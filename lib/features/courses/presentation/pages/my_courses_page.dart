import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/bloc/paged_bloc.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_card.dart';
import 'package:ibnzaidon/design_system/components/app_network_image.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/progress_ring.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:ibnzaidon/shared/presentation/auth_gate.dart';
import 'package:ibnzaidon/shared/presentation/paged_bloc_view.dart';
import 'package:ibnzaidon/shared/presentation/widgets/course_card_view.dart';

/// "My courses" tab: progress rings, completed badge, continue button.
class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myCoursesTitle)),
      body: ContentConstraint(
        child: AuthGate(
          message: l10n.myCoursesGate,
          builder: (_) => BlocProvider(
            create: (_) =>
                getIt<MyCoursesBloc>()..add(const PagedStarted<NoQuery>()),
            child: PagedBlocView<MyCoursesBloc, Enrollment, NoQuery>(
              skeletonBuilder: (_) => const SkeletonRow(),
              emptyBuilder: (context) => EmptyState(
                icon: Icons.school_outlined,
                title: l10n.myCoursesEmptyTitle,
                message: l10n.myCoursesEmptyBody,
                actionLabel: l10n.myCoursesBrowse,
                onAction: () => context.go(AppRoutes.explore),
              ),
              itemBuilder: (context, enrollment, _) =>
                  _EnrollmentCard(enrollment: enrollment),
            ),
          ),
        ),
      ),
    );
  }
}

class _EnrollmentCard extends StatelessWidget {
  const _EnrollmentCard({required this.enrollment});

  final Enrollment enrollment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final course = enrollment.course;
    return AppCard(
      onTap: () => context.push(AppRoutes.course(course.id)),
      semanticLabel: course.title,
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Row(
        children: [
          Hero(
            tag: courseHeroTag(course.id),
            child: AppNetworkImage(
              url: course.thumbnail,
              width: AppSizes.thumbnailCompact,
              height: AppSizes.thumbnailCompact,
              borderRadius: AppRadii.fieldRadius,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall,
                ),
                if (course.teacherName != null)
                  Text(
                    course.teacherName!,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                if (enrollment.isCompleted)
                  Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: AppSizes.iconMd,
                        color: context.palette.success,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.myCoursesCompleted,
                        style: context.text.labelMedium?.copyWith(
                          color: context.palette.success,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    l10n.myCoursesContinue,
                    style: context.text.labelLarge?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ProgressRing(
            progress: enrollment.progress,
            color: enrollment.isCompleted ? context.palette.success : null,
          ),
        ],
      ),
    );
  }
}
