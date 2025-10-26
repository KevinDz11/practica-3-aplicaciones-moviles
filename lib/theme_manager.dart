import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static final ValueNotifier<ThemeData> themeNotifier = ValueNotifier(lightTheme);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF8B0000), // Guinda
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF8B0000),
      secondary: Color(0xFF1E3A8A), // Azul
      background: Colors.white,
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: const Color(0xFF660000), // Guinda oscuro
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF660000),
      secondary: Color(0xFF1E40AF), // Azul oscuro
      background: Color(0xFF121212),
    ),
    useMaterial3: true,
  );

  static final ThemeData guindaAzulTheme = ThemeData(
    primaryColor: const Color(0xFF8B0000), // Guinda
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF8B0000),
      secondary: Color(0xFF1E3A8A), // Azul
      background: Colors.white,
    ),
    useMaterial3: true,
  );

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme') ?? 0;
    _setTheme(themeIndex);
  }

  static void _setTheme(int index) {
    switch (index) {
      case 0:
        themeNotifier.value = lightTheme;
        break;
      case 1:
        themeNotifier.value = darkTheme;
        break;
      case 2:
        themeNotifier.value = guindaAzulTheme;
        break;
    }
    _saveTheme(index);
  }

  static Future<void> _saveTheme(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme', index);
  }

  static void changeTheme(int index) {
    _setTheme(index);
  }
}