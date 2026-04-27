import '../../domain/models/account_entity.dart';
import '../../presentation/controllers/account_viewmodel.dart';
import '../../presentation/controllers/auth_viewmodel.dart';
import '../../presentation/views/login_view.dart';
import '../../presentation/views/about_view.dart';
import '../../presentation/views/account_create_view.dart';
import '../../presentation/views/characters_view.dart';
import '../../presentation/views/home_view.dart';
import '../di/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Route names for easier referencing
class AppRouteNames {
  static const login = 'login';
  static const home = 'home';
  static const about = 'about';
  static const accountCreate = 'account_create';
  static const characters = 'characters';
}

/// Paths to keep URL structure consistent
class AppPaths {
  static const login = '/login';
  static const home = '/home';
  static const about = '/about';
  static const accountCreate = '/account-create';
  static const characters = '/characters';
}

/// app routers using go_router
class AppRouter {
  AppRouter._();

  static final AuthViewModel _authViewModel = injector.get<AuthViewModel>();

  static final GoRouter router = GoRouter(
    initialLocation: AppPaths.login,
    refreshListenable: _authViewModel,
    redirect: (context, state) {
      final isLoginRoute = state.matchedLocation == AppPaths.login;
      final isAuthenticated = _authViewModel.isAuthenticated;

      if (!isAuthenticated && !isLoginRoute) {
        return AppPaths.login;
      }

      if (isAuthenticated && isLoginRoute) {
        return AppPaths.home;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppPaths.login,
        name: AppRouteNames.login,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const LoginView()),
      ),
      GoRoute(
        path: AppPaths.home,
        name: AppRouteNames.home,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const HomeView()),
      ),
      GoRoute(
        path: AppPaths.accountCreate,
        name: AppRouteNames.accountCreate,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const AccountCreateView()),
      ),
      GoRoute(
        path: AppPaths.characters,
        name: AppRouteNames.characters,
        pageBuilder: (context, state) {
          final accountFromExtra = state.extra;
          final accountFromState = injector
              .get<AccountViewModel>()
              .accountState
              .state
              .value;
          final account = accountFromExtra is Account
              ? accountFromExtra
              : accountFromState;

          if (account == null) {
            return _buildPage(state: state, child: const HomeView());
          }

          return _buildPage(
            state: state,
            child: CharactersView(account: account),
          );
        },
      ),
      GoRoute(
        path: AppPaths.about,
        name: AppRouteNames.about,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const AboutView()),
      ),
    ],
  );

  /// Cinematic fade + vertical slide transition
  static CustomTransitionPage _buildPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(fadeAnimation);

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
    );
  }
}
