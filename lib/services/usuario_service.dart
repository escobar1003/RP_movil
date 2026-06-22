
import 'auth_service.dart';
import 'api_service.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class UsuarioService {
  // ── PERFIL ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getPerfil() async {
    return ApiService.get('/usuario/perfil');
  }

  static Future<Map<String, dynamic>> updatePerfil({
    required String nombre,
    required String apellido,
    required String telefono,
  }) async {
    return ApiService.put('/usuario/perfil', body: {
      'nombre': nombre,
      'apellido': apellido,
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

  // ── NOTIFICACIONES ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getNotificaciones() async {
    return ApiService.get('/usuario/notificaciones');
  }

  static Future<Map<String, dynamic>> marcarNotificacionLeida(int id) async {
    return ApiService.put('/usuario/notificaciones/$id/leer');
  }

  static Future<Map<String, dynamic>> marcarTodasNotificacionesLeidas() async {
    return ApiService.put('/usuario/notificaciones/leer-todas');
  }

  // ── RECOMPENSAS ────────────────────────────────────────────
  static Future<Map<String, dynamic>> getRecompensas() async {
    return ApiService.get('/usuario/recompensas');
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
    return ApiService.put('/usuario/reservas/$id/cancelar', body: {});
  }
  
  static Future<String?> subirFotoPerfil(File foto) async {
  try {
    final token = await AuthService.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiService.baseUrl}/usuario/perfil/foto'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(
      'foto',
      foto.path,
    ));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['foto'] as String?;
    }
    debugPrint('Error subiendo foto: ${response.body}');
    return null;
  } catch (e) {
    debugPrint('Error subiendo foto: $e');
    return null;
  }
}
}
