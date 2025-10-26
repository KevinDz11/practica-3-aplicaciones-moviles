import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  // El Notifier ahora guarda el nombre del tema base: 'guinda' o 'azul'
  static final ValueNotifier<String> themeNotifier = ValueNotifier('guinda');

  // --- Tema Guinda ---
  static final ThemeData guindaLightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF8B0000), // Guinda
      secondary: Color(0xFF1E3A8A), // Azul
      background: Colors.white,
    ),
  );

  static final ThemeData guindaDarkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFB71C1C), // Un guinda más brillante para modo oscuro
      secondary: Color(0xFF3B5998), // Un azul más brillante
      background: Color(0xFF121212),
    ),
  );

  // --- Tema Azul ---
  static final ThemeData azulLightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1E3A8A), // Azul
      secondary: Color(0xFF8B0000), // Guinda
      background: Colors.white,
    ),
  );

  static final ThemeData azulDarkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3B5998), // Azul más brillante
      secondary: Color(0xFFB71C1C), // Guinda más brillante
      background: Color(0xFF121212),
    ),
  );


  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    // Lee el nombre del tema, por defecto 'guinda'
    final themeName = prefs.getString('themeName') ?? 'guinda';
    themeNotifier.value = themeName;
  }

  static Future<void> changeTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeName', themeName);
    themeNotifier.value = themeName;
  }
}