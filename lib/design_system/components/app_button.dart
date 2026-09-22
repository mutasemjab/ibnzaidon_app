import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/services/haptics.dart';
import 'package:ibnzaidon/design_system/tokens/app_colors.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

enum AppButtonVariant { primary, secondary, text, destructive }

/// Brand button. Primary uses the signature gradient; all variants give
/// press feedback (scale + light haptic) and a loading state that blocks
/// double taps.
class AppButton extends StatefulWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.expanded = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool expanded;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  static const _pressedScale = 0.97;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  void _setPressed({required bool value}) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground, border) = switch (widget.variant) {
      AppButtonVariant.primary => (null, scheme.onPrimary, null),
      AppButtonVariant.secondary => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        null,
      ),
      AppButtonVariant.text => (
        Colors.transparent,
        scheme.primary,
        null,
      ),
      AppButtonVariant.destructive => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        BorderSide(color: scheme.error.withValues(alpha: 0.4)),
      ),
    };
    final isPrimary = widget.variant == AppButtonVariant.primary;
    final decoration = BoxDecoration(
      gradient: isPrimary ? AppColors.signatureGradient : null,
      color: background,
      borderRadius: AppRadii.buttonRadius,
      border: border == null ? null : Border.fromBorderSide(border),
    );

    return AnimatedScale(
      scale: _pressed && _enabled ? _pressedScale : 1,
      duration: AppMotion.fast,
      child: AnimatedOpacity(
        opacity: widget.onPressed == null ? 0.5 : 1,
        duration: AppMotion.fast,
        child: Semantics(
          button: true,
          enabled: _enabled,
          label: widget.label,
          excludeSemantics: true,
          // `Ink`'s decoration paints on the *nearest ancestor* Material's
          // ink layer, which is drawn before that Material's child subtree.
          // Without a Material directly here, any opaque widget between this
          // button and the enclosing Material (a card, a bottom sheet panel,
          // this very auth card, ...) paints over the gradient afterwards
          // and hides it completely. Wrapping in a local transparent
          // Material makes this button its own nearest Material, so nothing
          // can paint over it.
          child: Material(
            type: MaterialType.transparency,
            child: Ink(
              decoration: decoration,
              child: InkWell(
                borderRadius: AppRadii.buttonRadius,
                onTap: _enabled
                    ? () {
                        Haptics.light();
                        widget.onPressed?.call();
                      }
                    : null,
                onHighlightChanged: (value) => _setPressed(value: value),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppSizes.buttonHeight,
                    minWidth: AppSizes.touchTarget,
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.sm,
                    ),
                    child: _Content(
                      label: widget.label,
                      icon: widget.icon,
                      isLoading: widget.isLoading,
                      color: foreground,
                      expanded: widget.expanded,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.color,
    required this.expanded,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;
  final Color color;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: color,
      fontSize: 15,
    );
    return Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox.square(
            dimension: AppSizes.iconMd,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: color),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: AppSizes.iconMd, color: color),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Text(
              label,
              style: style,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ],
    );
  }
}
