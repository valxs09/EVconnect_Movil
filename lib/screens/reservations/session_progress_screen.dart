import 'package:flutter/material.dart';
import 'dart:async';
import '../../widgets/custom_app_bar.dart';
import '../../services/websocket_service.dart';
import '../../services/session_service.dart';

class SessionProgressScreen extends StatefulWidget {
  // Parámetros de la sesión de carga
  final int reservationId;
  final String chargerName;
  final Duration initialDuration;
  final double pricePerMinute; // Precio por minuto en tu moneda

  const SessionProgressScreen({
    super.key,
    this.reservationId = 0,
    this.chargerName = '',
    this.initialDuration = const Duration(minutes: 90),
    this.pricePerMinute = 0.50,
  });

  @override
  State<SessionProgressScreen> createState() => _SessionProgressScreenState();
}

class _SessionProgressScreenState extends State<SessionProgressScreen> {
  // Control de sesión
  int? _sessionId;
  bool _isSessionActive = false;
  bool _isLoading = true;

  late Duration _remainingTime;
  late Duration _elapsedTime;
  double _currentProgress = 1.0; // 1.0 = 100%, 0.0 = 0%
  late double _totalSeconds;

  // Valores de costo
  double _currentCost = 0.00;
  double _montoRetenido = 0.00;

  // Control de finalización manual
  bool _isFinishing = false;

  // Throttling para evitar setState() excesivos
  DateTime? _lastProgressUpdate;
  Timer? _backupTimer;

  // Colores
  final Color _backgroundColor = const Color(0xFFF2F2F2);
  final Color _progressColor = const Color(0xFF37A686);
  final Color _finalizarButtonColor = const Color(0xFF2C403A);

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.initialDuration;
    _elapsedTime = Duration.zero;
    _totalSeconds = widget.initialDuration.inSeconds.toDouble();

    // Esperar a que el contexto esté disponible para obtener argumentos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSession();
    });
  }

  Future<void> _initializeSession() async {
    try {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args == null) {
        throw Exception('No se recibieron argumentos');
      }

      final int cargadorId = args['reservationId'] ?? widget.reservationId;
      final Duration duration =
          args['initialDuration'] ?? widget.initialDuration;

      // Actualizar duración con el valor correcto de los argumentos
      setState(() {
        _remainingTime = duration;
        _totalSeconds = duration.inSeconds.toDouble();
      });

      print('🔄 Inicializando sesión de carga...');
      print('📍 Cargador ID: $cargadorId');
      print('⏱️ Duración seleccionada: ${duration.inMinutes} minutos');
      print('⏱️ Total segundos: $_totalSeconds');

      // 1. Conectar al WebSocket (no bloqueante)
      _connectWebSocket(cargadorId);

      // 2. Iniciar sesión en el backend
      await _startSession(cargadorId, duration);
    } catch (e) {
      print('❌ Error al inicializar sesión: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Esperar un frame para que se actualice la UI
        await Future.delayed(const Duration(milliseconds: 100));

        _showError('Error al iniciar la carga: ${e.toString()}');

        // Esperar que se muestre el snackbar antes de volver
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  void _connectWebSocket(int cargadorId) {
    print('🔌 Conectando al WebSocket del cargador $cargadorId...');

    WebSocketService.connect(
      cargadorId: cargadorId,
      role: 'client',
      onSubscribedCallback: (data) {
        print('✅ Suscrito al cargador: ${data['cargadorId']}');
        print('📊 Estado: ${data['estado_cargador']}');
      },
      onSessionStartedCallback: (data) {
        print('🚀 Sesión iniciada desde WebSocket');

        // Cancelar backup timer ya que el WebSocket respondió
        _backupTimer?.cancel();
        _backupTimer = null;

        if (mounted) {
          setState(() {
            _sessionId = data['id_sesion'] as int;
            _montoRetenido = (data['monto_retenido'] as num).toDouble();
            _isSessionActive = true;
            _isLoading = false;
          });
        }
      },
      onSessionProgressCallback: (data) {
        _handleSessionProgress(data);
      },
      onSessionFinishedCallback: (data) {
        _handleSessionFinished(data);
      },
    );
  }

  Future<void> _startSession(int cargadorId, Duration duration) async {
    try {
      print('📡 Iniciando sesión de carga en el backend...');

      final result = await SessionService.startSession(
        idCargador: cargadorId,
        durationMinutes: duration.inMinutes,
        tipoCarga: 'lenta',
      );

      if (result == null) {
        throw Exception('No se pudo iniciar la sesión');
      }

      print('✅ Sesión iniciada correctamente en el backend');
      print('📊 Datos: $result');

      // Si el WebSocket no envía el mensaje de inicio, actualizar estado manualmente
      // Usar Timer cancelable en lugar de Future.delayed
      _backupTimer?.cancel();
      _backupTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _isLoading) {
          print('⚠️ WebSocket no respondió, activando backup timer');
          setState(() {
            _isLoading = false;
            _isSessionActive = true;
          });
        }
      });
    } catch (e) {
      throw Exception('Error al iniciar sesión: ${e.toString()}');
    }
  }

  void _handleSessionProgress(Map<String, dynamic> data) {
    if (!mounted) return;

    // THROTTLING: Limitar actualizaciones a máximo cada 500ms
    final now = DateTime.now();
    if (_lastProgressUpdate != null) {
      final diff = now.difference(_lastProgressUpdate!);
      if (diff.inMilliseconds < 500) {
        // Ignorar esta actualización, muy frecuente
        return;
      }
    }
    _lastProgressUpdate = now;

    final int tiempoTranscurridoSeg = data['tiempo_transcurrido_seg'] as int;
    final int tiempoRestanteSeg = data['tiempoRestanteSeg'] as int;
    final double montoAcumulado = (data['monto_acumulado'] as num).toDouble();
    final int duracionEstimadaMin = data['duracion_estimada_min'] as int;

    // Usar addPostFrameCallback para no bloquear el frame actual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _elapsedTime = Duration(seconds: tiempoTranscurridoSeg);
        _remainingTime = Duration(seconds: tiempoRestanteSeg);
        _currentCost = montoAcumulado;
        _totalSeconds = (duracionEstimadaMin * 60).toDouble();
        _currentProgress = tiempoRestanteSeg / _totalSeconds;
      });
    });
  }

  void _handleSessionFinished(Map<String, dynamic> data) {
    if (!mounted) return;

    print('🏁 Sesión finalizada desde WebSocket');
    print('📊 Razón: ${data['razon']}');

    setState(() {
      _isSessionActive = false;
    });

    // Usar los datos del WebSocket para navegar
    _navigateToSummaryWithData(data);
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // El timer ya no es necesario, el WebSocket envía actualizaciones cada segundo

  @override
  void dispose() {
    print('🧹 Limpiando recursos de SessionProgressScreen...');

    // Cancelar timer de backup si existe
    _backupTimer?.cancel();
    _backupTimer = null;

    // Desconectar WebSocket y cancelar suscripción
    WebSocketService.disconnect();

    super.dispose();
    print('✅ Recursos limpiados correctamente');
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitHours = twoDigits(duration.inHours);
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    // Siempre mostrar formato HH:MM:SS
    return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _finishCharge() async {
    // Validar que tengamos el ID de sesión
    if (_sessionId == null) {
      _showError('No se puede finalizar: ID de sesión no encontrado');
      return;
    }

    // Evitar múltiples llamadas
    if (_isFinishing) {
      print('⚠️ Ya se está finalizando la sesión');
      return;
    }

    setState(() {
      _isFinishing = true;
    });

    try {
      print('🛑 Finalizando carga manualmente - Sesión ID: $_sessionId');

      // Mostrar diálogo de carga
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF37A686),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Finalizando carga...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }

      // Llamar al endpoint para detener la sesión
      final result = await SessionService.stopSession(_sessionId!);

      // Cerrar diálogo de carga
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (result == null) {
        throw Exception('No se recibió respuesta del servidor');
      }

      print('✅ Sesión detenida exitosamente');
      print('📊 Datos finales: $result');

      // Navegar a pantalla de resumen con los datos reales del servidor
      if (mounted) {
        _navigateToSummaryWithData(result);
      }
    } catch (e) {
      print('❌ Error al finalizar carga: $e');

      // Cerrar diálogo si está abierto
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        setState(() {
          _isFinishing = false;
        });

        _showError('Error al finalizar carga: ${e.toString()}');
      }
    }
  }

  void _navigateToSummaryWithData(Map<String, dynamic> data) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String chargerName = args?['chargerName'] ?? widget.chargerName;

    // Extraer datos del resultado del servidor
    final double montoCobrado = (data['monto_cobrado'] as num?)?.toDouble() ?? _currentCost;
    final double montoRetenido = (data['monto_retenido'] as num?)?.toDouble() ?? _montoRetenido;
    final double ahorro = (data['ahorro'] is String 
        ? double.tryParse(data['ahorro']) 
        : (data['ahorro'] as num?)?.toDouble()) ?? 0.0;
    final int tiempoTranscurrido = data['tiempo_transcurrido_min'] as int? ?? _elapsedTime.inMinutes;
    final double energiaConsumida = (data['energia_consumida_kwh'] as num?)?.toDouble() ?? 0.0;

    print('📊 Navegando a resumen con datos:');
    print('   Monto cobrado: \$$montoCobrado');
    print('   Monto retenido: \$$montoRetenido');
    print('   Ahorro: \$$ahorro');
    print('   Tiempo transcurrido: $tiempoTranscurrido min');
    print('   Energía: ${energiaConsumida}kWh');

    Navigator.of(context).pushReplacementNamed(
      '/summary',
      arguments: {
        'totalCost': '\$${montoCobrado.toStringAsFixed(2)}',
        'energyConsumed': '${energiaConsumida.toStringAsFixed(1)}kWh',
        'duration': _formatDurationForSummary(Duration(minutes: tiempoTranscurrido)),
        'stationId': chargerName,
        'paymentCard': 'Visa ••••4567',
        'montoRetenido': '\$${montoRetenido.toStringAsFixed(2)}',
        'ahorro': ahorro > 0 ? '\$${ahorro.toStringAsFixed(2)}' : null,
      },
    );
  }

  String _formatDurationForSummary(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    // Obtener argumentos de navegación si existen
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Usar argumentos o valores por defecto del widget
    final String chargerName = args?['chargerName'] ?? widget.chargerName;

    final String timeDisplay = _formatDuration(_remainingTime);
    final String costDisplay = '\$${_currentCost.toStringAsFixed(2)}';

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: CustomAppBar(title: chargerName, showBackButton: true),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF37A686)),
                    SizedBox(height: 20),
                    Text(
                      'Iniciando sesión de carga...',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              )
              : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 40),

                      // Título
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icono de Rayo
                          Image.asset(
                            'assets/rayo.png',
                            height: 35,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Carga en\nprogreso...',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),

                      // Círculo de Progreso
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Círculo de progreso
                            SizedBox(
                              width: 250,
                              height: 250,
                              child: CircularProgressIndicator(
                                value: _currentProgress,
                                strokeWidth: 15,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _progressColor,
                                ),
                              ),
                            ),

                            // Texto en medio del círculo
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Tiempo Restante (Cuenta regresiva)
                                Text(
                                  timeDisplay,
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: _progressColor,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                // Texto "Cargando..."
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.flash_on,
                                      color: _progressColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Cargando...',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: _progressColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),

                      // Costo Actual
                      const Text(
                        'Costo actual:',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        costDisplay,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _progressColor,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Botón Finalizar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _finishCharge,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _finalizarButtonColor,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Finalizar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
    );
  }
}
