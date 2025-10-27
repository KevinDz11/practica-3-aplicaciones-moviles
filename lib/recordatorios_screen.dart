import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';

class Recordatorio {
  final String id;
  final String titulo;
  final String descripcion;
  final DateTime fechaHora;
  bool activo;

  Recordatorio({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaHora,
    this.activo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaHora': fechaHora.toIso8601String(),
      'activo': activo,
    };
  }

  static Recordatorio fromMap(Map<String, dynamic> map) {
    return Recordatorio(
      id: map['id'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      fechaHora: DateTime.parse(map['fechaHora']),
      activo: map['activo'],
    );
  }
}

class RecordatoriosScreen extends StatefulWidget {
  const RecordatoriosScreen({Key? key}) : super(key: key);

  @override
  State<RecordatoriosScreen> createState() => _RecordatoriosScreenState();
}

class _RecordatoriosScreenState extends State<RecordatoriosScreen> {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final List<Recordatorio> _recordatorios = [];
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  DateTime _fechaHora = DateTime.now().add(const Duration(minutes: 5));

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _cargarRecordatorios();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // 1. CAMBIO PARA NOTIFICACIÓN SILENCIOSA (iOS)
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false, // <-- Cambiado a false
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notificationsPlugin.initialize(initializationSettings);
  }

  void _cargarRecordatorios() {
    // En una app real, cargaríamos desde SharedPreferences o base de datos
    // Esta lista ahora persistirá gracias al IndexedStack en home_screen.dart
    if (_recordatorios.isEmpty) { // Solo añadimos el ejemplo si la lista está vacía
      setState(() {
        _recordatorios.addAll([
          Recordatorio(
            id: '1',
            titulo: 'Recordatorio de ejemplo',
            descripcion: 'Esta es una descripción de ejemplo',
            fechaHora: DateTime.now().add(const Duration(hours: 1)),
          ),
        ]);
      });
    }
  }

  void _agregarRecordatorio() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Nuevo Recordatorio'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        'Fecha y Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(_fechaHora)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final fecha = await showDatePicker(
                          context: context,
                          initialDate: _fechaHora,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (fecha != null) {
                          final hora = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_fechaHora),
                          );
                          if (hora != null) {
                            setDialogState(() {
                              _fechaHora = DateTime(
                                fecha.year,
                                fecha.month,
                                fecha.day,
                                hora.hour,
                                hora.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _guardarRecordatorio();
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _guardarRecordatorio() {
    final nuevoRecordatorio = Recordatorio(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloController.text,
      descripcion: _descripcionController.text,
      fechaHora: _fechaHora,
    );

    setState(() {
      _recordatorios.add(nuevoRecordatorio);
    });

    _programarNotificacion(nuevoRecordatorio);

    _tituloController.clear();
    _descripcionController.clear();
    _fechaHora = DateTime.now().add(const Duration(minutes: 5));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recordatorio agregado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _programarNotificacion(Recordatorio recordatorio) async {

    // 2. CAMBIO PARA NOTIFICACIÓN SILENCIOSA (Android)
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'recordatorios_channel',
      'Recordatorios',
      channelDescription: 'Canal para recordatorios programados',
      importance: Importance.low, // <-- Bajado de .max a .low
      priority: Priority.low, // <-- Bajado de .high a .low
      playSound: false, // <-- Explícitamente apagamos sonido
      enableVibration: false, // <-- Explícitamente apagamos vibración
    );

    // 3. CAMBIO PARA NOTIFICACIÓN SILENCIOSA (iOS)
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentSound: false, // <-- Explícitamente apagamos sonido
      presentAlert: true,
      presentBadge: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await notificationsPlugin.zonedSchedule(
      int.parse(recordatorio.id),
      recordatorio.titulo,
      recordatorio.descripcion,
      tz.TZDateTime.from(recordatorio.fechaHora, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  void _eliminarRecordatorio(int index) {
    final recordatorio = _recordatorios[index];

    // Cancelar notificación
    notificationsPlugin.cancel(int.parse(recordatorio.id));

    setState(() {
      _recordatorios.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recordatorio eliminado'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _toggleRecordatorio(int index) {
    setState(() {
      _recordatorios[index].activo = !_recordatorios[index].activo;
    });

    final recordatorio = _recordatorios[index];
    if (recordatorio.activo) {
      _programarNotificacion(recordatorio);
    } else {
      notificationsPlugin.cancel(int.parse(recordatorio.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarRecordatorio,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: _recordatorios.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay recordatorios',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Presiona el botón + para agregar uno',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _recordatorios.length,
        itemBuilder: (context, index) {
          final recordatorio = _recordatorios[index];
          return Dismissible(
            key: Key(recordatorio.id),
            background: Container(color: Colors.red),
            onDismissed: (direction) => _eliminarRecordatorio(index),
            child: Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Icon(
                  recordatorio.activo
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: recordatorio.activo
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                title: Text(recordatorio.titulo),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recordatorio.descripcion),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm')
                          .format(recordatorio.fechaHora),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        recordatorio.activo
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: () => _toggleRecordatorio(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _eliminarRecordatorio(index),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}