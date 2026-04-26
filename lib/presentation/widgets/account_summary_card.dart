import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/account_entity.dart';

class AccountSummaryCard extends StatelessWidget {
  final Account account;

  const AccountSummaryCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline, width: 1),
      ),
      child: Column(
        children: [
          // Top cyan→violet accent line
          Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(2),
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.neonCyan.withOpacity(0.8),
                  AppColors.plasmaViolet.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: AppSpacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        account.displayName.toUpperCase(),
                        style: context.textStyles.headlineLarge?.copyWith(
                          color: AppColors.coolWhite,
                          letterSpacing: 2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neonCyan.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.neonCyan.withOpacity(0.25),
                        ),
                      ),
                      child: Text(
                        'LV.${account.level}',
                        style: context.textStyles.titleSmall?.copyWith(
                          color: AppColors.neonCyan,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(
                      icon: Icons.bolt_rounded,
                      label: 'Energia',
                      value: account.energy.toString(),
                      color: AppColors.limeScan,
                    ),
                    _StatItem(
                      icon: Icons.diamond_rounded,
                      label: 'Gemas',
                      value: account.gems.toString(),
                      color: AppColors.techBlue,
                    ),
                    _StatItem(
                      icon: Icons.attach_money_rounded,
                      label: 'Gold',
                      value: account.gold.toStringAsFixed(0),
                      color: AppColors.plasmaGold,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: context.textStyles.labelLarge?.copyWith(
            color: AppColors.coolWhite,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: context.textStyles.bodySmall?.copyWith(
            color: AppColors.coolWhiteMuted,
          ),
        ),
      ],
    );
  }
}
