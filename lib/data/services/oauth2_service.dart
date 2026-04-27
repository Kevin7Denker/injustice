import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'oauth_web_bridge.dart';

final class OAuthRedirectInProgressException implements Exception {
  const OAuthRedirectInProgressException();
}

final class OAuthCredentials {
  final String accessToken;
  final String? refreshToken;
  final String? idToken;
  final DateTime? expiresAt;
  final List<String> scopes;

  const OAuthCredentials({
    required this.accessToken,
    this.refreshToken,
    this.idToken,
    this.expiresAt,
    this.scopes = const <String>[],
  });
}

final class OAuth2Service {
  OAuth2Service({FlutterAppAuth? appAuth})
    : _appAuth = appAuth ?? const FlutterAppAuth();

  final FlutterAppAuth _appAuth;
  static const String _pkceVerifierStorageKey = 'oauth.pkce_verifier';
  static const String _stateStorageKey = 'oauth.state';
  static const String _redirectUriStorageKey = 'oauth.redirect_uri';

  String get providerLabel =>
      dotenv.maybeGet('OAUTH_PROVIDER_NAME', fallback: 'Identity Provider') ??
      'Identity Provider';

  bool get isConfigured {
    final hasClientId =
      kIsWeb
        ? _optionalEnv('OAUTH_WEB_CLIENT_ID') != null
        : _optionalEnv('OAUTH_CLIENT_ID') != null;
    final hasRedirectUri =
      kIsWeb
        ? _optionalEnv('OAUTH_WEB_REDIRECT_URI') != null
        : _optionalEnv('OAUTH_REDIRECT_URI') != null;
    final hasIssuer = _optionalEnv('OAUTH_ISSUER') != null;

    final hasManualEndpoints =
        _optionalEnv('OAUTH_AUTHORIZATION_ENDPOINT') != null &&
        _optionalEnv('OAUTH_TOKEN_ENDPOINT') != null;

    return hasClientId && hasRedirectUri && (hasIssuer || hasManualEndpoints);
  }

  Future<OAuthCredentials> signIn() async {
    if (kIsWeb) {
      return _signInWeb();
    }

    if (!_isOAuthSupportedPlatform()) {
      throw StateError(
        'OAuth 2.0 via AppAuth e suportado apenas em Android, iOS e macOS.',
      );
    }

    final clientId = _requiredEnv('OAUTH_CLIENT_ID');
    final redirectUri = _requiredEnv('OAUTH_REDIRECT_URI');

    final isHttpRedirect =
        redirectUri.startsWith('http://') || redirectUri.startsWith('https://');

    /*if (!_isWebLikePlatform() && isHttpRedirect) {
      throw StateError(
        'OAUTH_REDIRECT_URI deve usar custom scheme no mobile. '
        'Ex.: com.googleusercontent.apps.<id>:/oauth2redirect',
      );
    }*/

    final issuer = _optionalEnv('OAUTH_ISSUER');
    final authEndpoint = _optionalEnv('OAUTH_AUTHORIZATION_ENDPOINT');
    final tokenEndpoint = _optionalEnv('OAUTH_TOKEN_ENDPOINT');

    final shouldUseManualEndpoints =
        (issuer == null || issuer.isEmpty) &&
        (authEndpoint != null && authEndpoint.isNotEmpty) &&
        (tokenEndpoint != null && tokenEndpoint.isNotEmpty);

    if ((issuer == null || issuer.isEmpty) && !shouldUseManualEndpoints) {
      throw StateError(
        'Configure OAUTH_ISSUER ou os dois endpoints '
        'OAUTH_AUTHORIZATION_ENDPOINT e OAUTH_TOKEN_ENDPOINT no .env.',
      );
    }

    final scopes = _resolveScopes();
    final allowInsecure =
        (_optionalEnv('OAUTH_ALLOW_INSECURE_CONNECTIONS') ?? 'false')
            .toLowerCase() ==
        'true';

    final response = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        clientId,
        redirectUri,
        issuer: shouldUseManualEndpoints ? null : issuer,
        serviceConfiguration: shouldUseManualEndpoints
            ? AuthorizationServiceConfiguration(
                authorizationEndpoint: authEndpoint!,
                tokenEndpoint: tokenEndpoint!,
              )
            : null,
        scopes: scopes,
        allowInsecureConnections: allowInsecure,
        promptValues: const <String>[Prompt.login],
      ),
    );

    final accessToken = response.accessToken;

    if (accessToken == null || accessToken.trim().isEmpty) {
      throw StateError('O provedor OAuth nao retornou access token valido.');
    }

    return OAuthCredentials(
      accessToken: accessToken,
      refreshToken: response.refreshToken,
      idToken: response.idToken,
      expiresAt: response.accessTokenExpirationDateTime,
      scopes: response.scopes ?? scopes,
    );
  }

  Future<OAuthCredentials> _signInWeb() async {
    if (!isWebOAuthBridgeAvailable) {
      throw StateError('OAuth web indisponivel nesta plataforma.');
    }

    final clientId = _requiredEnv('OAUTH_WEB_CLIENT_ID');
    final redirectUri = _resolveWebRedirectUri();
    _validateWebRedirectUri(redirectUri);
    final currentUri = webCurrentUri();

    final error = currentUri.queryParameters['error'];
    final errorDescription = currentUri.queryParameters['error_description'];

    if (error != null && error.trim().isNotEmpty) {
      webClearOAuthQueryParams();
      throw StateError(
        errorDescription ?? 'Falha na autorizacao OAuth: $error',
      );
    }

    final code = currentUri.queryParameters['code'];
    final returnedState = currentUri.queryParameters['state'];

    if (code != null && code.trim().isNotEmpty) {
      final expectedState = webStorageGet(_stateStorageKey);
      final verifier = webStorageGet(_pkceVerifierStorageKey);
      final storedRedirect =
          webStorageGet(_redirectUriStorageKey) ?? redirectUri;

      webStorageRemove(_stateStorageKey);
      webStorageRemove(_pkceVerifierStorageKey);
      webStorageRemove(_redirectUriStorageKey);
      webClearOAuthQueryParams();

      if (expectedState == null || verifier == null) {
        throw StateError(
          'Sessao OAuth web expirada. Tente autenticar novamente.',
        );
      }

      if (returnedState == null || returnedState != expectedState) {
        throw StateError('State OAuth invalido. Refaça o login.');
      }

      return _exchangeAuthorizationCodeForToken(
        code: code,
        codeVerifier: verifier,
        redirectUri: storedRedirect,
        clientId: clientId,
      );
    }

    final authEndpoint = _optionalEnv('OAUTH_AUTHORIZATION_ENDPOINT');

    if (authEndpoint == null || authEndpoint.isEmpty) {
      throw StateError(
        'No web, configure OAUTH_AUTHORIZATION_ENDPOINT no .env.',
      );
    }

    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _createCodeChallenge(codeVerifier);
    final state = _generateState();
    final scopes = _resolveScopes();

    final parameters = <String, String>{
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': scopes.join(' '),
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
      'state': state,
    };

    final prompt = _optionalEnv('OAUTH_WEB_PROMPT');
    if (prompt != null && prompt.isNotEmpty) {
      parameters['prompt'] = prompt;
    }

    webStorageSet(_stateStorageKey, state);
    webStorageSet(_pkceVerifierStorageKey, codeVerifier);
    webStorageSet(_redirectUriStorageKey, redirectUri);

    final authorizationUri = Uri.parse(
      authEndpoint,
    ).replace(queryParameters: parameters);

    webRedirectTo(authorizationUri.toString());
    throw const OAuthRedirectInProgressException();
  }

  Future<OAuthCredentials> _exchangeAuthorizationCodeForToken({
    required String code,
    required String codeVerifier,
    required String redirectUri,
    required String clientId,
  }) async {
    final tokenEndpoint = _optionalEnv('OAUTH_TOKEN_ENDPOINT');

    if (tokenEndpoint == null || tokenEndpoint.isEmpty) {
      throw StateError('No web, configure OAUTH_TOKEN_ENDPOINT no .env.');
    }

    final requestBody = <String, String>{
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': redirectUri,
      'client_id': clientId,
      'code_verifier': codeVerifier,
    };

    final clientSecret = _optionalEnv('OAUTH_CLIENT_SECRET');
    if (clientSecret != null && clientSecret.isNotEmpty) {
      requestBody['client_secret'] = clientSecret;
    }

    final response = await http.post(
      Uri.parse(tokenEndpoint),
      headers: const <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: requestBody,
    );

    final body = response.body.trim();
    final data = body.isEmpty
        ? <String, dynamic>{}
        : (jsonDecode(body) as Map<String, dynamic>);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorDescription = data['error_description'] as String?;
      final error = data['error'] as String?;
      throw StateError(
        errorDescription ??
            error ??
            'Falha ao trocar code por token (HTTP ${response.statusCode}).',
      );
    }

    final accessToken = data['access_token'] as String?;

    if (accessToken == null || accessToken.trim().isEmpty) {
      throw StateError('O provedor OAuth nao retornou access token valido.');
    }

    final expiresIn = _toIntOrNull(data['expires_in']);
    final expiresAt = expiresIn == null
        ? null
        : DateTime.now().add(Duration(seconds: expiresIn));

    final rawScope = data['scope'] as String?;
    final scopes = (rawScope == null || rawScope.trim().isEmpty)
        ? _resolveScopes()
        : rawScope
              .split(RegExp(r'[ ,]+'))
              .map((scope) => scope.trim())
              .where((scope) => scope.isNotEmpty)
              .toList(growable: false);

    return OAuthCredentials(
      accessToken: accessToken,
      refreshToken: data['refresh_token'] as String?,
      idToken: data['id_token'] as String?,
      expiresAt: expiresAt,
      scopes: scopes,
    );
  }

  bool _isOAuthSupportedPlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
    }
  }

  String _resolveWebRedirectUri() {
    final webRedirect = _optionalEnv('OAUTH_WEB_REDIRECT_URI');
    if (webRedirect != null && webRedirect.isNotEmpty) {
      return webRedirect;
    }

    final fallback = _requiredEnv('OAUTH_REDIRECT_URI');

    if (fallback.startsWith('http://') || fallback.startsWith('https://')) {
      return fallback;
    }

    final uri = webCurrentUri();
    return '${uri.origin}/login';
  }

  void _validateWebRedirectUri(String redirectUri) {
    final uri = Uri.tryParse(redirectUri);

    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw StateError(
        'OAUTH_WEB_REDIRECT_URI invalido. Use URL absoluta com https:// (ou http://localhost).',
      );
    }

    final isHttps = uri.scheme == 'https';
    final isLocalhost = uri.scheme == 'http' &&
        (uri.host == 'localhost' || uri.host == '127.0.0.1');

    if (!isHttps && !isLocalhost) {
      throw StateError(
        'OAUTH_WEB_REDIRECT_URI precisa ser https:// em producao. '
        'http:// e permitido apenas para localhost.',
      );
    }
  }

  String _generateCodeVerifier() {
    final secureRandom = Random.secure();
    final values = List<int>.generate(64, (_) => secureRandom.nextInt(256));
    return _base64UrlNoPadding(values);
  }

  String _createCodeChallenge(String codeVerifier) {
    final digest = sha256.convert(utf8.encode(codeVerifier));
    return _base64UrlNoPadding(digest.bytes);
  }

  String _generateState() {
    final secureRandom = Random.secure();
    final values = List<int>.generate(32, (_) => secureRandom.nextInt(256));
    return _base64UrlNoPadding(values);
  }

  String _base64UrlNoPadding(List<int> value) {
    return base64UrlEncode(value).replaceAll('=', '');
  }

  int? _toIntOrNull(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  String _requiredEnv(String key) {
    final value = _optionalEnv(key);

    if (value == null || value.isEmpty) {
      throw StateError('Variavel obrigatoria ausente no .env: $key');
    }

    return value;
  }

  String? _optionalEnv(String key) {
    final value = dotenv.maybeGet(key);

    if (value == null) {
      return null;
    }

    final normalized = value.trim();

    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  List<String> _resolveScopes() {
    final rawScopes = _optionalEnv('OAUTH_SCOPES');

    if (rawScopes == null || rawScopes.isEmpty) {
      return const <String>['openid', 'profile', 'email', 'offline_access'];
    }

    return rawScopes
        .split(RegExp(r'[ ,]+'))
        .map((scope) => scope.trim())
        .where((scope) => scope.isNotEmpty)
        .toList(growable: false);
  }
}
