import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themePrefsKey = 'selectedThemeMode';

// Enum for theme modes
enum AppThemeMode { light, dark, system }

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  final SharedPreferences _prefs;

  Future<void> _loadThemeMode() async {
    final themeString = _prefs.getString(_themePrefsKey);
    if (themeString == null) {
      state = ThemeMode.system; // Default to system
      return;
    }
    switch (themeString) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'system':
      default:
        state = ThemeMode.system;
        break;
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    switch (mode) {
      case AppThemeMode.light:
        state = ThemeMode.light;
        await _prefs.setString(_themePrefsKey, 'light');
        break;
      case AppThemeMode.dark:
        state = ThemeMode.dark;
        await _prefs.setString(_themePrefsKey, 'dark');
        break;
      case AppThemeMode.system:
        state = ThemeMode.system;
        await _prefs.setString(_themePrefsKey, 'system');
        break;
    }
  }

  // Helper to get the current AppThemeMode for UI display (e.g., in settings)
  AppThemeMode get currentAppThemeMode {
    switch (state) {
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
      case ThemeMode.system:
      default:
        return AppThemeMode.system;
    }
  }
}

// Provider for SharedPreferences (can be initialized in main)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // This will throw if SharedPreferences isn't initialized before being read.
  // Ensure it's initialized in main.dart
  throw UnimplementedError('SharedPreferences provider not initialized');
});

// The main theme notifier provider
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});
