import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/usuario_service.dart';
import 'historial_entregas_screen.dart';
import 'mis_canjes_screen.dart';
import 'editar_perfil_screen.dart';
import 'welcome_screen.dart';
import 'configuracion_screen.dart';
import 'notificaciones_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String _nombre = '';
  String _apellido = '';
  String _correo = '';
  String _rol = '';
  String _telefono = '';
  int _reciclajes = 0;
  int _puntos = 0;
  int _canjesCount = 0;
  int _puntosGanados = 0;
  String? _fotoPath; // ← MODIFICADO: ruta de la foto local
  String? _fotoUrl;  // ← NUEVO: URL de Cloudinary

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    _nombre = await AuthService.getNombre();
    _apellido = await AuthService.getApellido();
    _correo = await AuthService.getCorreo();
    _rol = await AuthService.getRol();
    _telefono = await AuthService.getTelefono();

    try {
      final perfil = await UsuarioService.getPerfil();
      final u = perfil['usuario'] ?? perfil;
      if (u['nombre'] != null) _nombre = u['nombre'];
      if (u['apellido'] != null) _apellido = u['apellido'];
      if (u['correo'] != null) _correo = u['correo'];
      if (u['rol'] != null) _rol = u['rol'];
      if (u['telefono'] != null) _telefono = u['telefono'];
      if (u['imagen'] != null) _fotoUrl = u['imagen'];
    } catch (_) {}

    try {
      final puntos = await UsuarioService.getResumenPuntos();
      _puntos = puntos['saldo'] ?? 0;
      _puntosGanados = puntos['ganados'] ?? 0;
    } catch (_) {}

    try {
      final entregas = await UsuarioService.getEntregas();
      _reciclajes = (entregas['entregas'] as List?)?.length ?? 0;
    } catch (_) {}

    try {
      final canjes = await UsuarioService.getCanjes();
      _canjesCount = (canjes['canjes'] as List?)?.length ?? 0;
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('foto_perfil_path');
    if (!kIsWeb && savedPath != null && File(savedPath).existsSync()) {
      _fotoPath = savedPath;
    }

    if (mounted) setState(() {});
  }

  Future<void> _cambiarFoto() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Cambiar foto de perfil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 600,
    );
    if (picked == null) return;

    try {
      if (!kIsWeb) {
        final res = await UsuarioService.updateFotoPerfil(picked.path);
        if (mounted && (res['status'] == 'error' || res['error'] != null)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['mensaje'] ?? res['error'] ?? 'Error al subir foto'), backgroundColor: Colors.orange),
          );
        }
      } else {
        final bytes = await picked.readAsBytes();
        final res = await UsuarioService.updateFotoPerfilBytes(bytes, 'foto_perfil.jpg');
        if (mounted && (res['status'] == 'error' || res['error'] != null)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['mensaje'] ?? res['error'] ?? 'Error al subir foto'), backgroundColor: Colors.orange),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir foto: $e'), backgroundColor: Colors.red),
        );
      }
    }

    if (mounted) _cargarDatos();
  }

  Future<void> _cerrarSesion() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6EF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargarDatos,
          child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context),
              _buildStats(),
              const SizedBox(height: 20),
              _buildProgreso(),
              const SizedBox(height: 20),
              _buildMenu(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // Fondo verde
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.fromARGB(255, 20, 125, 35), Color.fromARGB(255, 46, 158, 55), Color.fromARGB(255, 30, 220, 40), Color.fromARGB(255, 170, 225, 90)],
                stops: [0.0, 0.35, 0.6, 1.0],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                  Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7BC043),
                          borderRadius: BorderRadius.circular(45),
                          border: Border.all(color: const Color.fromARGB(255, 255, 255, 255), width: 3),
                          image: _fotoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(_fotoUrl!),
                                  fit: BoxFit.cover)
                              : (!kIsWeb && _fotoPath != null
                                  ? DecorationImage(
                                      image: FileImage(File(_fotoPath!)),
                                      fit: BoxFit.cover)
                                   : null),
                          ),
                        child: _fotoUrl == null && (!kIsWeb ? _fotoPath == null : true)
                            ? const Icon(Icons.person, color: Colors.white, size: 52)
                            : null,
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _cambiarFoto,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            size: 16,
                            color: Color(0xFF2D5A1B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '$_nombre $_apellido'.trim(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_correo.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _correo,
                    style: TextStyle(
                      color: const Color.fromARGB(66, 46, 5, 5).withValues(alpha: 0.65),
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 123, 241, 26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.eco, size: 14, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        _rol == 'admin' ? 'Administrador' : 'Flor Verde',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Hoja superior izquierda ──
          Positioned(
            top: 8,
            left: 8,
            child: Transform.rotate(
              angle: -0.3,
              child: Icon(
                Icons.eco,
                size: 28,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
          // ── Hoja grande lateral izquierdo ──
          Positioned(
            top: 60,
            left: -16,
            child: Transform.rotate(
              angle: -0.8,
              child: Icon(
                Icons.eco,
                size: 64,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          // ── Hoja grande esquina inferior derecha ──
          Positioned(
            bottom: -10,
            right: -14,
            child: Transform.rotate(
              angle: 2.0,
              child: Icon(
                Icons.eco,
                size: 72,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          // ── Líneas curvas de viento ──
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _WindPainter(
                  color: const Color.fromARGB(255, 238, 227, 227).withValues(alpha: 0.07),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.recycling,
              iconColor: const Color.fromARGB(255, 38, 118, 6),
              iconBg: const Color.fromARGB(255, 202, 237, 160),
              value: '$_reciclajes',
              label: 'Reciclajes',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              icon: Icons.stars_rounded,
              iconColor: const Color.fromARGB(255, 32, 33, 4),
              iconBg: const Color.fromARGB(255, 234, 234, 17),
              value: '$_puntos',
              label: 'Puntos',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              icon: Icons.emoji_events_outlined,
              iconColor: const Color.fromARGB(255, 15, 109, 202),
              iconBg: const Color.fromARGB(184, 173, 207, 239),
              value: '$_canjesCount',
              label: 'Canjes',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(238, 223, 244, 221),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A0F),
            ),
          ),
          Text(label, style: TextStyle(fontSize: 11, color: const Color.fromARGB(255, 135, 132, 132))),
        ],
      ),
    );
  }

  Widget _buildProgreso() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color.fromARGB(240, 231, 243, 228),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tu progreso',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 38, 54, 29),
                ),
              ),
              Text(
                '$_puntos / 3,000 pts',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_puntos / 3000).clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: Color.fromARGB(255, 241, 247, 234),
              valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(181, 89, 134, 53)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza a reciclar para ganar puntos y subir de nivel',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(235, 230, 238, 227),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuRow(
            icon: Icons.person_outline,
            label: 'Editar perfil',
            color: const Color.fromARGB(255, 5, 9, 3),
            bg: const Color.fromARGB(255, 203, 209, 197),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditarPerfilScreen()),
              );
              _cargarDatos();
            },
          ),
          Divider(height: 1, color: const Color.fromARGB(255, 83, 82, 82).withValues(alpha: 0.1), indent: 60),

          _buildMenuRow(
            icon: Icons.history,
            label: 'Mis entregas',
            color: const Color.fromARGB(255, 3, 71, 140),
            bg: const Color(0xFFE6F1FB),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HistorialEntregasScreen(),
              ),
            ),
          ),
          Divider(height: 1, color: const Color.fromARGB(255, 87, 86, 86).withValues(alpha: 0.1), indent: 60),

          _buildMenuRow(
            icon: Icons.card_giftcard_outlined,
            label: 'Mis canjes',
            color: const Color.fromARGB(255, 218, 122, 5),
            bg: const Color.fromARGB(255, 243, 233, 215),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MisCanjesScreen()),
            ),
          ),
          Divider(height: 1, color: const Color.fromARGB(255, 106, 104, 104).withValues(alpha: 0.1), indent: 60),

          _buildMenuRow(
            icon: Icons.settings_outlined,
            label: 'Configuración',
            color: const Color.fromARGB(255, 3, 3, 3),
            bg: const Color.fromARGB(255, 234, 234, 229),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConfiguracionScreen()),
            ),
          ),
          Divider(height: 1, color: const Color.fromARGB(255, 96, 93, 93).withValues(alpha: 0.1), indent: 60),

          _buildMenuRow(
            icon: Icons.logout,
            label: 'Cerrar sesión',
            color: const Color.fromARGB(255, 212, 7, 7),
            bg: const Color.fromARGB(255, 197, 191, 191),
            onTap: _cerrarSesion,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E3A0F),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

class _WindPainter extends CustomPainter {
  final Color color;
  _WindPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(size.width * -0.1, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.3, size.height * 0.05,
        size.width * 0.7, size.height * 0.2,
      );
    canvas.drawPath(path1, paint);

    final path2 = Path()
      ..moveTo(size.width * 0.3, size.height * 0.1)
      ..quadraticBezierTo(
        size.width * 0.6, size.height * 0.25,
        size.width * 0.9, size.height * 0.15,
      );
    canvas.drawPath(path2, paint);

    final path3 = Path()
      ..moveTo(size.width * 0.5, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.75, size.height * 0.6,
        size.width * 1.1, size.height * 0.75,
      );
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
