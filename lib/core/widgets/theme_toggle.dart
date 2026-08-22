import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:qde_eco_bahor/core/di/injection_container.dart';
import 'package:qde_eco_bahor/core/services/theme_service.dart';

import '../../generated/locale_keys.g.dart';

class ThemeToggle extends StatefulWidget {
  const ThemeToggle({super.key});

  @override
  State<ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<ThemeToggle> {
  late ThemeService _themeService;
  ThemeMode _currentTheme = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _themeService = getIt<ThemeService>();
    _loadTheme();
    _themeService.themeModeStream.listen((mode) {
      if (mounted) {
        setState(() {
          _currentTheme = mode;
        });
      }
    });
  }

  Future<void> _loadTheme() async {
    final mode = await _themeService.getThemeMode();
    if (mounted) {
      setState(() {
        _currentTheme = mode;
      });
    }
  }

  Future<void> _toggleTheme() async {
    ThemeMode newMode;
    switch (_currentTheme) {
      case ThemeMode.light:
        newMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newMode = ThemeMode.system;
        break;
      case ThemeMode.system:
        newMode = ThemeMode.light;
        break;
    }
    await _themeService.setThemeMode(newMode);
  }

  IconData _getThemeIcon() {
    switch (_currentTheme) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_getThemeIcon()),
      tooltip: LocaleKeys.theme_toggle.tr(),
      onPressed: _toggleTheme,
    );
  }
}
