import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Keys
const _themeKey = 'theme_mode';

/// Read saved theme from SharedPreferences
Future<ThemeMode> getSavedTheme() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(_themeKey) ?? 'light';

    switch (themeStr) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  } catch (e) {
    debugPrint(e.toString());
    return ThemeMode.system;
  }
}

/// Save selected theme
Future<void> saveTheme(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  final themeStr = mode.name; // gives 'light', 'dark', or 'system'
  await prefs.setString(_themeKey, themeStr);
}

/// Provider to load theme on startup
final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((
  ref,
) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final mode = await getSavedTheme();
    state = mode;
  }

  void toggleTheme(bool isDark) {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    saveTheme(newMode);
  }
}
