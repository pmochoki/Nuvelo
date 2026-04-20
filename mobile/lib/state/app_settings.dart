import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

/// App-wide language + theme (SharedPreferences).
class AppSettingsController extends ChangeNotifier {
  AppSettingsController();

  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final lang = p.getString(kPrefsLang);
    if (lang == 'hu') {
      _locale = const Locale('hu');
    } else if (lang == 'en') {
      _locale = const Locale('en');
    } else {
      final device = WidgetsBinding.instance.platformDispatcher.locale;
      _locale = device.languageCode.toLowerCase().startsWith('hu')
          ? const Locale('hu')
          : const Locale('en');
    }

    final tm = p.getString(kPrefsThemeMode);
    _themeMode = switch (tm) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final p = await SharedPreferences.getInstance();
    await p.setString(kPrefsLang, locale.languageCode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final p = await SharedPreferences.getInstance();
    await p.setString(
      kPrefsThemeMode,
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
    );
    notifyListeners();
  }
}
