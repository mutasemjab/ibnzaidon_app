import 'package:flutter/material.dart';
import 'package:ibnzaidon/design_system/tokens/app_colors.dart';

/// Semantic colors that Material's [ColorScheme] has no slot for.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.heroGradient,
    required this.scrimGradient,
    required this.subjectTints,
    required this.imageDimming,
  });

  static const light = AppPalette(
    success: Color(0xFF1E8A3A),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFDDF4E3),
    onSuccessContainer: Color(0xFF0B4A1D),
    warning: AppColors.highlight,
    warningContainer: Color(0xFFFFEBC7),
    onWarningContainer: Color(0xFF4A2E00),
    heroGradient: AppColors.signatureGradient,
    scrimGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x00000000), Color(0xB3000000)],
    ),
    subjectTints: _lightTints,
    imageDimming: 0,
  );

  static const dark = AppPalette(
    success: Color(0xFF5CD07A),
    onSuccess: Color(0xFF053014),
    successContainer: Color(0xFF14512A),
    onSuccessContainer: Color(0xFFDDF4E3),
    warning: Color(0xFFF5B84D),
    warningContainer: Color(0xFF6B4300),
    onWarningContainer: Color(0xFFFFEBC7),
    heroGradient: LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: [Color(0xFF0F2E6E), Color(0xFF1A4AB0)],
    ),
    scrimGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x00000000), Color(0xCC000000)],
    ),
    subjectTints: _darkTints,
    imageDimming: 0.12,
  );

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;
  final LinearGradient heroGradient;
  final LinearGradient scrimGradient;
  final List<SubjectTint> subjectTints;

  /// Extra black overlay applied on images in dark mode.
  final double imageDimming;

  /// Maps the API's `color_class` (e.g. `primary`, `success`, `warning`) to a
  /// stable tint. Unknown values hash to a palette entry so a subject always
  /// gets the same color.
  SubjectTint tintFor(String? colorClass) {
    final key = (colorClass ?? '').toLowerCase();
    final index = switch (key) {
      final k when k.contains('primary') || k.contains('blue') => 0,
      final k when k.contains('success') || k.contains('green') => 1,
      final k when k.contains('warning') || k.contains('orange') => 2,
      final k when k.contains('danger') || k.contains('red') => 3,
      final k when k.contains('info') || k.contains('teal') => 4,
      final k when k.contains('purple') || k.contains('violet') => 5,
      _ => key.isEmpty ? 0 : key.codeUnits.fold<int>(0, (a, b) => a + b),
    };
    return subjectTints[index % subjectTints.length];
  }

  @override
  AppPalette copyWith({Color? success}) => AppPalette(
    success: success ?? this.success,
    onSuccess: onSuccess,
    successContainer: successContainer,
    onSuccessContainer: onSuccessContainer,
    warning: warning,
    warningContainer: warningContainer,
    onWarningContainer: onWarningContainer,
    heroGradient: heroGradient,
    scrimGradient: scrimGradient,
    subjectTints: subjectTints,
    imageDimming: imageDimming,
  );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) =>
      other is AppPalette ? (t < 0.5 ? this : other) : this;

  static const _lightTints = [
    SubjectTint(Color(0xFF0B3D91), Color(0xFFE3ECFC)),
    SubjectTint(Color(0xFF1E7A3A), Color(0xFFE0F4E6)),
    SubjectTint(Color(0xFF9A5B00), Color(0xFFFFEFD1)),
    SubjectTint(Color(0xFFB3261E), Color(0xFFFCE4E2)),
    SubjectTint(Color(0xFF00707D), Color(0xFFD9F3F6)),
    SubjectTint(Color(0xFF6A3FB5), Color(0xFFEDE4FA)),
  ];

  static const _darkTints = [
    SubjectTint(Color(0xFF9DB9F5), Color(0xFF16284D)),
    SubjectTint(Color(0xFF6FD98A), Color(0xFF12351F)),
    SubjectTint(Color(0xFFF5B84D), Color(0xFF3F2C0A)),
    SubjectTint(Color(0xFFF28B93), Color(0xFF45161B)),
    SubjectTint(Color(0xFF63D3E0), Color(0xFF0F3439)),
    SubjectTint(Color(0xFFC3A6F2), Color(0xFF2C1E4A)),
  ];
}

@immutable
class SubjectTint {
  const SubjectTint(this.foreground, this.background);

  final Color foreground;
  final Color background;
}

extension PaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
