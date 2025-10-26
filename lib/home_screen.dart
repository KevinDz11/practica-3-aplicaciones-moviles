import 'package.flutter/material.dart';
import 'recordatorios_screen.dart';
import 'linterna_screen.dart';
import 'contador_pasos_screen.dart';
import 'theme_manager.dart';
import 'package:permission_handler/permission_handler.dart'; // Importar

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Lista de pantallas (se mantendrán vivas gracias a IndexedStack)
  final List<Widget> _screens = [
    RecordatoriosScreen(),
    LinternaScreen(),
    ContadorPasosScreen(),
  ];

  final List<String> _appBarTitles = [
    'Recordatorios',
    'Linterna',
    'Contador de Pasos',
  ];

  @override
  void initState() {
    super.initState();
    // 4. Pedir permisos cada vez que se inicie la app
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Pide los permisos estándar
    await [
      Permission.notification,
      Permission.camera,
      Permission.activityRecognition,
    ].request();

    // Pide el permiso especial de Alarma Exacta (crucial para recordatorios)
    var status = await Permission.scheduleExactAlarm.status;
    if (status.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    // Opcional: Mostrar un diálogo si los permisos de notificación siguen denegados
    if (await Permission.notification.isDenied ||
        await Permission.scheduleExactAlarm.isDenied) {
      if (mounted) {
        // Verifica que el widget esté en pantalla
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permisos Requeridos'),
            content: const Text(
                'Para que los recordatorios funcionen, por favor habilita los permisos de "Notificaciones" y "Alarmas y recordatorios" en la configuración de tu teléfono.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Menú para cambiar tema (actualizado)
          PopupMenuButton<String>(
            onSelected: (value) {
              ThemeManager.changeTheme(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'guinda', // Valor es el nombre del tema
                child: Row(
                  children: [
                    Icon(Icons.school, color: Color(0xFF8B0000)),
                    SizedBox(width: 8),
                    Text('Tema Guinda'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'azul', // Valor es el nombre del tema
                child: Row(
                  children: [
                    Icon(Icons.water_drop, color: Color(0xFF1E3A8A)),
                    SizedBox(width: 8),
                    Text('Tema Azul'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.palette),
          ),
        ],
      ),

      // 1. CAMBIO A INDEXEDSTACK
      // Esto mantiene el estado de todas las pantallas en la lista _screens.
      // Ya no se perderán los recordatorios al cambiar de pestaña.
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        // 2. CAMBIO DE COLOR DE ICONOS
        // Asigna explícitamente el color primario al item seleccionado
        selectedItemColor: Theme.of(context).colorScheme.primary,
        // Asigna un color neutral a los items no seleccionados
        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Recordatorios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flashlight_on),
            label: 'Linterna',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk),
            label: 'Pasos',
          ),
        ],
      ),
    );
  }
}