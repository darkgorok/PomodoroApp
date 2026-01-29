import 'package:flutter/material.dart';

import '../../core/storage/prefs.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  Future<void> init() async {
    final stored = Prefs.getThemeMode();
    _mode = _parse(stored) ?? ThemeMode.system;
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    await Prefs.setThemeMode(_serialize(mode));
    notifyListeners();
  }

  ThemeMode? _parse(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  String _serialize(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }
}
