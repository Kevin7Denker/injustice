import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  String get providerLabel =>
      dotenv.maybeGet('OAUTH_PROVIDER_NAME', fallback: 'Identity Provider') ??
      'Identity Provider';

  bool get isConfigured {
    final hasClientId = _optionalEnv('OAUTH_CLIENT_ID') != null;
    final hasRedirectUri = _optionalEnv('OAUTH_REDIRECT_URI') != null;
    final hasIssuer = _optionalEnv('OAUTH_ISSUER') != null;

    final hasManualEndpoints =
        _optionalEnv('OAUTH_AUTHORIZATION_ENDPOINT') != null &&
        _optionalEnv('OAUTH_TOKEN_ENDPOINT') != null;

    return hasClientId && hasRedirectUri && (hasIssuer || hasManualEndpoints);
  }

  Future<OAuthCredentials> signIn() async {
    final clientId = _requiredEnv('OAUTH_CLIENT_ID');
    final redirectUri = _requiredEnv('OAUTH_REDIRECT_URI');

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
