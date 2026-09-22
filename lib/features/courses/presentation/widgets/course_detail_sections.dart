import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/design_system/components/app_network_image.dart';
import 'package:ibnzaidon/design_system/components/chips.dart';
import 'package:ibnzaidon/design_system/components/price_view.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/shared/presentation/widgets/course_card_view.dart';

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
          ],
        ),
      ),
    );
  }
}

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
          Text(course.title, style: context.text.headlineSmall),
          if (teacher != null) ...[
            const SizedBox(height: AppSpacing.md),
            InkWell(
              borderRadius: AppRadii.pillRadius,
              onTap: () => context.push(AppRoutes.teacher(teacher.id)),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
                    Text(teacher.name, style: context.text.titleSmall),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
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
              if (course.isLive)
                StatChip(
                  icon: Icons.sensors_rounded,
                  label: l10n.courseLive,
                  tint: context.colors.errorContainer,
                  onTint: context.colors.onErrorContainer,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              PriceView(
                price: course.price,
                oldPrice: course.oldPrice,
                isFree: course.isFree,
                large: true,
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

class CourseAboutTab extends StatelessWidget {
  const CourseAboutTab({required this.detail, super.key});

  final CourseDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final description = detail.course.description;
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description != null) ...[
            Text(l10n.courseDescription, style: context.text.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(description, style: context.text.bodyMedium),
            const SizedBox(height: AppSpacing.xl),
          ],
          if (detail.totalVideos > 0 || detail.totalPdfs > 0)
            Wrap(
              spacing: AppSpacing.sm,
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
          if (detail.whatYouLearn.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.courseWhatYouLearn, style: context.text.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _Bullets(
              items: detail.whatYouLearn,
              icon: Icons.check_circle_rounded,
            ),
          ],
          if (detail.requirements.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.courseRequirements, style: context.text.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _Bullets(
              items: detail.requirements,
              icon: Icons.arrow_right_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets({required this.items, required this.icon});

  final List<String> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: AppSizes.iconMd,
                  color: context.palette.success,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(item, style: context.text.bodyMedium)),
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
