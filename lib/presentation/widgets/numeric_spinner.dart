import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

/// Widget personalizado para seleção numérica com botões de incremento/decremento
///
/// Permite:
/// - Incremento e decremento com botões
/// - Digitação manual
/// - Limites configuráveis (mínimo e máximo)
class NumericSpinner extends StatefulWidget {
  final int value;
  final int minValue;
  final int maxValue;
  final int step;
  final String? label;
  final ValueChanged<int> onChanged;

  const NumericSpinner({
    super.key,
    required this.value,
    required this.onChanged,
    this.minValue = 0,
    this.maxValue = 999999,
    this.step = 1,
    this.label,
  });

  @override
  State<NumericSpinner> createState() => _NumericSpinnerState();
}

class _NumericSpinnerState extends State<NumericSpinner> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(NumericSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _validateAndUpdate();
    }
  }

  void _validateAndUpdate() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _controller.text = widget.value.toString();
      return;
    }

    final value = int.tryParse(text);
    if (value == null) {
      _controller.text = widget.value.toString();
      return;
    }

    final clampedValue = value.clamp(widget.minValue, widget.maxValue);
    _controller.text = clampedValue.toString();
    if (clampedValue != widget.value) {
      widget.onChanged(clampedValue);
    }
  }

  void _increment() {
    final newValue = (widget.value + widget.step).clamp(
      widget.minValue,
      widget.maxValue,
    );
    if (newValue != widget.value) {
      widget.onChanged(newValue);
    }
  }

  void _decrement() {
    final newValue = (widget.value - widget.step).clamp(
      widget.minValue,
      widget.maxValue,
    );
    if (newValue != widget.value) {
      widget.onChanged(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canIncrement = widget.value < widget.maxValue;
    final canDecrement = widget.value > widget.minValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: context.textStyles.labelLarge?.withColor(
              AppColors.coolWhiteMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(
              color: AppColors.outline,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrement button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canDecrement ? _decrement : null,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppRadius.md),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm + 2),
                    child: Icon(
                      Icons.remove_rounded,
                      size: 18,
                      color: canDecrement
                          ? AppColors.neonCyan
                          : AppColors.coolWhiteFaint,
                    ),
                  ),
                ),
              ),

              // Input field
              Container(
                width: 70,
                padding: AppSpacing.horizontalSm,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  cursorColor: AppColors.neonCyan,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  style: context.textStyles.titleMedium?.copyWith(
                    color: AppColors.coolWhite,
                    fontWeight: FontWeight.w700,
                  ),
                  onSubmitted: (_) => _validateAndUpdate(),
                ),
              ),

              // Increment button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canIncrement ? _increment : null,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(AppRadius.md),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm + 2),
                    child: Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: canIncrement
                          ? AppColors.neonCyan
                          : AppColors.coolWhiteFaint,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
