import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/design_system/components/app_card.dart';
import 'package:ibnzaidon/design_system/components/chips.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/exams/domain/entities/exam_entities.dart';

String formatMarks(double marks) => marks == marks.roundToDouble()
    ? marks.round().toString()
    : marks.toStringAsFixed(1);

class ExamCard extends StatelessWidget {
  const ExamCard({required this.exam, super.key});

  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colors;
    final subtitle = [
      exam.course?.name,
      exam.subject?.name,
    ].whereType<String>().join(' · ');
    return AppCard(
      onTap: () => context.push(AppRoutes.exam(exam.id)),
      semanticLabel: exam.title,
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.palette.warningContainer,
              borderRadius: AppRadii.fieldRadius,
            ),
            child: SizedBox.square(
              dimension: AppSizes.avatarMd,
              child: Icon(
                Icons.quiz_rounded,
                color: context.palette.onWarningContainer,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall,
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    StatChip(
                      icon: Icons.help_outline_rounded,
                      label: l10n.commonQuestionsCount(exam.totalQuestions),
                    ),
                    if (exam.durationMinutes > 0)
                      StatChip(
                        icon: Icons.timer_outlined,
                        label: l10n.examDurationMinutes(exam.durationMinutes),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: AppSizes.iconSm),
        ],
      ),
    );
  }
}

class AttemptCard extends StatelessWidget {
  const AttemptCard({required this.attempt, super.key});

  final AttemptHistoryItem attempt;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final color = attempt.isPassed ? palette.success : context.colors.error;
    final date = attempt.submittedAt;
    return AppCard(
      onTap: () => context.push(AppRoutes.exam(attempt.examId)),
      semanticLabel: attempt.examTitle,
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Row(
        children: [
          SizedBox.square(
            dimension: AppSizes.ringSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: attempt.percentage,
                  color: color,
                  strokeWidth: AppSizes.ringStroke,
                ),
                Text(
                  AppFormatters.percent(attempt.percentage),
                  style: context.text.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attempt.examTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall,
                ),
                Text(
                  l10n.examScoreOf(
                    formatMarks(attempt.score),
                    formatMarks(attempt.totalMarks),
                  ),
                  style: context.text.bodySmall,
                ),
                if (date != null)
                  Text(
                    l10n.examAttemptDate(
                      AppFormatters.date(date, context.languageCode),
                    ),
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          StatChip(
            icon: attempt.isPassed
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            label: attempt.isPassed ? l10n.examPassed : l10n.examFailed,
            tint: attempt.isPassed
                ? palette.successContainer
                : context.colors.errorContainer,
            onTint: attempt.isPassed
                ? palette.onSuccessContainer
                : context.colors.onErrorContainer,
          ),
        ],
      ),
    );
  }
}
