import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/account_entity.dart';
import '../controllers/account_viewmodel.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Glassmorphic sidebar drawer with animated active indicators
class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final _vmAccount = injector.get<AccountViewModel>();

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Drawer(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.void_.withOpacity(0.94),
            border: Border(
              right: BorderSide(
                color: AppColors.neonCyan.withOpacity(0.12),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ── Header ──
                _DrawerHeader(),

                // ── Cyan→Violet gradient divider ──
                Container(
                  height: 1.5,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.neonCyan.withOpacity(0.6),
                        AppColors.plasmaViolet.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Navigation Items ──
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Início',
                  isActive: currentRoute == AppPaths.home,
                  onTap: () {
                    context.pop();
                    if (currentRoute != AppPaths.home) {
                      context.goNamed(AppRouteNames.home);
                    }
                  },
                ),

                Watch((_) {
                  final hasAccount = _vmAccount.accountState.hasAccount.value;
                  return _NavItem(
                    icon: hasAccount
                        ? Icons.edit_rounded
                        : Icons.person_add_rounded,
                    label: hasAccount ? 'Editar Conta' : 'Criar Conta',
                    isActive: currentRoute == AppPaths.accountCreate,
                    onTap: () {
                      context.pop();
                      if (currentRoute != AppPaths.accountCreate) {
                        context.goNamed(AppRouteNames.accountCreate);
                      }
                    },
                  );
                }),

                Watch((_) {
                  final hasAccount = _vmAccount.accountState.hasAccount.value;
                  return _NavItem(
                    icon: Icons.people_rounded,
                    label: 'Personagens',
                    isActive: currentRoute == AppPaths.characters,
                    isDisabled: !hasAccount,
                    onTap: hasAccount
                        ? () {
                            context.pop();
                            Account account =
                                _vmAccount.accountState.state.value!;
                            if (currentRoute != AppPaths.characters) {
                              context.goNamed(
                                AppRouteNames.characters,
                                extra: account,
                              );
                            }
                          }
                        : null,
                  );
                }),

                _NavItem(
                  icon: Icons.info_rounded,
                  label: 'Sobre',
                  isActive: currentRoute == AppPaths.about,
                  onTap: () {
                    context.pop();
                    if (currentRoute != AppPaths.about) {
                      context.goNamed(AppRouteNames.about);
                    }
                  },
                ),

                const Spacer(),

                // ── Footer branding ──
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'v1.0.0',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.withColor(AppColors.coolWhiteFaint),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Drawer header with game branding
class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          // Glowing cyan icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.accentGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withOpacity(0.35),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.radar_rounded,
              color: AppColors.void_,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'injustice',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.coolWhite,
                    letterSpacing: 3,
                  ),
                ),
                Text(
                  'MOBILE',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.neonCyan,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Single nav item with animated active indicator and glow
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.isDisabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor;
    final Color textColor;

    if (isDisabled) {
      iconColor = AppColors.coolWhiteFaint;
      textColor = AppColors.coolWhiteFaint;
    } else if (isActive) {
      iconColor = AppColors.neonCyan;
      textColor = AppColors.coolWhite;
    } else {
      iconColor = AppColors.coolWhiteMuted;
      textColor = AppColors.coolWhiteMuted;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        splashColor: AppColors.neonCyan.withOpacity(0.1),
        highlightColor: AppColors.neonCyan.withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            color: isActive
                ? AppColors.neonCyan.withOpacity(0.06)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              // Active bar with cyan glow
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 3,
                height: isActive ? 24 : 0,
                margin: const EdgeInsets.only(right: AppSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isActive ? AppColors.neonCyan : Colors.transparent,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.neonCyan.withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
              ),
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: textColor,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
