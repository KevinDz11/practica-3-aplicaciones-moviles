import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:torch_light/torch_light.dart';

class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({super.key});

  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> {
  bool _isFlashlightOn = false;
  bool _hasFlashlight = false;

  @override
  void initState() {
    super.initState();
    _checkFlashlight();
    _requestPermission();
  }

  // Verificar si el dispositivo tiene linterna
  Future<void> _checkFlashlight() async {
    try {
      final bool hasFlash = await TorchLight.isTorchAvailable();
      setState(() {
        _hasFlashlight = hasFlash;
      });
    } catch (e) {
      _showErrorDialog('Error al verificar linterna: $e');
    }
  }

  // Pedir permiso de cámara
  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      _showErrorDialog('Se necesita permiso de cámara para usar la linterna.');
    }
  }

  Future<void> _toggleFlashlight() async {
    if (!_hasFlashlight) {
      _showErrorDialog('Este dispositivo no tiene linterna.');
      return;
    }

    try {
      if (_isFlashlightOn) {
        // Apagar
        await TorchLight.disableTorch();
      } else {
        // Encender
        await TorchLight.enableTorch();
      }
      setState(() {
        _isFlashlightOn = !_isFlashlightOn;
      });
    } catch (e) {
      _showErrorDialog('No se pudo acceder a la linterna: $e');
      setState(() {
        _isFlashlightOn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Asegurarnos de apagar la linterna si el usuario sale de la pantalla
    return PopScope(
      onPopInvoked: (_) => _turnOffBeforeLeaving(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Linterna'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_hasFlashlight)
                const Text('Este dispositivo no tiene linterna',
                    style: TextStyle(fontSize: 18, color: Colors.red)),

              IconButton(
                icon: Icon(
                  _isFlashlightOn ? Icons.flashlight_off_rounded : Icons.flashlight_on_rounded,
                  color: _isFlashlightOn
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).disabledColor,
                ),
                iconSize: 150,
                onPressed: _toggleFlashlight,
              ),

              Text(
                _isFlashlightOn ? 'ENCENDIDA' : 'APAGADA',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _turnOffBeforeLeaving() async {
    if (_isFlashlightOn) {
      await TorchLight.disableTorch();
    }
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