import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/services/haptics.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

/// 48 dp accessible icon button; always requires a [tooltip] (semantic label).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.filled = false,
    this.color,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool filled;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed == null
          ? null
          : () {
              Haptics.tap();
              onPressed?.call();
            },
      icon: Icon(
        icon,
        size: AppSizes.icon,
        color: color,
        applyTextScaling: false,
      ),
      style: IconButton.styleFrom(
        minimumSize: const Size.square(AppSizes.touchTarget),
        backgroundColor: filled ? scheme.surfaceContainerHigh : null,
        foregroundColor: scheme.onSurface,
      ),
    );
  }
}
