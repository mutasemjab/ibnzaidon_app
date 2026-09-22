import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/app_card.dart';
import 'package:ibnzaidon/design_system/components/course_card.dart';
import 'package:ibnzaidon/design_system/components/section_header.dart';
import 'package:ibnzaidon/design_system/tokens/app_colors.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/catalog/domain/entities/catalog_entities.dart';
import 'package:ibnzaidon/features/catalog/presentation/widgets/catalog_widgets.dart';
import 'package:ibnzaidon/features/home/domain/entities/home_data.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';
import 'package:ibnzaidon/shared/presentation/widgets/course_card_view.dart';

/// Horizontal course carousel with a section header.
class CourseCarousel extends StatelessWidget {
  const CourseCarousel({
    required this.title,
    required this.courses,
    this.onSeeAll,
    super.key,
  });

  final String title;
  final List<Course> courses;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onSeeAll: onSeeAll),
        SizedBox(
          height: 268,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.pagePadding,
            itemCount: courses.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, i) => SizedBox(
              width: AppSizes.courseCardWidth,
              child: CourseCardView(course: courses[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class TeachersCarousel extends StatelessWidget {
  const TeachersCarousel({required this.teachers, super.key});

  final List<Teacher> teachers;

  @override
  Widget build(BuildContext context) {
    if (teachers.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: context.l10n.homeTopTeachers,
          onSeeAll: () => context.push(AppRoutes.teachers),
        ),
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.pagePadding,
            itemCount: teachers.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) => TeacherCardView(teacher: teachers[i]),
          ),
        ),
      ],
    );
  }
}

class CategoriesStrip extends StatelessWidget {
  const CategoriesStrip({required this.categories, super.key});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: context.l10n.homeCategories,
          onSeeAll: () => context.go(AppRoutes.explore),
        ),
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.pagePadding,
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, i) => SizedBox(
              width: AppSizes.categoryCardWidth,
              child: CategoryCard(
                category: categories[i],
                onTap: () => context.push(
                  AppRoutes.category(categories[i].id),
                  extra: const <String>[],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Quick links to exams, teachers and results.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (Icons.quiz_rounded, l10n.homeQuickExams, AppRoutes.exams),
      (Icons.school_rounded, l10n.homeQuickCourses, AppRoutes.courses),
      (Icons.groups_rounded, l10n.homeQuickTeachers, AppRoutes.teachers),
      (Icons.emoji_events_rounded, l10n.homeQuickMyExams, AppRoutes.myExams),
    ];
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: InkWell(
                borderRadius: AppRadii.cardRadius,
                onTap: () => context.push(item.$3),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: context.colors.primaryContainer,
                          borderRadius: AppRadii.fieldRadius,
                        ),
                        child: SizedBox.square(
                          dimension: AppSizes.avatarMd + AppSpacing.xs,
                          child: Icon(item.$1, color: context.colors.primary),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        item.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Animated count-up stats strip.
class StatsStrip extends StatelessWidget {
  const StatsStrip({required this.stats, super.key});

  final PlatformStats stats;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Padding(
      padding: AppSpacing.pagePadding,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: context.palette.heroGradient,
          borderRadius: AppRadii.cardRadius,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              _Stat(value: stats.totalStudents, label: l10n.homeStatStudents),
              _Stat(value: stats.totalTeachers, label: l10n.homeStatTeachers),
              _Stat(value: stats.totalCourses, label: l10n.homeStatCourses),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: context.reduceMotion ? Duration.zero : AppMotion.slow * 3,
            curve: AppMotion.emphasizedDecelerate,
            builder: (context, current, _) => Text(
              AppFormatters.compactNumber(current),
              style: context.text.headlineSmall?.copyWith(
                color: AppColors.onHero,
              ),
            ),
          ),
          Text(
            label,
            style: context.text.labelMedium?.copyWith(
              color: AppColors.onHero.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline error card so a failing section never breaks the page.
class SectionError extends StatelessWidget {
  const SectionError({required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: AppCard(
        child: Row(
          children: [
            Icon(Icons.cloud_off_rounded, color: context.colors.error),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(message, style: context.text.bodyMedium)),
            AppButton(
              label: context.l10n.commonRetry,
              variant: AppButtonVariant.text,
              expanded: false,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact sign-in prompt shown to guests in place of personalised sections.
class GuestPrompt extends StatelessWidget {
  const GuestPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: AppSpacing.pagePadding,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.homeGuestPrompt, style: context.text.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.gateSignIn,
              expanded: false,
              onPressed: () => context.push(AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for the course carousels while `GET home` loads. Mirrors
/// [CourseCarousel]'s horizontal scroller so it never overflows narrow
/// screens the way a bare `Row` would.
class CarouselSkeleton extends StatelessWidget {
  const CarouselSkeleton({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 268,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.pagePadding,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        CourseCardSkeleton(),
        SizedBox(width: AppSpacing.md),
        CourseCardSkeleton(),
      ],
    ),
  );
}
