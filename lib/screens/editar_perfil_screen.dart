// lib/screens/editar_perfil_screen.dart
// ✅ Pon esto al inicio del archivo:
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // ← necesario para kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../services/usuario_service.dart';
import '../theme/app_theme.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController     = TextEditingController();
  final _apellidoController   = TextEditingController();
  final _correoController     = TextEditingController();
  final _telefonoController   = TextEditingController();
  final _infoController       = TextEditingController();

  bool _guardando   = false;
  bool _cargando    = true;

  // Foto de perfil
  File?   _fotoArchivo;       // foto nueva elegida del dispositivo
  String? _fotoUrlActual;     // URL que ya viene del servidor

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // ── Cargar datos desde el backend ────────────────────
  Future<void> _cargarDatos() async {
    try {
      final perfil = await UsuarioService.getPerfil();
      final u = perfil['usuario'] ?? perfil; // acepta ambas estructuras
      _nombreController.text   = u['nombre']   ?? '';
      _apellidoController.text = u['apellido'] ?? '';
      _correoController.text   = u['correo']   ?? '';
      _telefonoController.text = u['telefono'] ?? '';
      _infoController.text     = u['info']     ?? '';
      _fotoUrlActual           = u['imagen'];
    } catch (_) {
      // fallback a SharedPreferences si el backend falla
      _nombreController.text   = await AuthService.getNombre();
      _telefonoController.text = await AuthService.getTelefono();
    }
    if (mounted) setState(() => _cargando = false);
  }

  // ── Elegir foto de galería ────────────────────────────
  Future<void> _elegirFoto() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
    maxWidth: 600,
  );
  if (picked == null) return;

  if (!kIsWeb) {
    // En móvil (Android/iOS) usamos File normal
    setState(() => _fotoArchivo = File(picked.path));
  }
  // En web no se puede usar File — se activará cuando conectes la subida real
}

  // ── Guardar cambios ───────────────────────────────────
  Future<void> _guardar() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _guardando = true);

  try {
    final resultado = await UsuarioService.updatePerfil(
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      telefono: _telefonoController.text.trim(),
    );
    // Verifica si el backend devolvió error
    if (resultado['status'] == 'error' || resultado['error'] != null) {
      final msg = resultado['mensaje'] ?? resultado['error'] ?? 'Error del servidor';
      throw Exception(msg);
    }

    // Actualizar caché local
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombre_usuario', _nombreController.text.trim());
    await prefs.setString('usuario_telefono', _telefonoController.text.trim());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Color(0xFF2D5A1B),
        ),
      );
      Navigator.pop(context, true);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  if (mounted) setState(() => _guardando = false);
}

  // ── Restablecer campos ────────────────────────────────
  Future<void> _restablecer() async {
    setState(() => _cargando = true);
    _fotoArchivo = null;
    await _cargarDatos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6EF),
      appBar: AppBar(
        title: const Text('Editar perfil'),
        backgroundColor: const Color(0xFF2D5A1B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D5A1B)))
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  // ── Contenido scrolleable ──────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      child: Column(
                        children: [
                          // ── Avatar ─────────────────────
                          _buildAvatarPicker(),
                          const SizedBox(height: 24),

                          // ── Tarjeta campos ─────────────
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _campo(
                                  label: 'Nombre',
                                  controller: _nombreController,
                                  hint: 'Tu nombre',
                                  icon: Icons.person_outline_rounded,
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'El nombre es obligatorio'
                                      : null,
                                ),
                                _divider(),
                               _campo(
                                  label: 'Apellido',
                                  controller: _apellidoController,
                                  hint: 'Tu apellido',
                                  icon: Icons.person_outline_rounded,
                                  enabled: true,
                                ),
                                _divider(),
                                _campo(
                                  label: 'Correo electrónico',
                                  controller: _correoController,
                                  hint: 'tu@correo.com',
                                  icon: Icons.mail_outline_rounded,
                                  teclado: TextInputType.emailAddress,
                                  enabled: false,      // correo no editable por ahora
                                  sufijo: const Icon(Icons.lock_outline_rounded,
                                      size: 16, color: Color(0xFF9DB8A0)),
                                ),
                                _divider(),
                                _campo(
                                  label: 'Teléfono',
                                  controller: _telefonoController,
                                  hint: '3001234567',
                                  icon: Icons.phone_outlined,
                                  teclado: TextInputType.phone,
                                ),
                                _divider(),
                                _campo(
                                  label: 'Info / Bio',
                                  controller: _infoController,
                                  hint: 'Cuéntanos algo sobre ti...',
                                  icon: Icons.info_outline_rounded,
                                  maxLines: 3,
                                  enabled: false,
                                  sufijo: _badgePendiente(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ── Nota campos deshabilitados ──
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAEEDA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.schedule_rounded,
                                    size: 16, color: Color(0xFF854F0B)),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Info estará disponible próximamente.',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF854F0B),
                                        height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // ── Botones fijos abajo ─────────────────
                  _buildBotonesInferiores(),
                ],
              ),
            ),
    );
  }

  // ── Widget: selector de avatar ──────────────────────────
  Widget _buildAvatarPicker() {
  // Decide qué imagen mostrar: primero foto local, luego URL del servidor
  ImageProvider? imagenMostrar;
  if (!kIsWeb && _fotoArchivo != null) {
    imagenMostrar = FileImage(_fotoArchivo!);
  } else if (_fotoUrlActual != null && _fotoUrlActual!.isNotEmpty) {
    imagenMostrar = NetworkImage(_fotoUrlActual!);
  }

  return Center(
    child: Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD6EFC7),
            border: Border.all(color: const Color(0xFF2D5A1B), width: 3),
            image: imagenMostrar != null
                ? DecorationImage(image: imagenMostrar, fit: BoxFit.cover)
                : null,
          ),
          child: imagenMostrar == null
              ? const Icon(Icons.person_rounded,
                  size: 50, color: Color(0xFF2D5A1B))
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _elegirFoto,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2D5A1B),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    ),
  );
}

  // ── Widget: tarjeta blanca con sombra ───────────────────
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  // ── Widget: campo de formulario ─────────────────────────
  Widget _campo({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType teclado = TextInputType.text,
    String? Function(String?)? validator,
    bool enabled = true,
    int maxLines = 1,
    Widget? sufijo,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: enabled
                      ? const Color(0xFF1E3A0F)
                      : const Color(0xFF9DB8A0))),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: teclado,
            maxLines: maxLines,
            validator: validator,
            style: TextStyle(
                fontSize: 14,
                color: enabled
                    ? const Color(0xFF1E3A0F)
                    : const Color(0xFF9DB8A0)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color(0xFF9DB8A0), fontSize: 14),
              prefixIcon:
                  Icon(icon, size: 18, color: const Color(0xFF5A7060)),
              suffixIcon: sufijo,
              filled: true,
              fillColor: enabled
                  ? const Color(0xFFF4F6EF)
                  : const Color(0xFFF0F0EE),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              errorStyle: const TextStyle(fontSize: 11),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: Color(0xFFF0F0EE));

  Widget _badgePendiente() => Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFAEEDA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('Pronto',
            style: TextStyle(
                fontSize: 10,
                color: Color(0xFF854F0B),
                fontWeight: FontWeight.w600)),
      );

  // ── Botones Restablecer / Guardar fijos abajo ───────────
  Widget _buildBotonesInferiores() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3))
        ],
      ),
      child: Row(
        children: [
          // Restablecer
          Expanded(
            child: OutlinedButton(
              onPressed: _guardando ? null : _restablecer,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2D5A1B),
                side: const BorderSide(color: Color(0xFF2D5A1B)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Restablecer',
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          // Guardar
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _guardando ? null : _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5A1B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Guardar cambios',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}