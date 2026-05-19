import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  static const String baseUrl = 'http://127.0.0.1:3333/api/auth';

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

    // Guarda el nombre si el login fue exitoso
    if (data['usuario'] != null && data['usuario']['nombre'] != null) {
       final prefs = await SharedPreferences.getInstance();
       await prefs.setString('nombre_usuario', data['usuario']['nombre']);
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

  // OBTENER NOMBRE GUARDADO
  static Future<String> getNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nombre_usuario') ?? 'Usuario';
  }

  // CERRAR SESIÓN
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nombre_usuario');
  }
}