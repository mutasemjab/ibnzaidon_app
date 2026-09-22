import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

/// Animated 270° gauge for exam scores. [fraction] is 0..1.
class ScoreGauge extends StatelessWidget {
  const ScoreGauge({
    required this.fraction,
    required this.isPassed,
    this.caption,
    this.size = AppSizes.gaugeSize,
    super.key,
  });

  final double fraction;
  final bool isPassed;
  final String? caption;
  final double size;

  @override
  Widget build(BuildContext context) {
    final target = fraction.clamp(0.0, 1.0);
    final color = isPassed ? context.palette.success : context.colors.error;
    return Semantics(
      value: AppFormatters.percent(target),
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: target),
        duration: context.reduceMotion ? Duration.zero : AppMotion.slow * 3,
        curve: AppMotion.emphasizedDecelerate,
        builder: (context, value, _) => SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _GaugePainter(
              progress: value,
              color: color,
              trackColor: context.colors.surfaceContainerHigh,
              strokeWidth: AppSizes.gaugeStroke,
              isRtl: context.isRtl,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppFormatters.percent(value),
                    style: context.text.displaySmall?.copyWith(color: color),
                  ),
                  if (caption != null)
                    Text(
                      caption!,
                      style: context.text.labelLarge?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
    required this.isRtl,
  });

  static const double _startAngle = math.pi * 0.75;
  static const double _sweepAngle = math.pi * 1.5;

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;
  final bool isRtl;

  @override
  void paint(Canvas canvas, Size size) {
    final rect =
        Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);
    Paint stroke(Color c) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = c;
    canvas.drawArc(rect, _startAngle, _sweepAngle, false, stroke(trackColor));
    if (progress <= 0) return;
    if (isRtl) {
      const start = _startAngle + _sweepAngle;
      canvas.drawArc(
        rect,
        start,
        -_sweepAngle * progress,
        false,
        stroke(color),
      );
    } else {
      canvas.drawArc(
        rect,
        _startAngle,
        _sweepAngle * progress,
        false,
        stroke(color),
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.progress != progress || old.color != color || old.isRtl != isRtl;
}
