import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  late final AuthViewModel _authViewModel;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _authViewModel = injector.get<AuthViewModel>();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.2, end: 0.45).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleOAuthSignIn() async {
    final isSuccess = await _authViewModel.signInWithOAuth();

    if (!mounted) {
      return;
    }

    if (isSuccess) {
      context.goNamed(AppRouteNames.home);
      return;
    }

    final errorMessage = _authViewModel.errorMessage;

    if (errorMessage != null && errorMessage.trim().isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.hotMagenta,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AnimatedBuilder(
                  animation: _authViewModel,
                  builder: (context, _) {
                    final isLoading = _authViewModel.isLoading;
                    final isConfigured = _authViewModel.isConfigured;
                    final errorMessage = _authViewModel.errorMessage;

                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(color: AppColors.outline, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonCyan.withOpacity(0.08),
                            blurRadius: 22,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: 86,
                                  height: 86,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.accentGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.neonCyan.withOpacity(
                                          _pulseAnimation.value,
                                        ),
                                        blurRadius: 30,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.lock_open_rounded,
                                    color: AppColors.void_,
                                    size: 42,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          Text(
                            'ACCESS TERMINAL',
                            textAlign: TextAlign.center,
                            style: context.textStyles.headlineMedium?.copyWith(
                              color: AppColors.coolWhite,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          Text(
                            'Autentique-se via OAuth 2.0 para acessar o sistema.',
                            textAlign: TextAlign.center,
                            style: context.textStyles.bodyMedium?.copyWith(
                              color: AppColors.coolWhiteMuted,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: AppColors.outline,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Provider: ${_authViewModel.providerLabel}',
                              textAlign: TextAlign.center,
                              style: context.textStyles.labelLarge?.copyWith(
                                color: AppColors.plasmaViolet,
                                letterSpacing: 0.4,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          if (!isConfigured) ...[
                            const SizedBox(height: AppSpacing.md),
                            _ConfigHintBanner(),
                          ],

                          if (errorMessage != null &&
                              errorMessage.trim().isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            _ErrorBanner(message: errorMessage),
                          ],

                          const SizedBox(height: AppSpacing.xl),

                          Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.accentGradient,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.neonCyan.withOpacity(0.20),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: isLoading || !isConfigured
                                  ? null
                                  : _handleOAuthSignIn,
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.void_,
                                      ),
                                    )
                                  : const Icon(Icons.login_rounded),
                              label: Text(
                                isLoading
                                    ? 'Conectando...'
                                    : 'Entrar com OAuth 2.0',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                disabledBackgroundColor: Colors.transparent,
                                disabledForegroundColor: AppColors.void_
                                    .withOpacity(0.6),
                                minimumSize: const Size.fromHeight(52),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfigHintBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.plasmaGold.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.plasmaGold.withOpacity(0.4)),
      ),
      child: Text(
        'Configure no .env: OAUTH_CLIENT_ID, OAUTH_REDIRECT_URI e OAUTH_ISSUER\n'
        'ou OAUTH_AUTHORIZATION_ENDPOINT + OAUTH_TOKEN_ENDPOINT.',
        style: context.textStyles.bodySmall?.copyWith(
          color: AppColors.coolWhite,
          height: 1.4,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.hotMagenta.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.hotMagenta.withOpacity(0.5)),
      ),
      child: Text(
        message,
        style: context.textStyles.bodySmall?.copyWith(
          color: AppColors.coolWhite,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
    );
  }
}
