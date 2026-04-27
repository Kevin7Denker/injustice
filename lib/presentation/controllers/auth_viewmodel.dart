import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import '../../data/services/oauth2_service.dart';

final class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required OAuth2Service oauth2Service})
    : _oauth2Service = oauth2Service;

  final OAuth2Service _oauth2Service;

  bool _isLoading = false;
  String? _errorMessage;
  OAuthCredentials? _credentials;

  bool get isLoading => _isLoading;
  bool get isAuthenticated =>
      _credentials != null && _credentials!.accessToken.trim().isNotEmpty;

  bool get isConfigured => _oauth2Service.isConfigured;
  String get providerLabel => _oauth2Service.providerLabel;

  String? get errorMessage => _errorMessage;
  DateTime? get accessTokenExpiresAt => _credentials?.expiresAt;

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signInWithOAuth() async {
    if (_isLoading) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credentials = await _oauth2Service.signIn();
      _credentials = credentials;

      _isLoading = false;
      notifyListeners();
      return true;
    } on FlutterAppAuthUserCancelledException {
      _errorMessage = 'Login cancelado pelo usuario.';
    } on FlutterAppAuthPlatformException catch (error) {
      _errorMessage =
          error.platformErrorDetails.errorDescription ??
          error.platformErrorDetails.error ??
          error.message ??
          'Falha ao autenticar com OAuth 2.0.';
    } on StateError catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Nao foi possivel concluir o login OAuth 2.0.';
    }

    _isLoading = false;
    notifyListeners();

    return false;
  }

  void signOut() {
    _credentials = null;
    _errorMessage = null;
    notifyListeners();
  }
}
