import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

/// Countdown pill that shifts calm -> warning -> danger as time runs out.
/// It never blocks the UI; it only pulses gently in the danger zone.
class ExamTimer extends StatelessWidget {
  const ExamTimer({required this.remaining, required this.total, super.key});

  static const warningFraction = 0.5;
  static const dangerFraction = 0.2;

  final Duration remaining;
  final Duration total;

  double get _fraction =>
      total.inSeconds == 0 ? 0 : remaining.inSeconds / total.inSeconds;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final palette = context.palette;
    final fraction = _fraction;
    final (background, foreground) = fraction > warningFraction
        ? (scheme.primaryContainer, scheme.onPrimaryContainer)
        : fraction > dangerFraction
        ? (palette.warningContainer, palette.onWarningContainer)
        : (scheme.errorContainer, scheme.onErrorContainer);
    final isDanger = fraction <= dangerFraction;

    final pill = AnimatedContainer(
      duration: AppMotion.medium,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: AppSizes.iconMd, color: foreground),
          const SizedBox(width: AppSpacing.xs),
          Text(
            AppFormatters.clock(remaining),
            style: context.text.titleSmall?.copyWith(
              color: foreground,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );

    return Semantics(
      liveRegion: false,
      label: context.l10n.examTimeRemaining(AppFormatters.clock(remaining)),
      excludeSemantics: true,
      child: isDanger && !context.reduceMotion
          ? pill
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.05, 1.05),
                  duration: AppMotion.slow * 2,
                )
          : pill,
    );
  }
}
