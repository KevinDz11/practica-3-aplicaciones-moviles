import 'dart:async'; // Necesario para el StreamSubscription
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorsScreen extends StatefulWidget {
  const SensorsScreen({super.key});

  @override
  State<SensorsScreen> createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen> {
  double _accelX = 0;
  double _accelY = 0;
  double _accelZ = 0;

  // Un "listener" para el stream de datos del sensor
  StreamSubscription? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    // Empezar a escuchar los eventos del acelerómetro
    _accelerometerSubscription =
        accelerometerEventStream().listen((AccelerometerEvent event) {
          // Actualizar el estado con los nuevos valores
          setState(() {
            _accelX = event.x;
            _accelY = event.y;
            _accelZ = event.z;
          });
        });
  }

  @override
  void dispose() {
    // ¡Muy importante! Cancelar la suscripción al salir de la pantalla
    // para evitar fugas de memoria.
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensores (Acelerómetro)'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Mueve tu teléfono y mira cómo cambian los valores:',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            // Formatear los números a 2 decimales
            Text(
              'Eje X: ${_accelX.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Eje Y: ${_accelY.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Eje Z: ${_accelZ.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}