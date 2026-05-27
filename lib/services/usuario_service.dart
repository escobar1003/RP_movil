import 'api_service.dart';

class UsuarioService {
  // ── PERFIL ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getPerfil() async {
    return ApiService.get('/usuario/perfil');
  }

  static Future<Map<String, dynamic>> updatePerfil({
    required String nombre,
    required String telefono,
  }) async {
    return ApiService.put('/usuario/perfil', body: {
      'nombre': nombre,
      'telefono': telefono,
    });
  }

  static Future<Map<String, dynamic>> cambiarPassword({
    required String passwordActual,
    required String passwordNuevo,
  }) async {
    return ApiService.put('/usuario/perfil/cambiar-password', body: {
      'passwordActual': passwordActual,
      'passwordNuevo': passwordNuevo,
    });
  }

  // ── PUNTOS ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getResumenPuntos() async {
    return ApiService.get('/usuario/puntos');
  }

  static Future<Map<String, dynamic>> getHistorialPuntos() async {
    return ApiService.get('/usuario/puntos/historial');
  }

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

  static Future<Map<String, dynamic>> getReservaDetalle(int id) async {
    return ApiService.get('/usuario/reservas/$id');
  }

  static Future<Map<String, dynamic>> crearReserva(Map<String, dynamic> body) async {
    return ApiService.post('/usuario/reservas', body: body);
  }

  static Future<Map<String, dynamic>> cancelarReserva(int id) async {
    return ApiService.delete('/usuario/reservas/$id');
  }
}
