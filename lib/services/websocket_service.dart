import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

// Callbacks para los diferentes tipos de mensajes
typedef OnSubscribedCallback = void Function(Map<String, dynamic> data);
typedef OnSessionStartedCallback = void Function(Map<String, dynamic> data);
typedef OnSessionProgressCallback = void Function(Map<String, dynamic> data);
typedef OnSessionFinishedCallback = void Function(Map<String, dynamic> data);

class WebSocketService {
  static WebSocketChannel? _channel;
  static StreamSubscription? _streamSubscription;
  static bool _isConnected = false;

  // Callbacks
  static OnSubscribedCallback? onSubscribed;
  static OnSessionStartedCallback? onSessionStarted;
  static OnSessionProgressCallback? onSessionProgress;
  static OnSessionFinishedCallback? onSessionFinished;

  // Conectar al WebSocket
  static Future<void> connect({
    required int cargadorId,
    String role = 'client',
    OnSubscribedCallback? onSubscribedCallback,
    OnSessionStartedCallback? onSessionStartedCallback,
    OnSessionProgressCallback? onSessionProgressCallback,
    OnSessionFinishedCallback? onSessionFinishedCallback,
  }) async {
    try {
      // Guardar callbacks
      onSubscribed = onSubscribedCallback;
      onSessionStarted = onSessionStartedCallback;
      onSessionProgress = onSessionProgressCallback;
      onSessionFinished = onSessionFinishedCallback;

      final uri = Uri.parse(
        'wss://evconnect-3ydy.onrender.com/ws?cargadorId=$cargadorId&role=$role',
      );

      print('🔌 Intentando conectar a WebSocket...');
      print('📡 URL: ${uri.toString()}');

      _channel = WebSocketChannel.connect(uri);

      // Cancelar suscripción anterior si existe
      await _streamSubscription?.cancel();

      // Escuchar mensajes con suscripción controlable
      _streamSubscription = _channel!.stream.listen(
        (message) {
          _isConnected = true;
          print('✅ WebSocket conectado exitosamente');
          print('📨 Mensaje recibido: $message');

          // Procesar mensaje
          _handleMessage(message);
        },
        onError: (error) {
          _isConnected = false;
          print('❌ Error en WebSocket: $error');
        },
        onDone: () {
          _isConnected = false;
          print('⚠️ WebSocket desconectado');
        },
        cancelOnError: false, // Continuar escuchando aunque haya errores
      );

      print('✅ WebSocket inicializado correctamente');
    } catch (e) {
      _isConnected = false;
      print('❌ Error al conectar WebSocket: $e');
    }
  }

  // Procesar mensajes recibidos
  static void _handleMessage(String message) {
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final type = data['type'] as String?;

      print('📦 Tipo de mensaje: $type');

      switch (type) {
        case 'subscribed':
          print('🟢 Suscrito al cargador: ${data['cargadorId']}');
          print('📊 Estado: ${data['estado_cargador']}');
          onSubscribed?.call(data);
          break;

        case 'sesion_iniciada':
          print('🚀 Sesión iniciada: ${data['id_sesion']}');
          print('💰 Monto retenido: \$${data['monto_retenido']}');
          onSessionStarted?.call(data);
          break;

        case 'carga_en_progreso':
          print('⚡ Carga en progreso - ID: ${data['id_sesion']}');
          print('⏱️ Tiempo transcurrido: ${data['tiempo_transcurrido_seg']}s');
          print('💵 Monto acumulado: \$${data['monto_acumulado']}');
          onSessionProgress?.call(data);
          break;

        case 'sesion_finalizada':
          print('🏁 Sesión finalizada - ID: ${data['id_sesion']}');
          print('✅ Razón: ${data['razon']}');
          print('💰 Monto cobrado: \$${data['monto_cobrado']}');
          onSessionFinished?.call(data);
          break;

        default:
          print('❓ Tipo de mensaje desconocido: $type');
      }
    } catch (e) {
      print('❌ Error al procesar mensaje: $e');
      print('📄 Mensaje raw: $message');
    }
  }

  // Enviar mensaje
  static void send(String message) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(message);
      print('📤 Mensaje enviado: $message');
    } else {
      print('⚠️ WebSocket no está conectado');
    }
  }

  // Desconectar
  static Future<void> disconnect() async {
    print('🔌 Desconectando WebSocket...');

    // Cancelar la suscripción del stream primero
    await _streamSubscription?.cancel();
    _streamSubscription = null;

    // Cerrar el canal
    if (_channel != null) {
      await _channel!.sink.close(status.goingAway);
      _channel = null;
    }

    _isConnected = false;

    // Limpiar callbacks
    onSubscribed = null;
    onSessionStarted = null;
    onSessionProgress = null;
    onSessionFinished = null;

    print('✅ WebSocket desconectado correctamente');
  }

  // Verificar si está conectado
  static bool get isConnected => _isConnected;
}
