import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/l10n/generated/app_localizations.dart';

extension AppContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
  String get languageCode => Localizations.localeOf(this).languageCode;
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
}
