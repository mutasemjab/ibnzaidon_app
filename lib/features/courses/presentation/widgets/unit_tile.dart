import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_card.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';

/// View-model row so the same tile renders both the public outline and the
/// lock-aware `units` response.
class LessonRowData {
  const LessonRowData({
    required this.id,
    required this.title,
    required this.type,
    required this.durationMinutes,
    required this.isFree,
    this.isLocked = false,
    this.isLockedBySequence = false,
    this.isCompleted = false,
  });

  final int id;
  final String title;
  final LessonType type;
  final int durationMinutes;
  final bool isFree;
  final bool isLocked;
  final bool isLockedBySequence;
  final bool isCompleted;
}

class ExamRowData {
  const ExamRowData({
    required this.id,
    required this.title,
    required this.questions,
    required this.minutes,
  });

  final int id;
  final String title;
  final int questions;
  final int minutes;
}

class UnitTile extends StatelessWidget {
  const UnitTile({
    required this.title,
    required this.lessons,
    required this.exams,
    required this.onLessonTap,
    required this.onExamTap,
    this.initiallyExpanded = false,
    super.key,
  });

  final String title;
  final List<LessonRowData> lessons;
  final List<ExamRowData> exams;
  final ValueChanged<LessonRowData> onLessonTap;
  final ValueChanged<ExamRowData> onExamTap;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: context.theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text(title, style: context.text.titleSmall),
          subtitle: Text(
            context.l10n.commonLessonsCount(lessons.length),
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          children: [
            for (final lesson in lessons)
              _LessonRow(lesson: lesson, onTap: () => onLessonTap(lesson)),
            if (exams.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xs,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    context.l10n.courseUnitExamsTitle,
                    style: context.text.labelLarge?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            for (final exam in exams)
              _ExamRow(exam: exam, onTap: () => onExamTap(exam)),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.lesson, required this.onTap});

  final LessonRowData lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locked = lesson.isLocked || lesson.isLockedBySequence;
    final typeIcon = switch (lesson.type) {
      LessonType.video => Icons.play_circle_outline_rounded,
      LessonType.pdf => Icons.picture_as_pdf_outlined,
      LessonType.other => Icons.article_outlined,
    };
    final typeLabel = switch (lesson.type) {
      LessonType.video => l10n.lessonTypeVideo,
      LessonType.pdf => l10n.lessonTypePdf,
      LessonType.other => l10n.lessonTypeOther,
    };
    final muted = context.colors.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.touchTarget),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(typeIcon, color: locked ? muted : context.colors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium?.copyWith(
                        color: locked ? muted : null,
                      ),
                    ),
                    Text(
                      lesson.durationMinutes > 0
                          ? '$typeLabel · ${l10n.commonMinutes(lesson.durationMinutes)}'
                          : typeLabel,
                      style: context.text.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (lesson.isCompleted)
                Icon(Icons.check_circle_rounded, color: context.palette.success)
              else if (locked)
                Icon(
                  lesson.isLockedBySequence
                      ? Icons.lock_clock_rounded
                      : Icons.lock_rounded,
                  color: muted,
                  size: AppSizes.iconMd,
                )
              else if (lesson.isFree)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.palette.successContainer,
                    borderRadius: AppRadii.chipRadius,
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    child: Text(
                      l10n.lessonFree,
                      style: context.text.labelSmall?.copyWith(
                        color: context.palette.onSuccessContainer,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamRow extends StatelessWidget {
  const _ExamRow({required this.exam, required this.onTap});

  final ExamRowData exam;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.touchTarget),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(Icons.quiz_outlined, color: context.colors.tertiary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exam.title, style: context.text.bodyMedium),
                    Text(
                      context.l10n.courseExamMeta(exam.questions, exam.minutes),
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: AppSizes.iconSm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
