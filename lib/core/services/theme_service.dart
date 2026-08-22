import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Пример сервиса для управления темой приложения
abstract class ThemeService {
  Future<ThemeMode> getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);
  Stream<ThemeMode> get themeModeStream;
}

class ThemeServiceImpl implements ThemeService {
  final SharedPreferences _prefs;
  static const String _themeKey = 'theme_mode';
  final _themeModeController = StreamController<ThemeMode>.broadcast();

  ThemeServiceImpl(this._prefs) {
    // Инициализация потока
    getThemeMode().then((mode) => _themeModeController.add(mode));
  }

  @override
  Future<ThemeMode> getThemeMode() async {
    final themeString = _prefs.getString(_themeKey);
    if (themeString == null) {
      return ThemeMode.system;
    }
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    String themeString;
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }
    await _prefs.setString(_themeKey, themeString);
    _themeModeController.add(mode);
  }

  @override
  Stream<ThemeMode> get themeModeStream => _themeModeController.stream;
}

