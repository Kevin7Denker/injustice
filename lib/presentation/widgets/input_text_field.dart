import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

class InputTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? prefixIcon;

  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Key? fieldKey;

  final bool enabled;

  const InputTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.prefixIcon,
    this.validator,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.enabled = true,
    this.fieldKey,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14);

    return TextFormField(
      key: fieldKey,
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onFieldSubmitted: onFieldSubmitted,

      style: const TextStyle(
        color: AppColors.coolWhite,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),

      cursorColor: AppColors.neonCyan,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint ?? label,
        hintStyle: TextStyle(
          color: AppColors.coolWhiteFaint,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: AppColors.coolWhiteMuted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),

        floatingLabelStyle: TextStyle(
          color: AppColors.neonCyan,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),

        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.coolWhiteMuted, size: 20)
            : null,

        filled: true,
        fillColor: AppColors.surfaceVariant,

        border: OutlineInputBorder(borderRadius: borderRadius),

        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.outline, width: 1),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.neonCyan, width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.hotMagenta, width: 1),
        ),
        errorStyle: TextStyle(
          color: AppColors.hotMagentaLight,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.hotMagenta, width: 1.5),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),

      validator: validator,
    );
  }
}
