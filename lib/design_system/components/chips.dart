import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

/// Amber star + numeric rating.
class RatingChip extends StatelessWidget {
  const RatingChip({required this.rating, super.key});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      label: rating.toStringAsFixed(1),
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.warningContainer,
          borderRadius: AppRadii.chipRadius,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_rounded,
                size: AppSizes.iconSm,
                color: palette.warning,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                rating.toStringAsFixed(1),
                style: context.text.labelMedium?.copyWith(
                  color: palette.onWarningContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small tinted icon + label (students, duration, difficulty, ...).
class StatChip extends StatelessWidget {
  const StatChip({
    required this.icon,
    required this.label,
    this.tint,
    this.onTint,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color? tint;
  final Color? onTint;

  @override
  Widget build(BuildContext context) {
    final background = tint ?? context.colors.surfaceContainerHigh;
    final foreground = onTint ?? context.colors.onSurfaceVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.chipRadius,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSizes.iconSm, color: foreground),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelMedium?.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
