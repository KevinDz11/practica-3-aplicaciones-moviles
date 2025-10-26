import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

class ContadorPasosScreen extends StatefulWidget {
  const ContadorPasosScreen({Key? key}) : super(key: key);

  @override
  State<ContadorPasosScreen> createState() => _ContadorPasosScreenState();
}

class _ContadorPasosScreenState extends State<ContadorPasosScreen> {
  int _pasos = 0;
  double _ultimaAceleracion = 0;
  bool _monitoreando = false;
  DateTime? _ultimoPaso;

  @override
  void initState() {
    super.initState();
    _iniciarMonitoreo();
  }

  void _iniciarMonitoreo() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (!_monitoreando) return;

      final aceleracionTotal = (event.x * event.x +
          event.y * event.y +
          event.z * event.z);

      final delta = aceleracionTotal - _ultimaAceleracion;

      if (delta > 15) { // Umbral para detectar paso
        final ahora = DateTime.now();
        if (_ultimoPaso == null ||
            ahora.difference(_ultimoPaso!) > const Duration(milliseconds: 300)) {

          setState(() {
            _pasos++;
            _ultimoPaso = ahora;
          });
        }
      }

      _ultimaAceleracion = aceleracionTotal;
    });
  }

  void _toggleMonitoreo() {
    setState(() {
      _monitoreando = !_monitoreando;
      if (!_monitoreando) {
        _ultimaAceleracion = 0;
        _ultimoPaso = null;
      }
    });
  }

  void _reiniciarContador() {
    setState(() {
      _pasos = 0;
      _ultimaAceleracion = 0;
      _ultimoPaso = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indicador de estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _monitoreando ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _monitoreando ? Colors.green : Colors.grey,
                ),
              ),
              child: Text(
                _monitoreando ? 'MONITOREANDO PASOS' : 'DETENIDO',
                style: TextStyle(
                  color: _monitoreando ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Contador de pasos
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 4,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_pasos',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'PASOS',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Botones de control
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleMonitoreo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _monitoreando ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  icon: Icon(_monitoreando ? Icons.pause : Icons.play_arrow),
                  label: Text(_monitoreando ? 'DETENER' : 'INICIAR'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _reiniciarContador,
                  icon: const Icon(Icons.refresh),
                  label: const Text('REINICIAR'),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Información
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'El contador utiliza el acelerómetro del dispositivo '
                    'para detectar movimientos que simulan pasos. '
                    'Para mejores resultados, lleva el dispositivo en el bolsillo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}