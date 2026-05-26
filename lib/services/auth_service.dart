import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  static const String baseUrl = 'https://backend-rp-arreglado-n8p8.onrender.com/api/auth';

  // LOGIN
  static Future<Map<String, dynamic>> login({
    required String correo,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse('$baseUrl/iniciar-sesion'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'password': password}),
    );

    final data = jsonDecode(response.body);

    // Guarda los datos de sesión si el login fue exitoso
    if (data['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      if (data['usuario'] != null) {
        if (data['usuario']['nombre'] != null) {
          await prefs.setString('nombre_usuario', data['usuario']['nombre']);
        }
        if (data['usuario']['id'] != null) {
          await prefs.setString('usuario_id', data['usuario']['id'].toString());
        }
        if (data['usuario']['correo'] != null) {
          await prefs.setString('usuario_correo', data['usuario']['correo']);
        }
        if (data['usuario']['rol'] != null) {
          await prefs.setString('usuario_rol', data['usuario']['rol']);
        }
        if (data['usuario']['telefono'] != null) {
          await prefs.setString('usuario_telefono', data['usuario']['telefono']);
        }
      }
    }

    return data;
  }

  // REGISTER
  static Future<Map<String, dynamic>> register({
    required String nombre,
    required String correo,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse('$baseUrl/registrarse'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nombre': nombre, 'correo': correo, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  // OBTENER DATOS GUARDADOS
  static Future<String> getNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nombre_usuario') ?? 'Usuario';
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String> getUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuario_id') ?? '';
  }

  static Future<String> getCorreo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuario_correo') ?? '';
  }

  static Future<String> getRol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuario_rol') ?? 'usuario';
  }

  static Future<String> getTelefono() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuario_telefono') ?? '';
  }

  // RECUPERAR CONTRASEÑA
  static Future<Map<String, dynamic>> recuperarPasswordSolicitar(String correo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recuperar-password/solicitar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> recuperarPasswordRestablecer({
    required String correo,
    required String codigo,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recuperar-password/restablecer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'codigo': codigo, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  // CERRAR SESIÓN (API + local)
  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.delete(
          Uri.parse('$baseUrl/cerrar-sesion'),
          headers: {'Authorization': 'Bearer $token'},
        );
      }
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nombre_usuario');
    await prefs.remove('token');
    await prefs.remove('usuario_id');
    await prefs.remove('usuario_correo');
    await prefs.remove('usuario_rol');
    await prefs.remove('usuario_telefono');
  }

  static Future<bool> estaLogueado() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }
}