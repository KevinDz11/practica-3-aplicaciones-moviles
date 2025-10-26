import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeManager.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha el ValueNotifier que ahora contiene 'guinda' o 'azul'
    return ValueListenableBuilder<String>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, themeName, child) {
        return MaterialApp(
          title: 'Recordatorios App',
          // Configura el modo automático
          themeMode: ThemeMode.system,

          // Asigna los temas claros y oscuros según el nombre
          theme: themeName == 'azul'
              ? ThemeManager.azulLightTheme
              : ThemeManager.guindaLightTheme,

          darkTheme: themeName == 'azul'
              ? ThemeManager.azulDarkTheme
              : ThemeManager.guindaDarkTheme,

          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}