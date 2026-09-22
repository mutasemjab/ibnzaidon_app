import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/design_system/components/app_card.dart';
import 'package:ibnzaidon/design_system/components/app_network_image.dart';
import 'package:ibnzaidon/design_system/components/chips.dart';
import 'package:ibnzaidon/design_system/components/progress_ring.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

enum CourseCardVariant { vertical, horizontal, compact }

/// Entity-agnostic course card. Features map their entity onto these
/// primitives; price widgets arrive as slots so `show_price` gating stays in
/// `PriceView` / `DiscountBadge`.
class CourseCard extends StatelessWidget {
  const CourseCard({
    required this.title,
    this.thumbnailUrl,
    this.teacherName,
    this.teacherAvatarUrl,
    this.rating,
    this.priceSlot,
    this.discountSlot,
    this.progress,
    this.subtitle,
    this.heroTag,
    this.onTap,
    this.variant = CourseCardVariant.vertical,
    super.key,
  });

  final String title;
  final String? thumbnailUrl;
  final String? teacherName;
  final String? teacherAvatarUrl;
  final double? rating;
  final Widget? priceSlot;
  final Widget? discountSlot;

  /// 0..1 when the student is enrolled.
  final double? progress;
  final String? subtitle;
  final Object? heroTag;
  final VoidCallback? onTap;
  final CourseCardVariant variant;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      CourseCardVariant.horizontal => _HorizontalLayout(card: this),
      CourseCardVariant.compact => _VerticalLayout(card: this, compact: true),
      CourseCardVariant.vertical => _VerticalLayout(card: this),
    };
  }

  Widget buildThumbnail({BorderRadius radius = AppRadii.cardRadius}) {
    final image = AppNetworkImage(url: thumbnailUrl, borderRadius: radius);
    return heroTag == null ? image : Hero(tag: heroTag!, child: image);
  }
}

class _VerticalLayout extends StatelessWidget {
  const _VerticalLayout({required this.card, this.compact = false});

  final CourseCard card;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppCard(
      onTap: card.onTap,
      padding: EdgeInsets.zero,
      semanticLabel: card.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                card.buildThumbnail(
                  radius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadii.card),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: palette.scrimGradient,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadii.card),
                    ),
                  ),
                ),
                if (card.discountSlot != null)
                  PositionedDirectional(
                    top: AppSpacing.sm,
                    start: AppSpacing.sm,
                    child: card.discountSlot!,
                  ),
                if (card.rating != null && !compact)
                  PositionedDirectional(
                    bottom: AppSpacing.sm,
                    end: AppSpacing.sm,
                    child: RatingChip(rating: card.rating!),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall,
                ),
                if (card.teacherName != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _TeacherLine(card: card, compact: compact),
                ],
                if (card.priceSlot != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  card.priceSlot!,
                ],
                if (card.progress != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _ProgressBar(progress: card.progress!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalLayout extends StatelessWidget {
  const _HorizontalLayout({required this.card});

  final CourseCard card;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: card.onTap,
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      semanticLabel: card.title,
      child: Row(
        children: [
          SizedBox(
            width: AppSizes.thumbnailCompact + AppSpacing.xl,
            height: AppSizes.thumbnailCompact,
            child: card.buildThumbnail(radius: AppRadii.fieldRadius),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall,
                ),
                if (card.subtitle != null || card.teacherName != null)
                  Text(
                    card.subtitle ?? card.teacherName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    if (card.rating != null) RatingChip(rating: card.rating!),
                    if (card.priceSlot != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(child: card.priceSlot!),
                    ],
                    if (card.discountSlot != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      card.discountSlot!,
                    ],
                  ],
                ),
                if (card.progress != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _ProgressBar(progress: card.progress!),
                ],
              ],
            ),
          ),
          if (card.progress != null) ...[
            const SizedBox(width: AppSpacing.sm),
            ProgressRing(progress: card.progress!),
          ],
        ],
      ),
    );
  }
}

class _TeacherLine extends StatelessWidget {
  const _TeacherLine({required this.card, required this.compact});

  final CourseCard card;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!compact) ...[
          AppNetworkImage(
            url: card.teacherAvatarUrl,
            width: AppSizes.avatarSm - AppSpacing.sm,
            height: AppSizes.avatarSm - AppSpacing.sm,
            circle: true,
            placeholderIcon: Icons.person_rounded,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: Text(
            card.teacherName!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: AppFormatters.percent(progress),
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0, 1)),
        duration: context.reduceMotion ? Duration.zero : AppMotion.slow,
        curve: AppMotion.emphasizedDecelerate,
        builder: (context, value, _) => ClipRRect(
          borderRadius: AppRadii.pillRadius,
          child: LinearProgressIndicator(
            value: value,
            minHeight: AppSpacing.xs + AppSpacing.xxs,
          ),
        ),
      ),
    );
  }
}

/// Skeleton matching [CourseCardVariant.vertical] at carousel width.
class CourseCardSkeleton extends StatelessWidget {
  const CourseCardSkeleton({this.width = AppSizes.courseCardWidth, super.key});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: SkeletonBox(height: double.infinity, radius: AppRadii.card),
          ),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(height: AppSpacing.lg),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(width: 120, height: AppSpacing.md),
        ],
      ),
    );
  }
}
