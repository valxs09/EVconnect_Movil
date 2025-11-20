import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  static WebSocketChannel? _channel;
  static bool _isConnected = false;

  // Conectar al WebSocket
  static Future<void> connect({
    required int cargadorId,
    String role = 'client',
  }) async {
    try {
      final uri = Uri.parse(
        'wss://evconnect-3ydy.onrender.com/ws?cargadorId=$cargadorId&role=$role',
      );

      print('🔌 Intentando conectar a WebSocket...');
      print('📡 URL: ${uri.toString()}');

      _channel = WebSocketChannel.connect(uri);

      // Escuchar mensajes
      _channel!.stream.listen(
        (message) {
          _isConnected = true;
          print('✅ WebSocket conectado exitosamente');
          print('📨 Mensaje recibido: $message');
        },
        onError: (error) {
          _isConnected = false;
          print('❌ Error en WebSocket: $error');
        },
        onDone: () {
          _isConnected = false;
          print('⚠️ WebSocket desconectado');
        },
      );

      print('✅ WebSocket inicializado correctamente');
    } catch (e) {
      _isConnected = false;
      print('❌ Error al conectar WebSocket: $e');
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
  static void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _isConnected = false;
      print('🔌 WebSocket desconectado manualmente');
    }
  }

  // Verificar si está conectado
  static bool get isConnected => _isConnected;
}
