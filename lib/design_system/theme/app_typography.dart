import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cairo for Arabic, Plus Jakarta Sans for Latin. Arabic needs taller line
/// heights (1.5-1.7) than Latin.
abstract final class AppTypography {
  static const _arabicHeight = 1.6;
  static const _latinHeight = 1.4;

  static TextTheme textTheme({
    required String languageCode,
    required Color color,
    bool useGoogleFonts = true,
  }) {
    final isArabic = languageCode == 'ar';
    final height = isArabic ? _arabicHeight : _latinHeight;
    TextStyle style(double size, FontWeight weight, {double? h}) => TextStyle(
      fontSize: size,
      fontWeight: weight,
      height: h ?? height,
      color: color,
      letterSpacing: isArabic ? 0 : -0.1,
    );

    final base = TextTheme(
      displayLarge: style(40, FontWeight.w800, h: 1.25),
      displayMedium: style(34, FontWeight.w800, h: 1.25),
      displaySmall: style(30, FontWeight.w700, h: 1.3),
      headlineLarge: style(28, FontWeight.w700),
      headlineMedium: style(24, FontWeight.w700),
      headlineSmall: style(20, FontWeight.w700),
      titleLarge: style(20, FontWeight.w700),
      titleMedium: style(16, FontWeight.w600),
      titleSmall: style(14, FontWeight.w600),
      bodyLarge: style(16, FontWeight.w400),
      bodyMedium: style(14, FontWeight.w400),
      bodySmall: style(12, FontWeight.w400),
      labelLarge: style(14, FontWeight.w600),
      labelMedium: style(12, FontWeight.w600),
      labelSmall: style(11, FontWeight.w600),
    );
    if (!useGoogleFonts) return base;
    return isArabic
        ? GoogleFonts.cairoTextTheme(base)
        : GoogleFonts.plusJakartaSansTextTheme(base);
  }
}
