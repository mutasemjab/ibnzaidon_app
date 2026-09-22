import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/services/haptics.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_network_image.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/exams/domain/entities/exam_entities.dart';
import 'package:ibnzaidon/features/exams/presentation/widgets/exam_cards.dart';

/// One question with selectable options. Purely presentational.
class ExamQuestionView extends StatelessWidget {
  const ExamQuestionView({
    required this.question,
    required this.index,
    required this.total,
    required this.selectedOptionId,
    required this.isFlagged,
    required this.onSelect,
    required this.onClear,
    required this.onToggleFlag,
    super.key,
  });

  final Question question;
  final int index;
  final int total;
  final int? selectedOptionId;
  final bool isFlagged;
  final ValueChanged<int> onSelect;
  final VoidCallback onClear;
  final VoidCallback onToggleFlag;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colors;
    return ListView(
      padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
      children: [
        Row(
          children: [
            Text(
              l10n.examQuestionOf(index + 1, total),
              style: context.text.labelLarge?.copyWith(color: scheme.primary),
            ),
            const Spacer(),
            if (question.marks > 0)
              Text(
                l10n.examMarksLabel(formatMarks(question.marks)),
                style: context.text.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            IconButton(
              tooltip: isFlagged ? l10n.examUnflag : l10n.examFlag,
              onPressed: onToggleFlag,
              icon: Icon(
                isFlagged ? Icons.flag_rounded : Icons.outlined_flag_rounded,
                color: isFlagged ? context.colors.tertiary : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(question.text, style: context.text.titleMedium),
        if (question.imageUrl != null) ...[
          const SizedBox(height: AppSpacing.md),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: AppNetworkImage(
              url: question.imageUrl,
              fit: BoxFit.contain,
              borderRadius: AppRadii.fieldRadius,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        for (final option in question.options)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
            child: _OptionTile(
              text: option.text,
              selected: option.id == selectedOptionId,
              onTap: () {
                Haptics.tap();
                onSelect(option.id);
              },
            ),
          ),
        if (selectedOptionId != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.backspace_outlined, size: AppSizes.iconMd),
              label: Text(l10n.examClearAnswer),
            ),
          ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      button: true,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        decoration: BoxDecoration(
          color: selected
              ? scheme.primaryContainer
              : scheme.surfaceContainerLow,
          borderRadius: AppRadii.fieldRadius,
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: AppRadii.fieldRadius,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSizes.touchTarget,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: selected ? scheme.primary : scheme.outline,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(text, style: context.text.bodyLarge)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
