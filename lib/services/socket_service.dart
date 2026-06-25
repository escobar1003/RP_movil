import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  IO.Socket? _socket;
  bool _conectado = false;

  bool get estaConectado => _conectado;

  final StreamController<MapEntry<String, Map<String, dynamic>>> _controller =
      StreamController<MapEntry<String, Map<String, dynamic>>>.broadcast();

  /// Stream de (tipo, datos) para cualquier evento del socket
  Stream<MapEntry<String, Map<String, dynamic>>> get stream => _controller.stream;

  Future<void> conectar() async {
    if (_conectado) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('usuario_id');
    if (userId == null || userId.isEmpty) return;

    _socket = IO.io(
      'https://backend-rp-arreglado-n8p8.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'userId': userId, 'role': 'usuario'})
          .build(),
    );

    _socket!.onConnect((_) {
      _conectado = true;
    });

    _socket!.onDisconnect((_) {
      _conectado = false;
    });

    _socket!.on('puntos_actualizados', (data) {
      _controller.add(MapEntry('puntos_actualizados', data as Map<String, dynamic>));
    });

    _socket!.on('nueva_entrega', (data) {
      _controller.add(MapEntry('nueva_entrega', data as Map<String, dynamic>));
    });

    _socket!.on('reserva_aceptada', (data) {
      _controller.add(MapEntry('reserva_aceptada', data as Map<String, dynamic>));
    });

    _socket!.on('reserva_rechazada', (data) {
      _controller.add(MapEntry('reserva_rechazada', data as Map<String, dynamic>));
    });

    _socket!.connect();
  }

  void desconectar() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _conectado = false;
  }

  void dispose() {
    _controller.close();
    desconectar();
  }
}
