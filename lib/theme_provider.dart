import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Esta clase "notificará" a la app cuando el tema cambie.
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final String _themeKey = 'theme_mode';

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme(); // Cargar el tema guardado cuando la app inicia
  }

  // Cargar el tema desde la persistencia
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final int themeIndex = prefs.getInt(_themeKey) ?? 0; // 0 = system
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  // Guardar el tema seleccionado y notificar a la app
  Future<void> setTheme(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners(); // Avisa a los "oyentes" (la app) que cambien el tema

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_themeKey, themeMode.index); // Guarda el índice (0, 1, o 2)
  }
}