import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class ApiService {
  static const String baseUrl =
      'https://backend-rp-arreglado-n8p8.onrender.com/api';

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await AuthService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<Map<String, dynamic>> get(
    String path, {
    bool auth = true,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> delete(
    String path, {
    bool auth = true,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> detectarMaterial(
    Map<String, dynamic> body,
  ) async {
    return post('/detectar-material', body: body, auth: false);
  }

  static Future<Map<String, dynamic>> asignarPuntos(
    Map<String, dynamic> body,
  ) async {
    const puntosBase =
        'https://backend-rp-arreglado-n8p8.onrender.com/api/puntos';
    final response = await http.post(
      Uri.parse('$puntosBase/asignar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> uploadImage(
    String path,
    String field,
    String filePath, {
    bool auth = true,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
    final headers = await _headers(auth: auth);
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath(field, filePath));

    print("--- ENVIANDO IMAGEN A: $baseUrl$path ---");

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 90),
    );
    final response = await http.Response.fromStream(streamedResponse);

    print("--- RESPUESTA RECIBIDA ---");
    print("STATUS CODE: ${response.statusCode}");
    print("CUERPO: ${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error del servidor: ${response.statusCode}");
    }
  }
}
