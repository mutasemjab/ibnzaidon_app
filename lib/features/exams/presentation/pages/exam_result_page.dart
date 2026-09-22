import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/services/haptics.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/app_card.dart';
import 'package:ibnzaidon/design_system/components/chips.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/score_gauge.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/exams/domain/entities/exam_entities.dart';
import 'package:ibnzaidon/features/exams/presentation/widgets/exam_cards.dart';
import 'package:share_plus/share_plus.dart';

class ExamResultArgs {
  const ExamResultArgs({required this.result, required this.exam});

  final ExamResult result;
  final Exam exam;
}

class ExamResultPage extends StatefulWidget {
  const ExamResultPage({required this.args, super.key});

  final ExamResultArgs args;

  @override
  State<ExamResultPage> createState() => _ExamResultPageState();
}

class _ExamResultPageState extends State<ExamResultPage> {
  final _confetti = ConfettiController(duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    if (widget.args.result.isPassed) {
      Haptics.success();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !context.reduceMotion) _confetti.play();
      });
    } else {
      Haptics.light();
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final result = widget.args.result;
    final exam = widget.args.exam;
    final palette = context.palette;
    final color = result.isPassed ? palette.success : context.colors.error;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.examResultTitle),
          automaticallyImplyLeading: false,
          leading: CloseButton(onPressed: () => context.go(AppRoutes.home)),
          actions: [
            IconButton(
              tooltip: l10n.examShareResult,
              icon: const Icon(Icons.ios_share_rounded),
              onPressed: () => SharePlus.instance.share(
                ShareParams(
                  text: l10n.examShareText(
                    AppFormatters.percent(result.percentage),
                    exam.title,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            ContentConstraint(
              child: ListView(
                padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
                children: [
                  Center(
                    child: ScoreGauge(
                      fraction: result.percentage,
                      isPassed: result.isPassed,
                      caption: l10n.examScoreOf(
                        formatMarks(result.score),
                        formatMarks(result.totalMarks),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    result.isPassed ? l10n.examPassed : l10n.examFailed,
                    textAlign: TextAlign.center,
                    style: context.text.headlineMedium?.copyWith(color: color),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    result.isPassed ? l10n.examCongrats : l10n.examKeepGoing,
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _Stats(result: result),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: StatChip(
                      icon: Icons.timer_outlined,
                      label: l10n.examTimeTaken(
                        result.timeTakenMinutes.toStringAsFixed(
                          result.timeTakenMinutes % 1 == 0 ? 0 : 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: l10n.examTryAgain,
                    icon: Icons.refresh_rounded,
                    onPressed: () =>
                        context.pushReplacement(AppRoutes.exam(exam.id)),
                  ),
                  if (result.reviews != null && result.reviews!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    Text(l10n.examReviewTitle, style: context.text.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    for (var i = 0; i < result.reviews!.length; i++)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          bottom: AppSpacing.md,
                        ),
                        child: Staggered(
                          index: i,
                          child: _ReviewCard(
                            number: i + 1,
                            review: result.reviews![i],
                            exam: exam,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            if (result.isPassed)
              ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                emissionFrequency: 0.05,
                numberOfParticles: 24,
                colors: [
                  context.colors.primary,
                  context.colors.tertiary,
                  palette.success,
                  context.colors.secondary,
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.result});

  final ExamResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final scheme = context.colors;
    Widget cell(String label, int value, Color tint, Color onTint) => Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tint,
          borderRadius: AppRadii.cardRadius,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: AppSpacing.lg,
          ),
          child: Column(
            children: [
              Text(
                '$value',
                style: context.text.headlineSmall?.copyWith(color: onTint),
              ),
              Text(
                label,
                style: context.text.labelMedium?.copyWith(color: onTint),
              ),
            ],
          ),
        ),
      ),
    );
    return Row(
      children: [
        cell(
          l10n.examStatCorrect,
          result.correctAnswers,
          palette.successContainer,
          palette.onSuccessContainer,
        ),
        const SizedBox(width: AppSpacing.md),
        cell(
          l10n.examStatWrong,
          result.wrongAnswers,
          scheme.errorContainer,
          scheme.onErrorContainer,
        ),
        const SizedBox(width: AppSpacing.md),
        cell(
          l10n.examStatUnanswered,
          result.unanswered,
          scheme.surfaceContainerHigh,
          scheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.number,
    required this.review,
    required this.exam,
  });

  final int number;
  final AnswerReview review;
  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final color = review.isCorrect ? palette.success : context.colors.error;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                review.isCorrect
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: color,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '$number. ${review.questionText}',
                  style: context.text.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (review.selectedOptionId == null)
            Text(
              l10n.examNotAnswered,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          if (!review.isCorrect && review.correctOption != null)
            Text(
              '${l10n.examCorrectAnswer}: ${review.correctOption}',
              style: context.text.bodyMedium?.copyWith(color: palette.success),
            ),
          if (review.explanation != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.examExplanation, style: context.text.labelLarge),
            Text(review.explanation!, style: context.text.bodyMedium),
          ],
        ],
      ),
    );
  }
}
