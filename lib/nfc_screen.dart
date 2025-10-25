import 'package.flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
// ¡SOLUCIÓN 1! - Añadir esta importación para Ndef
import 'package:nfc_manager/models/ndef.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NfcScreen extends StatefulWidget {
  const NfcScreen({super.key});

  @override
  State<NfcScreen> createState() => _NfcScreenState();
}

class _NfcScreenState extends State<NfcScreen> {
  bool _isScanning = false;
  String _scanResult = 'Acerque una etiqueta NFC para escanear...';
  List<String> _history = [];
  final String _historyKey = 'nfc_history';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList(_historyKey) ?? [];
    });
  }

  Future<void> _saveHistory(String data) async {
    _history.insert(0, data);
    if (_history.length > 5) {
      _history = _history.sublist(0, 5);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, _history);
    setState(() {});
  }

  // --- ¡SOLUCIÓN 2! - Lógica de escaneo actualizada para v4 ---
  Future<void> _startScan() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        _scanResult = 'NFC no está disponible en este dispositivo.';
      });
      return;
    }

    setState(() {
      _isScanning = true;
      _scanResult = 'Escaneando... Acerque una etiqueta NFC';
    });

    // La v4 usa try/catch en lugar de 'onError'
    try {
      await NfcManager.instance.startSession(
        // 'pollingOptions' es requerido
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
        },
        onDiscovered: (NfcTag tag) async {
          String data = 'Etiqueta detectada';

          var ndef = Ndef.from(tag);
          if (ndef != null && ndef.cachedMessage != null) {
            var record = ndef.cachedMessage!.records.first;

            if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
                record.type[0] == 0x54) { // 'T' for Text
              data = String.fromCharCodes(record.payload.sublist(record.payload[0] + 1));
            } else {
              data = 'Etiqueta no es de texto (Payload: ${record.payload})';
            }
          } else {
            data = 'Etiqueta no compatible con NDEF.';
          }

          // stopSession ahora es async
          await NfcManager.instance.stopSession();
          setState(() {
            _isScanning = false;
            _scanResult = 'Resultado:\n$data';
          });

          _saveHistory(data);
        },
      );
    } catch (e) {
      // Manejar el error
      await NfcManager.instance.stopSession();
      setState(() {
        _isScanning = false;
        _scanResult = 'Error al escanear: $e';
      });
    }
  }

  // stopSession ahora es async
  Future<void> _stopScan() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (e) {
      debugPrint("Error al detener sesión NFC: $e");
    }
    setState(() {
      _isScanning = false;
      _scanResult = 'Escaneo detenido. Listo para iniciar.';
    });
  }

  @override
  void dispose() {
    // Asegurarse de detener la sesión al salir
    _stopScan();
    super.dispose();
  }
  // --- Fin de los cambios ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lector NFC'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: Icon(_isScanning
                  ? Icons.stop_circle_outlined
                  : Icons.sensors_rounded),
              label: Text(_isScanning ? 'Detener Escaneo' : 'Iniciar Escaneo'),
              onPressed: _isScanning ? _stopScan : _startScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isScanning
                    ? Colors.redAccent
                    : Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Text(
                _scanResult,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            const Text('Historial Reciente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: _history.isEmpty
                  ? const Center(child: Text('No hay historial.'))
                  : ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(_history[index]),
                    dense: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}