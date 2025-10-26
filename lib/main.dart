import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// --- ¡AQUÍ ESTÁ LA CORRECCIÓN! ---
import 'package:flutter_native_timezone_updated/flutter_native_timezone.dart'; // <-- USANDO EL PAQUETE CORRECTO
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'home_screen.dart';
import 'theme_provider.dart';

// --- Colores Institucionales ---
const Color colorGuinda = Color(0xFF8A0002);
const Color colorAzul = Color(0xFF004A99);

// --- Instancia de Notificaciones ---
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración de Zona Horaria (con el paquete correcto)
  await _configureLocalTimezone();

  // Inicializar Notificaciones
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Lógica del Provider de Tema
  final themeProvider = ThemeProvider();
  await themeProvider.setTheme(themeProvider.themeMode);

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: const MyApp(),
    ),
  );
}

// Esta función usa el paquete 'flutter_native_timezone_updated'
Future<void> _configureLocalTimezone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // El resto de la app (Consumer, MaterialApp, Temas)
    // se queda exactamente igual.
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Kit de Herramientas',
          debugShowCheckedModeBanner: false,
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
          themeMode: themeProvider.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}