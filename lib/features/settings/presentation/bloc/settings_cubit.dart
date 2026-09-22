import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/network/locale_code_provider.dart';
import 'package:ibnzaidon/core/storage/key_value_store.dart';

final class SettingsState extends Equatable {
  const SettingsState({
    this.locale = const Locale('ar'),
    this.themeMode = ThemeMode.system,
  });

  final Locale locale;
  final ThemeMode themeMode;

  SettingsState copyWith({Locale? locale, ThemeMode? themeMode}) =>
      SettingsState(
        locale: locale ?? this.locale,
        themeMode: themeMode ?? this.themeMode,
      );

  @override
  List<Object?> get props => [locale, themeMode];
}

/// Global language + theme. Persisted, applied instantly, and doubles as the
/// source of `Accept-Language` for the network layer.
class SettingsCubit extends Cubit<SettingsState> implements LocaleCodeProvider {
  SettingsCubit(this._store) : super(_read(_store));

  static const supportedLanguageCodes = ['ar', 'en'];
  static const _localeKey = 'settings.locale';
  static const _themeKey = 'settings.theme';

  final KeyValueStore _store;

  @override
  String get languageCode => state.locale.languageCode;

  static SettingsState _read(KeyValueStore store) {
    final code = store.getString(_localeKey);
    final theme = store.getString(_themeKey);
    return SettingsState(
      locale: Locale(supportedLanguageCodes.contains(code) ? code! : 'ar'),
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == theme,
        orElse: () => ThemeMode.system,
      ),
    );
  }

  Future<void> setLanguage(String languageCode) async {
    if (!supportedLanguageCodes.contains(languageCode) ||
        languageCode == state.locale.languageCode) {
      return;
    }
    await _store.setString(_localeKey, languageCode);
    emit(state.copyWith(locale: Locale(languageCode)));
    _languageChanges.add(languageCode);
  }

  final _languageChanges = StreamController<String>.broadcast();

  /// Fires after the locale (and therefore `Accept-Language`) has changed.
  Stream<String> get languageChanges => _languageChanges.stream;

  @override
  Future<void> close() async {
    await _languageChanges.close();
    return super.close();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == state.themeMode) return;
    await _store.setString(_themeKey, mode.name);
    emit(state.copyWith(themeMode: mode));
  }
}
