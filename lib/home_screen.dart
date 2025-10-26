import 'package:flutter/material.dart';
import 'recordatorios_screen.dart';
import 'linterna_screen.dart';
import 'contador_pasos_screen.dart';
import 'theme_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) {
              ThemeManager.changeTheme(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.light_mode, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('Modo Claro'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.dark_mode, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Modo Oscuro'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.school, color: Color(0xFF8B0000)),
                    SizedBox(width: 8),
                    Text('Tema Guinda/Azul'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.palette),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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