import 'package:flutter/material.dart';

/// 4-pt spacing scale.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double giant = 48;
  static const double massive = 64;

  /// Horizontal page gutter.
  static const double gutter = 16;

  static const EdgeInsetsDirectional pagePadding =
      EdgeInsetsDirectional.symmetric(horizontal: gutter);
}

abstract final class AppRadii {
  static const double small = 8;
  static const double chip = 10;
  static const double field = 14;
  static const double button = 16;
  static const double card = 20;
  static const double sheet = 28;
  static const double pill = 999;

  static const BorderRadius chipRadius = BorderRadius.all(
    Radius.circular(chip),
  );
  static const BorderRadius fieldRadius = BorderRadius.all(
    Radius.circular(field),
  );
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius pillRadius = BorderRadius.all(
    Radius.circular(pill),
  );
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}

abstract final class AppSizes {
  static const double touchTarget = 48;
  static const double buttonHeight = 52;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double icon = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;
  static const double avatarSm = 32;
  static const double avatarMd = 44;
  static const double avatarLg = 72;
  static const double avatarXl = 96;
  static const double bottomNavHeight = 68;
  static const double courseCardWidth = 264;
  static const double courseCardCompactWidth = 168;
  static const double teacherCardWidth = 120;
  static const double categoryCardWidth = 96;
  static const double bannerHeight = 168;
  static const double heroExpandedHeight = 260;
  static const double thumbnailCompact = 88;
  static const double maxContentWidth = 720;
  static const double gridTabletMinWidth = 600;
  static const double gaugeSize = 200;
  static const double gaugeStroke = 14;
  static const double ringSize = 56;
  static const double ringStroke = 6;
  static const double indicatorHeight = 4;
  static const double dragHandleWidth = 40;
  static const double illustration = 128;
  static const double logo = 96;
}

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
  static const stagger = Duration(milliseconds: 60);

  /// Material 3 "emphasized decelerate".
  static const emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1);
  static const Curve standard = Curves.easeOutCubic;
}

abstract final class AppShadows {
  /// Soft, layered, low-opacity shadows. Dark mode relies on surface tone
  /// instead of shadow.
  static List<BoxShadow> soft(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) return const [];
    final color = Theme.of(context).colorScheme.shadow;
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.05),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.06),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> raised(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) return const [];
    final color = Theme.of(context).colorScheme.shadow;
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.10),
        blurRadius: 36,
        offset: const Offset(0, 16),
      ),
    ];
  }
}
