import 'package:flutter/material.dart';
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
  String _correo = '';
  String _rol = '';
  String _telefono = '';
  int _reciclajes = 0;
  int _puntos = 0;
  int _canjesCount = 0;
  int _puntosGanados = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    _nombre = await AuthService.getNombre();
    _correo = await AuthService.getCorreo();
    _rol = await AuthService.getRol();
    _telefono = await AuthService.getTelefono();

    try {
      final perfil = await UsuarioService.getPerfil();
      if (perfil['nombre'] != null) _nombre = perfil['nombre'];
      if (perfil['correo'] != null) _correo = perfil['correo'];
      if (perfil['rol'] != null) _rol = perfil['rol'];
      if (perfil['telefono'] != null) _telefono = perfil['telefono'];
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

    if (mounted) setState(() {});
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
        child: SingleChildScrollView(
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF2D5A1B),
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
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 52),
              ),
              Positioned(
                bottom: 0,
                right: 0,
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
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _nombre,
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
                color: Colors.white.withOpacity(0.65),
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF7BC043),
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
              iconColor: const Color(0xFF2D5A1B),
              iconBg: const Color(0xFFEAF3DE),
              value: '$_reciclajes',
              label: 'Reciclajes',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              icon: Icons.stars_rounded,
              iconColor: const Color(0xFF854F0B),
              iconBg: const Color(0xFFFAEEDA),
              value: '$_puntos',
              label: 'Puntos',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              icon: Icons.emoji_events_outlined,
              iconColor: const Color(0xFF185FA5),
              iconBg: const Color(0xFFE6F1FB),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildProgreso() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                  color: Color(0xFF1E3A0F),
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
              backgroundColor: Color(0xFFEAF3DE),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7BC043)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
            color: const Color(0xFF2D5A1B),
            bg: const Color(0xFFEAF3DE),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditarPerfilScreen()),
              );
              _cargarDatos();
            },
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 60),

          _buildMenuRow(
            icon: Icons.history,
            label: 'Mis entregas',
            color: const Color(0xFF185FA5),
            bg: const Color(0xFFE6F1FB),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HistorialEntregasScreen(),
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 60),

          _buildMenuRow(
            icon: Icons.card_giftcard_outlined,
            label: 'Mis canjes',
            color: const Color(0xFF854F0B),
            bg: const Color(0xFFFAEEDA),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MisCanjesScreen()),
            ),
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 60),

          _buildMenuRow(
            icon: Icons.notifications_outlined,
            label: 'Notificaciones',
            color: const Color(0xFF0F6E56),
            bg: const Color(0xFFE1F5EE),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificacionesScreen()),
            ),
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 60),

          _buildMenuRow(
            icon: Icons.settings_outlined,
            label: 'Configuración',
            color: const Color(0xFF5F5E5A),
            bg: const Color(0xFFF1EFE8),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConfiguracionScreen()),
            ),
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 60),

          _buildMenuRow(
            icon: Icons.help_outline,
            label: 'Ayuda',
            color: const Color(0xFF5F5E5A),
            bg: const Color(0xFFF1EFE8),
            onTap: () {},
          ),

          Divider(height: 1, color: Colors.grey.withOpacity(0.15)),

          _buildMenuRow(
            icon: Icons.logout,
            label: 'Cerrar sesión',
            color: const Color(0xFFA32D2D),
            bg: const Color(0xFFFCEBEB),
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
