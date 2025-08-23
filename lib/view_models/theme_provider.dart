import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:peak_pass/data/services/storage_service_utils.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    // 1. 首先尝试或用户已经定义过的
    final strThemeMode = StorageServiceUtils.getThemeMode();
    if (strThemeMode != null &&
        (strThemeMode == 'dark' || strThemeMode == 'light')) {
      _themeMode = strThemeMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
      return;
    }

    // 2. 没有则使用系统默认值
    final brightness = PlatformDispatcher.instance.platformBrightness;
    _themeMode = brightness.name == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDark => _themeMode.name == 'dark';

  bool isSettingsPage = false;

  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    StorageServiceUtils.setThemeMode(mode.name);
    notifyListeners();
  }

  void setTheme(bool isDark) {
    isSettingsPage = true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    StorageServiceUtils.setThemeMode(_themeMode.name);
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode.name == 'dark' ? ThemeMode.light : ThemeMode.dark;
    StorageServiceUtils.setThemeMode(_themeMode.name);
    notifyListeners();
  }
}
