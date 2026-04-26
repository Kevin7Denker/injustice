import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'numeric_spinner.dart';

class AccountAttributeCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String hint;
  final int minValue;
  final int maxValue;
  final int value;
  final ValueChanged<int> onChanged;

  const AccountAttributeCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.hint,
    required this.minValue,
    required this.maxValue,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outline.withOpacity(0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            // Icon with subtle glow background
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.textStyles.labelLarge?.copyWith(
                      color: AppColors.coolWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    hint,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: AppColors.coolWhiteFaint,
                    ),
                  ),
                ],
              ),
            ),
            NumericSpinner(
              value: value,
              minValue: minValue,
              maxValue: maxValue,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}