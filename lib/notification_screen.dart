import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'main.dart'; // Importamos para acceder a `flutterLocalNotificationsPlugin`

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final int _notificationId = 1; // ID único para nuestra notificación

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    // Pedir permiso en Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _showNotification() async {
    final String title = _titleController.text;
    final String body = _bodyController.text;

    if (title.isEmpty || body.isEmpty) {
      _showErrorDialog('El título y el cuerpo no pueden estar vacíos.');
      return;
    }

    // Detalles de la notificación
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'canal_recordatorio', // id del canal
      'Recordatorios Rápidos', // nombre del canal
      channelDescription: 'Canal para recordatorios rápidos y persistentes',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',

      // --- Requisito: Hacerla Persistente ---
      // 'ongoing' la hace persistente (no se puede deslizar)
      ongoing: true,
      // 'autoCancel' en false también ayuda
      autoCancel: false,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    // Mostrar la notificación
    await flutterLocalNotificationsPlugin.show(
      _notificationId, // Usamos un ID fijo
      title,
      body,
      notificationDetails,
    );

    // Limpiar campos
    _titleController.clear();
    _bodyController.clear();

    // Opcional: mostrar un snackbar de confirmación
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recordatorio creado en la barra de notificaciones.')),
      );
    }
  }

  // Para cancelar la notificación persistente
  Future<void> _cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(_notificationId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recordatorio eliminado.')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorio Rápido'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Crea un recordatorio persistente en tu barra de notificaciones.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título del Recordatorio',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Cuerpo del Recordatorio',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.text_fields),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.send_rounded),
                label: const Text('Crear Recordatorio'),
                onPressed: _showNotification,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                icon: const Icon(Icons.cancel_rounded, color: Colors.red),
                label: const Text('Eliminar Recordatorio', style: TextStyle(color: Colors.red)),
                onPressed: _cancelNotification,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Campos incompletos'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}