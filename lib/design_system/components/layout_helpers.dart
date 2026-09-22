import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

/// Centers content and caps its width on tablets.
class ContentConstraint extends StatelessWidget {
  const ContentConstraint({
    required this.child,
    this.maxWidth = AppSizes.maxContentWidth,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    // Without `heightFactor`, Align expands to fill *all* height its parent
    // offers. That's invisible inside scrollable slivers (they hand down
    // unbounded height, so Align falls back to the child's size anyway),
    // but it silently ate the whole screen when this wrapped a
    // `bottomNavigationBar`: Scaffold gives that slot a bounded height, so
    // Align claimed nearly all of it and pushed the actual button to the
    // top of that claimed space — squeezing `body` to almost nothing above
    // it. Pinning height to the child's own size makes this safe in every
    // context that uses it.
    heightFactor: 1,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

extension ResponsiveContext on BuildContext {
  bool get isTablet => screenWidth >= AppSizes.gridTabletMinWidth;

  /// 2 columns on phones, 3 on tablets, 4 on large tablets.
  int get gridColumns => screenWidth >= AppSizes.maxContentWidth + 200
      ? 4
      : isTablet
      ? 3
      : 2;

  /// Horizontal padding that keeps content within [AppSizes.maxContentWidth].
  EdgeInsetsDirectional pageInsets({double top = 0, double bottom = 0}) {
    final side = math.max(
      AppSpacing.gutter,
      (screenWidth - AppSizes.maxContentWidth * 1.4) / 2,
    );
    return EdgeInsetsDirectional.fromSTEB(side, top, side, bottom);
  }
}

/// Staggered fade + rise entrance. Skips animation when the user asked to
/// reduce motion.
class Staggered extends StatelessWidget {
  const Staggered({required this.index, required this.child, super.key});

  static const _maxStaggeredItems = 8;

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return child;
    return child
        .animate(delay: AppMotion.stagger * math.min(index, _maxStaggeredItems))
        .fadeIn(duration: AppMotion.medium, curve: AppMotion.standard)
        .slideY(
          begin: 0.06,
          end: 0,
          duration: AppMotion.medium,
          curve: AppMotion.emphasizedDecelerate,
        );
  }
}

/// Brand-styled pull-to-refresh with a light haptic on trigger.
class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({
    required this.onRefresh,
    required this.child,
    super.key,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return RefreshIndicator(
      color: scheme.primary,
      backgroundColor: scheme.surfaceContainerLowest,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
