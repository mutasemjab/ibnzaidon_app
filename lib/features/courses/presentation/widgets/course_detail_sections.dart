import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/design_system/components/app_card.dart';
import 'package:ibnzaidon/design_system/components/app_network_image.dart';
import 'package:ibnzaidon/design_system/components/chips.dart';
import 'package:ibnzaidon/design_system/components/price_view.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';
import 'package:ibnzaidon/shared/presentation/widgets/course_card_view.dart';

/// Collapsing hero: thumbnail + gradient scrim, title fades in once
/// collapsed. Shows a placeholder while [detail] is still loading.
class CourseHero extends StatelessWidget {
  const CourseHero({required this.detail, super.key});

  final CourseDetail? detail;

  @override
  Widget build(BuildContext context) {
    final course = detail?.course;
    return SliverAppBar(
      pinned: true,
      expandedHeight: AppSizes.heroExpandedHeight,
      title: Text(
        course?.title ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (course == null)
              const ImagePlaceholder()
            else
              Hero(
                tag: courseHeroTag(course.id),
                child: AppNetworkImage(url: course.thumbnail),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: context.palette.scrimGradient,
              ),
            ),
            if (course?.isLive ?? false)
              const PositionedDirectional(
                top: AppSpacing.giant,
                start: AppSpacing.lg,
                child: _LiveBadge(),
              ),
          ],
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.error,
        borderRadius: AppRadii.pillRadius,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              context.l10n.courseLive,
              style: context.text.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Title, teacher, stats and price. Every row is overflow-safe (long real
/// Arabic names/titles must never push a RenderFlex past its bounds).
class CourseSummary extends StatelessWidget {
  const CourseSummary({required this.detail, super.key});

  final CourseDetail detail;

  @override
  Widget build(BuildContext context) {
    final course = detail.course;
    final l10n = context.l10n;
    final teacher = course.teacher;
    return Padding(
      padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.text.headlineSmall,
          ),
          if (teacher != null) ...[
            const SizedBox(height: AppSpacing.md),
            _TeacherRow(teacher: teacher),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (course.averageRating > 0)
                RatingChip(rating: course.averageRating),
              StatChip(
                icon: Icons.people_alt_rounded,
                label: l10n.commonStudentsCount(
                  AppFormatters.compactNumber(
                    course.totalStudents > 0
                        ? course.totalStudents
                        : detail.enrollmentsCount,
                  ),
                ),
              ),
              if (course.durationHours > 0)
                StatChip(
                  icon: Icons.schedule_rounded,
                  label: l10n.commonHours(course.durationHours.round()),
                ),
              if (course.difficultyLevel != null)
                StatChip(
                  icon: Icons.signal_cellular_alt_rounded,
                  label: _difficultyLabel(context, course.difficultyLevel!),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Flexible(
                child: PriceView(
                  price: course.price,
                  oldPrice: course.oldPrice,
                  isFree: course.isFree,
                  large: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              DiscountBadge(percent: course.discountPercent),
            ],
          ),
        ],
      ),
    );
  }

  String _difficultyLabel(BuildContext context, String raw) {
    final l10n = context.l10n;
    return switch (raw.toLowerCase()) {
      'beginner' || 'easy' => l10n.difficultyBeginner,
      'intermediate' || 'medium' => l10n.difficultyIntermediate,
      'advanced' || 'hard' => l10n.difficultyAdvanced,
      _ => raw,
    };
  }
}

class _TeacherRow extends StatelessWidget {
  const _TeacherRow({required this.teacher});

  final TeacherRef teacher;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: AppRadii.pillRadius,
        onTap: () => context.push(AppRoutes.teacher(teacher.id)),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Hero(
                tag: teacherHeroTag(teacher.id),
                child: AppNetworkImage(
                  url: teacher.avatar,
                  width: AppSizes.avatarSm,
                  height: AppSizes.avatarSm,
                  circle: true,
                  placeholderIcon: Icons.person_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  teacher.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.colors.onSurfaceVariant,
                size: AppSizes.iconMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CourseAboutTab extends StatelessWidget {
  const CourseAboutTab({required this.detail, super.key});

  final CourseDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final description = detail.course.description;
    final hasContentStats = detail.totalVideos > 0 || detail.totalPdfs > 0;
    final hasAnything =
        description != null ||
        hasContentStats ||
        detail.whatYouLearn.isNotEmpty ||
        detail.requirements.isNotEmpty;
    if (!hasAnything) {
      return SizedBox(
        height: 220,
        child: EmptyState(message: l10n.courseNoContent),
      );
    }
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasContentStats)
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (detail.totalVideos > 0)
                  StatChip(
                    icon: Icons.play_circle_outline_rounded,
                    label: l10n.courseVideos(detail.totalVideos),
                  ),
                if (detail.totalPdfs > 0)
                  StatChip(
                    icon: Icons.picture_as_pdf_outlined,
                    label: l10n.coursePdfs(detail.totalPdfs),
                  ),
              ],
            ),
          if (description != null) ...[
            if (hasContentStats) const SizedBox(height: AppSpacing.xl),
            _SectionCard(
              title: l10n.courseDescription,
              child: Text(description, style: context.text.bodyMedium),
            ),
          ],
          if (detail.whatYouLearn.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _SectionCard(
              title: l10n.courseWhatYouLearn,
              child: _Bullets(
                items: detail.whatYouLearn,
                icon: Icons.check_circle_rounded,
                iconColor: context.palette.success,
              ),
            ),
          ],
          if (detail.requirements.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _SectionCard(
              title: l10n.courseRequirements,
              child: _Bullets(
                items: detail.requirements,
                icon: Icons.arrow_right_rounded,
                iconColor: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.text.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets({
    required this.items,
    required this.icon,
    required this.iconColor,
  });

  final List<String> items;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsetsDirectional.only(
              bottom: i == items.length - 1 ? 0 : AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: AppSizes.iconMd, color: iconColor),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(items[i], style: context.text.bodyMedium),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class CourseReviewsTab extends StatelessWidget {
  const CourseReviewsTab({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 280,
    child: EmptyState(
      icon: Icons.rate_review_outlined,
      title: context.l10n.courseTabReviews,
      message: context.l10n.courseReviewsPlaceholder,
    ),
  );
}
