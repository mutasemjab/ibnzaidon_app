import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

/// Animated circular progress with a percentage label. [progress] is 0..1.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.progress,
    this.size = AppSizes.ringSize,
    this.strokeWidth = AppSizes.ringStroke,
    this.color,
    this.showLabel = true,
    super.key,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final Color? color;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final target = progress.clamp(0.0, 1.0);
    final ringColor = color ?? context.colors.primary;
    return Semantics(
      value: AppFormatters.percent(target),
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: target),
        duration: context.reduceMotion ? Duration.zero : AppMotion.slow,
        curve: AppMotion.emphasizedDecelerate,
        builder: (context, value, _) => SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _RingPainter(
              progress: value,
              strokeWidth: strokeWidth,
              color: ringColor,
              trackColor: context.colors.surfaceContainerHigh,
              isRtl: context.isRtl,
            ),
            child: showLabel
                ? Center(
                    child: Text(
                      AppFormatters.percent(value),
                      style: context.text.labelSmall,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
    required this.isRtl,
  });

  final double progress;
  final double strokeWidth;
  final Color color;
  final Color trackColor;
  final bool isRtl;

  @override
  void paint(Canvas canvas, Size size) {
    final rect =
        Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    final sweep = math.pi * 2 * progress * (isRtl ? -1 : 1);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.isRtl != isRtl;
}
