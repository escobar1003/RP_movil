import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {

  // LOGIN
  static Future<Map<String, dynamic>> login({
    required String correo,
    required String password,
  }) async {
    final data = await ApiService.post(
      '/auth/iniciar-sesion',
      body: {'correo': correo, 'password': password},
      auth: false,
    );

    if (data['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      if (data['usuario'] != null) {
        final u = data['usuario'];
        if (u['nombre'] != null) await prefs.setString('nombre_usuario', u['nombre']);
        if (u['id'] != null) await prefs.setString('usuario_id', u['id'].toString());
        if (u['correo'] != null) await prefs.setString('usuario_correo', u['correo']);
        if (u['rol'] != null) await prefs.setString('usuario_rol', u['rol']);
        if (u['telefono'] != null) await prefs.setString('usuario_telefono', u['telefono']);
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
    return ApiService.post(
      '/auth/registrarse',
      body: {'nombre': nombre, 'correo': correo, 'password': password},
      auth: false,
    );
  }

  // GET PERFIL
  static Future<Map<String, dynamic>> getPerfil() async {
    final data = await ApiService.get('/usuario/perfil');
    if (data['usuario'] != null) {
      final prefs = await SharedPreferences.getInstance();
      final u = data['usuario'];
      if (u['nombre'] != null) await prefs.setString('nombre_usuario', u['nombre']);
      if (u['correo'] != null) await prefs.setString('usuario_correo', u['correo']);
      if (u['rol'] != null) await prefs.setString('usuario_rol', u['rol']);
      if (u['telefono'] != null) await prefs.setString('usuario_telefono', u['telefono']);
    }
    return data;
  }

  // UPDATE PERFIL
  static Future<Map<String, dynamic>> updatePerfil({
    String? nombre,
    String? telefono,
  }) async {
    final body = <String, dynamic>{};
    if (nombre != null) body['nombre'] = nombre;
    if (telefono != null) body['telefono'] = telefono;
    final data = await ApiService.put('/usuario/perfil', body: body);
    if (data['usuario'] != null) {
      final prefs = await SharedPreferences.getInstance();
      final u = data['usuario'];
      if (u['nombre'] != null) await prefs.setString('nombre_usuario', u['nombre']);
      if (u['telefono'] != null) await prefs.setString('usuario_telefono', u['telefono']);
    }
    return data;
  }

  // CHANGE PASSWORD
  static Future<Map<String, dynamic>> cambiarPassword({
    required String passwordActual,
    required String passwordNuevo,
  }) async {
    return ApiService.put(
      '/usuario/perfil/cambiar-password',
      body: {'passwordActual': passwordActual, 'passwordNuevo': passwordNuevo},
    );
  }

  // GET PUNTOS
  static Future<Map<String, dynamic>> getPuntos() async {
    return ApiService.get('/usuario/puntos');
  }

  // OBTENER DATOS GUARDADOS LOCALMENTE
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

  static Future<bool> estaLogueado() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  // CERRAR SESIÓN
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nombre_usuario');
    await prefs.remove('token');
    await prefs.remove('usuario_id');
    await prefs.remove('usuario_correo');
    await prefs.remove('usuario_rol');
    await prefs.remove('usuario_telefono');
  }
}
