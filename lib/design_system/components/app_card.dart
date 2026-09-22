import 'package:flutter/material.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

/// Large rounded surface with soft layered shadow (tone-based in dark mode).
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsetsDirectional.all(AppSpacing.lg),
    this.color,
    this.gradient,
    this.borderRadius = AppRadii.cardRadius,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final BorderRadius borderRadius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: gradient == null
              ? color ?? scheme.surfaceContainerLowest
              : null,
          gradient: gradient,
          borderRadius: borderRadius,
          boxShadow: AppShadows.soft(context),
          border: isDark
              ? Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6))
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
