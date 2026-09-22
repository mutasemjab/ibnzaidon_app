import 'package:flutter/material.dart';

/// Brand colors taken from the Ibn Zaidon website.
abstract final class AppColors {
  static const primary = Color(0xFF0B3D91);
  static const primaryDark = Color(0xFF1A4AB0);
  static const accent = Color(0xFF1E6BD6);
  static const highlight = Color(0xFFF5A623);
  static const success = Color(0xFF28A745);
  static const danger = Color(0xFFDC3545);

  /// Foreground on gradient hero surfaces (identical in light and dark).
  static const onHero = Color(0xFFFFFFFF);

  /// 135° signature gradient. Directional so it mirrors in RTL.
  static const signatureGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [primary, primaryDark],
  );

  static const lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDCE6FB),
    onPrimaryContainer: Color(0xFF062A66),
    secondary: accent,
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD6E6FF),
    onSecondaryContainer: Color(0xFF0B3170),
    tertiary: highlight,
    onTertiary: Color(0xFF3A2500),
    tertiaryContainer: Color(0xFFFFEBC7),
    onTertiaryContainer: Color(0xFF4A2E00),
    error: Color(0xFFC62B3A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFDE3E6),
    onErrorContainer: Color(0xFF5C0A14),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF0F1A2E),
    onSurfaceVariant: Color(0xFF4A5568),
    outline: Color(0xFF7C879B),
    outlineVariant: Color(0xFFD5DBE7),
    shadow: Color(0xFF0B1F4D),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF1B2437),
    onInverseSurface: Color(0xFFF1F4FA),
    inversePrimary: Color(0xFFA9C2F5),
    surfaceTint: primary,
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF5F8FE),
    surfaceContainer: Color(0xFFEFF3FB),
    surfaceContainerHigh: Color(0xFFE8EDF7),
    surfaceContainerHighest: Color(0xFFE1E7F3),
  );

  static const darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF9DB9F5),
    onPrimary: Color(0xFF06214F),
    primaryContainer: primaryDark,
    onPrimaryContainer: Color(0xFFDCE6FB),
    secondary: Color(0xFF7FB0FF),
    onSecondary: Color(0xFF00295C),
    secondaryContainer: Color(0xFF1B4F9E),
    onSecondaryContainer: Color(0xFFD6E6FF),
    tertiary: Color(0xFFF5B84D),
    onTertiary: Color(0xFF3A2500),
    tertiaryContainer: Color(0xFF6B4300),
    onTertiaryContainer: Color(0xFFFFEBC7),
    error: Color(0xFFF28B93),
    onError: Color(0xFF4A0A12),
    errorContainer: Color(0xFF7A1B26),
    onErrorContainer: Color(0xFFFDE3E6),
    surface: Color(0xFF0B1220),
    onSurface: Color(0xFFE6ECF8),
    onSurfaceVariant: Color(0xFFB0BAD0),
    outline: Color(0xFF6F7A93),
    // Lighter than the old value: at the previous shade it nearly matched
    // the (now brighter) card fill below and the border disappeared.
    outlineVariant: Color(0xFF3E4E7C),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE6ECF8),
    onInverseSurface: Color(0xFF1B2437),
    inversePrimary: primary,
    surfaceTint: Color(0xFF9DB9F5),
    // `surfaceContainerLowest` is what AppCard, sheets, the bottom nav and
    // the selected segmented-control pill use as their "raised" fill (it
    // plays the role pure white plays in the light scheme, where it's the
    // brightest tone). The five container tones used to sit only 2-3%
    // lightness apart and — worse — `Lowest` was *darker* than `surface`,
    // so every card/chip/sheet nearly vanished into the black background.
    // Re-spaced here so each step is clearly perceptible and `Lowest` is
    // the brightest of the family, same as in light mode.
    surfaceContainerLowest: Color(0xFF2A3D68),
    surfaceContainerLow: Color(0xFF213254),
    surfaceContainer: Color(0xFF1B2748),
    surfaceContainerHigh: Color(0xFF16213C),
    surfaceContainerHighest: Color(0xFF0F1830),
  );
}
