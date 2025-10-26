import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart'; // <--- 1. IMPORT CORREGIDO

class LinternaScreen extends StatefulWidget {
  const LinternaScreen({Key? key}) : super(key: key);

  @override
  State<LinternaScreen> createState() => _LinternaScreenState();
}

class _LinternaScreenState extends State<LinternaScreen> {
  bool _linternaActiva = false;
  bool _disponible = false; // Inicia como falso hasta verificar

  @override
  void initState() {
    super.initState();
    _verificarDisponibilidad();
  }

  Future<void> _verificarDisponibilidad() async {
    try {
      // 2. FORMA NUEVA DE VERIFICAR
      final disponible = await TorchLight.isTorchAvailable();
      setState(() {
        _disponible = disponible;
      });
    } catch (e) {
      setState(() {
        _disponible = false;
      });
    }
  }

  Future<void> _toggleLinterna() async {
    try {
      if (_linternaActiva) {
        // 3. FORMA NUEVA DE APAGAR
        await TorchLight.disableTorch();
      } else {
        // 4. FORMA NUEVA DE ENCENDER
        await TorchLight.enableTorch();
      }
      setState(() {
        _linternaActiva = !_linternaActiva;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al controlar la linterna: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_disponible)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Linterna no disponible en este dispositivo',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            GestureDetector(
              onTap: _disponible ? _toggleLinterna : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: _linternaActiva
                      ? Colors.yellow.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _linternaActiva ? Colors.amber : Colors.grey,
                    width: 4,
                  ),
                ),
                child: Icon(
                  _linternaActiva ? Icons.flashlight_on : Icons.flashlight_off,
                  size: 80,
                  color: _linternaActiva ? Colors.amber : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              _linternaActiva ? 'LINTERNA ACTIVA' : 'LINTERNA APAGADA',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _linternaActiva
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _disponible ? _toggleLinterna : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: _linternaActiva ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
              icon: Icon(_linternaActiva ? Icons.power_off : Icons.power),
              label: Text(_linternaActiva ? 'APAGAR' : 'ENCENDER'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_linternaActiva) {
      // 5. APAGAR AL SALIR
      TorchLight.disableTorch();
    }
    super.dispose();
  }
}