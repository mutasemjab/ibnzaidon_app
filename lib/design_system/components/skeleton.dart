import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:shimmer/shimmer.dart';

/// Wrap any group of [SkeletonBox]es once; the shimmer is shared and turns
/// off when the user asked to reduce motion.
class SkeletonShimmer extends StatelessWidget {
  const SkeletonShimmer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Semantics(
      label: context.l10n.commonSearch,
      excludeSemantics: true,
      child: Shimmer.fromColors(
        enabled: !context.reduceMotion,
        baseColor: scheme.surfaceContainerHigh,
        highlightColor: scheme.surfaceContainerLowest,
        child: child,
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    this.width,
    this.height = AppSpacing.lg,
    this.radius = AppRadii.chip,
    this.circle = false,
    super.key,
  });

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}

/// Vertical list of identical skeleton rows.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    required this.itemBuilder,
    this.itemCount = 6,
    this.padding = AppSpacing.pagePadding,
    this.spacing = AppSpacing.md,
    this.shrinkWrap = false,
    super.key,
  });

  final WidgetBuilder itemBuilder;
  final int itemCount;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.separated(
        shrinkWrap: shrinkWrap,
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(height: spacing),
        itemBuilder: (context, _) => itemBuilder(context),
      ),
    );
  }
}

/// A generic "card row" skeleton (thumbnail + two text lines).
class SkeletonRow extends StatelessWidget {
  const SkeletonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBox(
          width: AppSizes.thumbnailCompact,
          height: AppSizes.thumbnailCompact,
          radius: AppRadii.field,
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(height: AppSpacing.lg),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(width: 120, height: AppSpacing.md),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(width: 80, height: AppSpacing.md),
            ],
          ),
        ),
      ],
    );
  }
}
