import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../../widgets/custom_app_bar.dart';
import '../../models/charger_model.dart';
import '../../services/auth_service.dart';

class NFCScreen extends StatefulWidget {
  const NFCScreen({super.key});

  @override
  State<NFCScreen> createState() => _NFCScreenState();
}

class _NFCScreenState extends State<NFCScreen> {
  // Colores
  final Color _backgroundColor = const Color(0xFFF2F2F2);
  final Color _chargerCardColor = const Color(0xFF52F2B8);
  final Color _chargerNumberColor = const Color(0xFF0D0D0D);
  final Color _nfcCardColor = const Color(0xFF2C403A);

  // Estado NFC
  bool _isNfcAvailable = false;
  bool _isReading = false;
  String? _nfcData;

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  // Verificar si NFC está disponible en el dispositivo
  Future<void> _checkNfcAvailability() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (mounted) {
      setState(() {
        _isNfcAvailable = isAvailable;
      });
    }

    if (!isAvailable) {
      _showSnackBar('❌ NFC no está disponible en este dispositivo');
    }
  }

  // Iniciar lectura de NFC
  Future<void> _startNfcReading() async {
    if (!_isNfcAvailable) {
      _showSnackBar('❌ NFC no está disponible');
      return;
    }

    setState(() {
      _isReading = true;
    });

    print('📡 Iniciando lectura NFC...');

    try {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          print('✅ Tag NFC detectado!');
          print('📋 Datos del tag: $tag');

          // Extraer el UID del tag
          String? uid;

          // Intentar obtener el identificador del tag
          if (tag.data.containsKey('nfca')) {
            final nfcA = tag.data['nfca'];
            if (nfcA is Map && nfcA.containsKey('identifier')) {
              final identifier = nfcA['identifier'] as List<int>?;
              if (identifier != null) {
                uid =
                    identifier
                        .map((e) => e.toRadixString(16).padLeft(2, '0'))
                        .join(':')
                        .toUpperCase();
              }
            }
          } else if (tag.data.containsKey('nfcb')) {
            final nfcB = tag.data['nfcb'];
            if (nfcB is Map && nfcB.containsKey('identifier')) {
              final identifier = nfcB['identifier'] as List<int>?;
              if (identifier != null) {
                uid =
                    identifier
                        .map((e) => e.toRadixString(16).padLeft(2, '0'))
                        .join(':')
                        .toUpperCase();
              }
            }
          } else if (tag.data.containsKey('nfcf')) {
            final nfcF = tag.data['nfcf'];
            if (nfcF is Map && nfcF.containsKey('identifier')) {
              final identifier = nfcF['identifier'] as List<int>?;
              if (identifier != null) {
                uid =
                    identifier
                        .map((e) => e.toRadixString(16).padLeft(2, '0'))
                        .join(':')
                        .toUpperCase();
              }
            }
          } else if (tag.data.containsKey('nfcv')) {
            final nfcV = tag.data['nfcv'];
            if (nfcV is Map && nfcV.containsKey('identifier')) {
              final identifier = nfcV['identifier'] as List<int>?;
              if (identifier != null) {
                uid =
                    identifier
                        .map((e) => e.toRadixString(16).padLeft(2, '0'))
                        .join(':')
                        .toUpperCase();
              }
            }
          }

          if (uid != null) {
            print('🔑 UID del NFC: $uid');

            // Guardar el UID
            await _saveNfcData(uid);

            if (mounted) {
              setState(() {
                _nfcData = uid;
                _isReading = false;
              });
            }

            _showSnackBar(' NFC leído exitosamente');

            // Detener la sesión
            NfcManager.instance.stopSession();
          } else {
            print('⚠️ No se pudo extraer el UID del tag');
            _showSnackBar(' No se pudo leer el UID del NFC');
            if (mounted) {
              setState(() {
                _isReading = false;
              });
            }
            NfcManager.instance.stopSession();
          }
        },
        onError: (error) async {
          print('❌ Error al leer NFC: $error');
          _showSnackBar('❌ Error al leer NFC');
          if (mounted) {
            setState(() {
              _isReading = false;
            });
          }
        },
      );
    } catch (e) {
      print('❌ Excepción al iniciar lectura NFC: $e');
      _showSnackBar('❌ Error al iniciar lectura NFC');
      if (mounted) {
        setState(() {
          _isReading = false;
        });
      }
    }
  }

  // Guardar el dato NFC
  Future<void> _saveNfcData(String uid) async {
    try {
      await AuthService.saveNfcUid(uid);
      print('💾 NFC UID guardado: $uid');
    } catch (e) {
      print('❌ Error al guardar NFC UID: $e');
    }
  }

  // Cancelar lectura NFC
  void _cancelNfcReading() {
    NfcManager.instance.stopSession();
    if (mounted) {
      setState(() {
        _isReading = false;
      });
    }
    print('⚠️ Lectura NFC cancelada');
  }

  // Mostrar SnackBar
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el cargador de los argumentos
    final ChargerModel? charger =
        ModalRoute.of(context)?.settings.arguments as ChargerModel?;
    final String chargerNumber =
        charger?.idCargador.toString().padLeft(2, '0') ?? '00';

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: const CustomAppBar(title: '', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Título Principal
            const Text(
              '¡Estación asignada!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // Subtítulo
            const Text(
              '¡Dirígete a cargar tu coche!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 0),

            // Icono del enchufe
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/enchufe.png',
                  height: 69,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // --- Card Principal: Cargador #07 ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 30.0,
                horizontal: 20.0,
              ),
              decoration: BoxDecoration(
                color: _chargerCardColor, // Color 52F2B8
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: _chargerCardColor.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Cargador\n# $chargerNumber',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: _chargerNumberColor, // Color 0D0D0D
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- Card/Botón: Leer NFC ---
            if (_nfcData == null)
              GestureDetector(
                onTap: _isReading ? _cancelNfcReading : _startNfcReading,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 30.0,
                    horizontal: 20.0,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _isReading
                            ? const Color(0xFFFF6B6B)
                            : _nfcCardColor, // Rojo si está leyendo, verde oscuro si no
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icono de NFC
                      if (_isReading)
                        const SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      else
                        Image.asset(
                          'assets/nfc.png',
                          height: 50,
                          color: Colors.white,
                        ),
                      const SizedBox(width: 20),

                      Flexible(
                        child: Text(
                          _isReading
                              ? '¡Acerca tu móvil al\nlector NFC ahora!'
                              : '¡Acerca tu móvil a la\nestación para empezar!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              // NFC leído exitosamente
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 30.0,
                  horizontal: 20.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50), // Verde éxito
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 50,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      '✅ NFC leído correctamente',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'UID: $_nfcData',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 40),

            // --- Botón/Link: Cancelar Carga ---
            TextButton(
              onPressed: () {
                print('Cancelar Carga');
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar Carga',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
