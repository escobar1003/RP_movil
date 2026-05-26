import 'api_service.dart';

class UsuarioService {
  // ── ENTREGAS ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> getEntregas() async {
    return ApiService.get('/usuario/entregas');
  }

  static Future<Map<String, dynamic>> getEntregaDetalle(int id) async {
    return ApiService.get('/usuario/entregas/$id');
  }

  static Future<Map<String, dynamic>> crearEntrega(Map<String, dynamic> body) async {
    return ApiService.post('/usuario/entregas', body: body);
  }

  // ── CANJES ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getCanjes() async {
    return ApiService.get('/usuario/canjes');
  }

  static Future<Map<String, dynamic>> getCanjeDetalle(int id) async {
    return ApiService.get('/usuario/canjes/$id');
  }

  static Future<Map<String, dynamic>> canjearRecompensa(int idRecompensa) async {
    return ApiService.post('/usuario/canjes', body: {'idRecompensa': idRecompensa});
  }

  // ── RESERVAS ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> getReservas() async {
    return ApiService.get('/usuario/reservas');
  }

  static Future<Map<String, dynamic>> crearReserva(Map<String, dynamic> body) async {
    return ApiService.post('/usuario/reservas', body: body);
  }

  static Future<Map<String, dynamic>> cancelarReserva(int id) async {
    return ApiService.delete('/usuario/reservas/$id');
  }
}
