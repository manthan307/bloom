import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  ThemeMode get themeMode => state;

  void setThemeMode(ThemeMode mode) {
    state = mode; // update state
  }
}

// Riverpod provider for ThemeNotifier
final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
