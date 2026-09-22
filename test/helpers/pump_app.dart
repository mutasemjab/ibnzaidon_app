import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ibnzaidon/core/l10n/generated/app_localizations.dart';
import 'package:ibnzaidon/design_system/components/price_view.dart';
import 'package:ibnzaidon/design_system/theme/app_theme.dart';

/// Pumps [child] inside the real theme + localizations. Fonts are not
/// fetched from the network in tests.
Widget testApp(
  Widget child, {
  Locale locale = const Locale('ar'),
  Brightness brightness = Brightness.light,
  bool showPrice = true,
}) {
  final language = locale.languageCode;
  return BlocProvider<PriceVisibilityCubit>(
    create: (_) => PriceVisibilityCubit(initiallyVisible: showPrice),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(language, useGoogleFonts: false),
      darkTheme: AppTheme.dark(language, useGoogleFonts: false),
      themeMode: brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget child, {
    Locale locale = const Locale('ar'),
    Brightness brightness = Brightness.light,
    bool showPrice = true,
  }) => pumpWidget(
    testApp(
      child,
      locale: locale,
      brightness: brightness,
      showPrice: showPrice,
    ),
  );
}
