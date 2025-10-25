import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'home_screen.dart'; // Crearemos esta pantalla a continuación

// --- Colores Institucionales ---
const Color colorGuinda = Color(0xFF8A0002);
const Color colorAzul = Color(0xFF004A99);

// --- Instancia de Notificaciones ---
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  // Asegura que los bindings estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // --- Inicializar Notificaciones ---
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher'); // Tu ícono de app

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kit de Herramientas',
      debugShowCheckedModeBanner: false,

      // --- Tema Claro ---
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: colorGuinda,
        colorScheme: ColorScheme.light(
          primary: colorGuinda,
          secondary: colorAzul,
          background: Colors.grey[100]!,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: colorGuinda,
          foregroundColor: Colors.white,
        ),
      ),

      // --- Tema Oscuro ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: colorGuinda,
        colorScheme: ColorScheme.dark(
          primary: colorGuinda,
          secondary: colorAzul,
          background: Colors.grey[900]!,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: colorGuinda,
          foregroundColor: Colors.white,
        ),
      ),

      // --- Usa el modo del sistema ---
      themeMode: ThemeMode.system,

      home: const HomeScreen(),
    );
  }
}