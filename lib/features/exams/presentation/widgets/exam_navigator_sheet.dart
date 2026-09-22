import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/overlays.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/exams/presentation/bloc/exam_taking_bloc.dart';

/// Question navigator: answered / unanswered / flagged at a glance.
/// Resolves to the tapped question index.
Future<int?> showExamNavigatorSheet(
  BuildContext context, {
  required ExamTakingState state,
}) {
  return showAppBottomSheet<int>(
    context,
    title: context.l10n.examNavigator,
    builder: (_) => _NavigatorGrid(state: state),
  );
}

class _NavigatorGrid extends StatelessWidget {
  const _NavigatorGrid({required this.state});

  final ExamTakingState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colors;
    final palette = context.palette;
    final questions = state.questions;
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              _Legend(color: palette.success, label: l10n.examLegendAnswered),
              _Legend(color: scheme.outline, label: l10n.examLegendUnanswered),
              _Legend(color: scheme.tertiary, label: l10n.examLegendFlagged),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (var i = 0; i < questions.length; i++)
                _Cell(
                  number: i + 1,
                  answered: state.answers.containsKey(questions[i].id),
                  flagged: state.flagged.contains(questions[i].id),
                  current: i == state.currentIndex,
                  onTap: () => Navigator.of(context).pop(i),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: AppSpacing.md,
        height: AppSpacing.md,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: AppSpacing.xs),
      Text(label, style: context.text.labelMedium),
    ],
  );
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.number,
    required this.answered,
    required this.flagged,
    required this.current,
    required this.onTap,
  });

  final int number;
  final bool answered;
  final bool flagged;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final palette = context.palette;
    final background = flagged
        ? scheme.tertiaryContainer
        : answered
        ? palette.successContainer
        : scheme.surfaceContainerHigh;
    final foreground = flagged
        ? scheme.onTertiaryContainer
        : answered
        ? palette.onSuccessContainer
        : scheme.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: current,
      label: '$number',
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.fieldRadius,
        child: Container(
          width: AppSizes.touchTarget,
          height: AppSizes.touchTarget,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppRadii.fieldRadius,
            border: current
                ? Border.all(color: scheme.primary, width: 2)
                : null,
          ),
          child: Text(
            '$number',
            style: context.text.labelLarge?.copyWith(color: foreground),
          ),
        ),
      ),
    );
  }
}
