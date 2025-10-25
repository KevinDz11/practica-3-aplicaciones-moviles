import 'package:flutter/material.dart';
import 'flashlight_screen.dart'; // Crearemos esto
import 'nfc_screen.dart';         // Crearemos esto
import 'notification_screen.dart'; // Crearemos esto

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kit de Herramientas Nativo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Botón para la Linterna
            _ToolButton(
              title: 'Linterna',
              icon: Icons.flashlight_on_rounded,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FlashlightScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // Botón para NFC
            _ToolButton(
              title: 'Lector NFC',
              icon: Icons.nfc_rounded,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NfcScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // Botón para Notificaciones
            _ToolButton(
              title: 'Recordatorio Rápido',
              icon: Icons.notification_add_rounded,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Widget genérico para los botones del menú
class _ToolButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const _ToolButton({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(title, style: const TextStyle(fontSize: 18)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.background,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}