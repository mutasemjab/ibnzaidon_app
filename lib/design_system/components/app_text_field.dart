import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

/// RTL-aware form field with built-in validation, server error text and a
/// password visibility toggle.
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.isPassword = false,
    this.prefixIcon,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.autofillHints,
    this.forceLtr = false,
    this.enabled = true,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final FormFieldValidator<String>? validator;

  /// Server-side (422) error for this field.
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool isPassword;
  final IconData? prefixIcon;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;

  /// Phone numbers, codes and emails stay left-to-right even in Arabic.
  final bool forceLtr;
  final bool enabled;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colors;
    final visibilityToggle = widget.isPassword
        ? IconButton(
            tooltip: _obscured ? l10n.authShowPassword : l10n.authHidePassword,
            onPressed: () => setState(() => _obscured = !_obscured),
            icon: Icon(
              _obscured
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: scheme.onSurfaceVariant,
            ),
          )
        : widget.suffix;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      obscureText: widget.isPassword && _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      textDirection: widget.forceLtr ? TextDirection.ltr : null,
      textAlign: widget.forceLtr ? TextAlign.start : TextAlign.start,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: context.text.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        errorMaxLines: 3,
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, size: AppSizes.icon),
        suffixIcon: visibilityToggle,
        alignLabelWithHint: widget.maxLines > 1,
      ),
    );
  }
}
