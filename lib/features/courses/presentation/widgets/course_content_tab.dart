import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/overlays.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/course_detail_bloc.dart';
import 'package:ibnzaidon/features/courses/presentation/widgets/unit_tile.dart';

/// Units accordion. Uses the lock-aware `units` response when available and
/// falls back to the public outline (guests).
class CourseContentTab extends StatelessWidget {
  const CourseContentTab({required this.state, super.key});

  final CourseDetailState state;

  @override
  Widget build(BuildContext context) {
    final detail = state.detail!;
    final completed = state.progress?.completedLessonIds ?? const <int>{};
    final units = state.units?.units;
    final rows = <_UnitRows>[
      if (units != null)
        for (final unit in units)
          _UnitRows(
            unit.title,
            [
              for (final lesson in unit.lessons)
                LessonRowData(
                  id: lesson.id,
                  title: lesson.title,
                  type: lesson.type,
                  durationMinutes: lesson.durationMinutes,
                  isFree: lesson.isFree,
                  isLocked: lesson.isLocked,
                  isLockedBySequence: lesson.isLockedBySequence,
                  isCompleted: completed.contains(lesson.id),
                ),
            ],
            [
              for (final exam in unit.exams)
                ExamRowData(
                  id: exam.id,
                  title: exam.title,
                  questions: exam.totalQuestions,
                  minutes: exam.durationMinutes,
                ),
            ],
          )
      else
        for (final unit in detail.units)
          _UnitRows(
            unit.title,
            [
              for (final lesson in unit.lessons)
                LessonRowData(
                  id: lesson.id,
                  title: lesson.title,
                  type: lesson.type,
                  durationMinutes: lesson.durationMinutes,
                  isFree: lesson.isFree,
                  isLocked: !lesson.isFree,
                ),
            ],
            const [],
          ),
    ];
    if (rows.isEmpty) {
      return SizedBox(
        height: 260,
        child: EmptyState(message: context.l10n.courseNoContent),
      );
    }
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        children: [
          if (detail.sequential)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: AppSizes.iconMd,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      context.l10n.courseSequentialHint,
                      style: context.text.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          for (var i = 0; i < rows.length; i++)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
              child: UnitTile(
                title: rows[i].title,
                lessons: rows[i].lessons,
                exams: rows[i].exams,
                initiallyExpanded: i == 0,
                onLessonTap: (lesson) =>
                    _openLesson(context, detail.course.id, lesson),
                onExamTap: (exam) => context.push(AppRoutes.exam(exam.id)),
              ),
            ),
        ],
      ),
    );
  }

  void _openLesson(BuildContext context, int courseId, LessonRowData lesson) {
    if (lesson.isLocked || lesson.isLockedBySequence) {
      showLockedLessonSheet(context, bySequence: lesson.isLockedBySequence);
      return;
    }
    context.push(AppRoutes.lesson(courseId, lesson.id));
  }
}

class _UnitRows {
  const _UnitRows(this.title, this.lessons, this.exams);

  final String title;
  final List<LessonRowData> lessons;
  final List<ExamRowData> exams;
}

/// Explains *why* a lesson is locked (needs activation vs. previous lesson).
Future<void> showLockedLessonSheet(
  BuildContext context, {
  required bool bySequence,
}) {
  final l10n = context.l10n;
  return showAppBottomSheet<void>(
    context,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsetsDirectional.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const IllustrationBadge(
            icon: Icons.lock_rounded,
            tone: IllustrationTone.warning,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.lessonLockedTitle, style: context.text.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            bySequence ? l10n.lessonLockedSequence : l10n.lessonLockedEnroll,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    ),
  );
}
