import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

// La clase Reminder se queda igual
class Reminder {
  final int id;
  final String title;
  final String body;
  final DateTime dateTime;

  Reminder({
    required this.id,
    required this.title,
    required this.body,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'dateTime': dateTime.toIso8601String(),
  };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    id: json['id'],
    title: json['title'],
    body: json['body'],
    dateTime: DateTime.parse(json['dateTime']),
  );
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  DateTime? _selectedDateTime;
  List<Reminder> _reminders = [];
  final String _historyKey = 'reminder_history';

  // --- Todas las funciones de lógica (initState, loadHistory, saveHistory, etc.)
  // --- se quedan EXACTAMENTE IGUAL que en el código anterior.
  // --- (Las omito aquí por brevedad, pero están en el código final de abajo)
  // --- ...
  // --- ...

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _loadHistory();
  }

  Future<void> _requestNotificationPermission() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson = prefs.getStringList(_historyKey) ?? [];
    setState(() {
      _reminders = historyJson
          .map((jsonString) => Reminder.fromJson(jsonDecode(jsonString)))
          .toList();
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson =
    _reminders.map((reminder) => jsonEncode(reminder.toJson())).toList();
    await prefs.setStringList(_historyKey, historyJson);
  }

  Future<void> _selectDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(minutes: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 1))),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _scheduleNotification() async {
    final String title = _titleController.text;
    final String body = _bodyController.text;

    if (title.isEmpty || body.isEmpty) {
      _showErrorDialog('El título y el cuerpo son obligatorios.');
      return;
    }
    if (_selectedDateTime == null) {
      _showErrorDialog('Por favor, selecciona una fecha y hora.');
      return;
    }
    if (_selectedDateTime!.isBefore(DateTime.now())) {
      _showErrorDialog('La hora seleccionada ya pasó.');
      return;
    }

    final int id = DateTime.now().millisecondsSinceEpoch % 100000;
    final Reminder reminder = Reminder(
      id: id,
      title: title,
      body: body,
      dateTime: _selectedDateTime!,
    );

    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'canal_recordatorio',
      'Recordatorios Programados',
      channelDescription: 'Canal para recordatorios programados',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.schedule(
      reminder.id,
      reminder.title,
      reminder.body,
      reminder.dateTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    setState(() {
      _reminders.add(reminder);
      _reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    });
    await _saveHistory();

    _titleController.clear();
    _bodyController.clear();
    setState(() {
      _selectedDateTime = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recordatorio programado para ${DateFormat.yMd().add_Hm().format(reminder.dateTime)}')),
      );
    }
  }

  Future<void> _deleteReminder(int index) async {
    final reminder = _reminders[index];
    await flutterLocalNotificationsPlugin.cancel(reminder.id);
    setState(() {
      _reminders.removeAt(index);
    });
    await _saveHistory();

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


  // --- ¡AQUÍ ESTÁ LA CORRECCIÓN DE LAYOUT (LÍNEA 144)! ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programar Recordatorio'),
      ),
      // Usamos 'LayoutBuilder' y 'SingleChildScrollView' para que el teclado
      // no rompa la pantalla y el historial haga scroll correctamente.
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  // Esta es tu Column de la línea 144, ahora funciona
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Esta es la parte de "crear recordatorio" ---
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _bodyController,
                        decoration: const InputDecoration(
                          labelText: 'Cuerpo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_selectedDateTime == null
                            ? 'Seleccionar Fecha y Hora'
                            : DateFormat.yMd().add_Hm().format(_selectedDateTime!)),
                        onPressed: _selectDateTime,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.schedule_send),
                        label: const Text('Programar Recordatorio'),
                        onPressed: _scheduleNotification,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const Divider(height: 32),

                      // --- Esta es la parte del "historial" ---
                      Text(
                        'Historial de Recordatorios',
                        // Corregí el estilo por si acaso era eso (es lo mismo pero más seguro)
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 8), // Pequeño espacio

                      // ¡AQUÍ ESTÁ EL CAMBIO!
                      // Quitamos 'Expanded' y dejamos que el ListView
                      // crezca tanto como necesite (ya que estamos en un SingleChildScrollView)
                      _reminders.isEmpty
                          ? const Center(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No hay recordatorios programados.'),
                      )
                          : ListView.builder(
                        itemCount: _reminders.length,
                        shrinkWrap: true, // Importante: para que quepa en el Column
                        physics: const NeverScrollableScrollPhysics(), // Para que scrollee el 'SingleChildScrollView'
                        itemBuilder: (context, index) {
                          final reminder = _reminders[index];
                          return ListTile(
                            title: Text(reminder.title),
                            subtitle: Text(
                              '${reminder.body}\n${DateFormat.yMd().add_Hm().format(reminder.dateTime)}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteReminder(index),
                            ),
                            isThreeLine: true,
                          );
                        },
                      ),
                      // El 'Expanded' que estaba aquí se eliminó.
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
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