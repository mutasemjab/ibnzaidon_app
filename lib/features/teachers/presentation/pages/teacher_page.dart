import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/design_system/components/app_network_image.dart';
import 'package:ibnzaidon/design_system/components/chips.dart';
import 'package:ibnzaidon/design_system/components/course_card.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/section_header.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/teachers/domain/entities/teacher_detail.dart';
import 'package:ibnzaidon/features/teachers/presentation/bloc/teachers_bloc.dart';
import 'package:ibnzaidon/shared/presentation/failure_view.dart';
import 'package:ibnzaidon/shared/presentation/widgets/course_card_view.dart';

class TeacherPage extends StatelessWidget {
  const TeacherPage({required this.teacherId, super.key});

  final int teacherId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<TeacherDetailBloc>(param1: teacherId)
            ..add(const ResourceRequested()),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocBuilder<TeacherDetailBloc, ResourceState<TeacherDetail>>(
          builder: (context, state) {
            if (state.isLoading) return const _Skeleton();
            final detail = state.data;
            if (detail == null) {
              return FailureView(
                failure: state.failure!,
                onRetry: () => context.read<TeacherDetailBloc>().add(
                  const ResourceRequested(),
                ),
              );
            }
            return ContentConstraint(child: _Profile(detail: detail));
          },
        ),
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.detail});

  final TeacherDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final teacher = detail.teacher;
    return ListView(
      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.lg),
      children: [
        Center(
          child: Hero(
            tag: teacherHeroTag(teacher.id),
            child: AppNetworkImage(
              url: teacher.avatar,
              width: AppSizes.avatarXl,
              height: AppSizes.avatarXl,
              circle: true,
              placeholderIcon: Icons.person_rounded,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                teacher.name,
                textAlign: TextAlign.center,
                style: context.text.headlineSmall,
              ),
            ),
            if (teacher.isVerified) ...[
              const SizedBox(width: AppSpacing.xs),
              Tooltip(
                message: l10n.teacherVerified,
                child: Icon(
                  Icons.verified_rounded,
                  color: context.colors.secondary,
                ),
              ),
            ],
          ],
        ),
        if (teacher.specialization != null)
          Text(
            teacher.specialization!,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: AppSpacing.pagePadding,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (teacher.averageRating > 0)
                RatingChip(rating: teacher.averageRating),
              StatChip(
                icon: Icons.people_alt_rounded,
                label: l10n.commonStudentsCount(
                  AppFormatters.compactNumber(teacher.totalStudents),
                ),
              ),
              StatChip(
                icon: Icons.menu_book_rounded,
                label: l10n.commonCoursesCount(teacher.totalCourses),
              ),
              if (teacher.yearsOfExperience > 0)
                StatChip(
                  icon: Icons.workspace_premium_rounded,
                  label: l10n.teacherExperience(teacher.yearsOfExperience),
                  tint: context.palette.warningContainer,
                  onTint: context.palette.onWarningContainer,
                ),
            ],
          ),
        ),
        if (detail.qualification != null)
          _InfoBlock(
            title: l10n.teacherQualification,
            body: detail.qualification!,
          ),
        if (detail.bio != null)
          _InfoBlock(title: l10n.teacherAbout, body: detail.bio!),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(title: l10n.teacherCoursesTitle),
        if (detail.courses.isEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
            child: Text(l10n.teacherNoCourses, style: context.text.bodyMedium),
          )
        else
          for (var i = 0; i < detail.courses.length; i++)
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.gutter,
                vertical: AppSpacing.xs,
              ),
              child: Staggered(
                index: i,
                child: CourseCardView(
                  course: detail.courses[i],
                  variant: CourseCardVariant.horizontal,
                  enableHero: true,
                ),
              ),
            ),
      ],
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.gutter,
        AppSpacing.xl,
        AppSpacing.gutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(body, style: context.text.bodyMedium),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) => const SkeletonShimmer(
    child: Padding(
      padding: EdgeInsetsDirectional.all(AppSpacing.gutter),
      child: Column(
        children: [
          SkeletonBox(
            width: AppSizes.avatarXl,
            height: AppSizes.avatarXl,
            circle: true,
          ),
          SizedBox(height: AppSpacing.lg),
          SkeletonBox(width: 180, height: 24),
          SizedBox(height: AppSpacing.lg),
          SkeletonBox(height: 96, radius: AppRadii.card),
        ],
      ),
    ),
  );
}
