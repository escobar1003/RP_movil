// lib/perfil/perfil_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../styles/colors.dart';
import '../historial_entregas/historial_entregas_screen.dart';
import '../mis_canjes/mis_canjes_screen.dart';
import '../welcome/welcome_screen.dart';
import '../editar_perfil/editar_perfil_screen.dart';
import 'perfil_style.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String _nombre = '';
  String _correo = '';
  String _rol = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final nombre = await AuthService.getNombre();
    final correo = await AuthService.getCorreo();
    final rol = await AuthService.getRol();
    if (mounted) {
      setState(() {
        _nombre = nombre;
        _correo = correo;
        _rol = rol;
      });
    }
  }

  Future<void> _cerrarSesion() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PerfilStyles.bg,
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
      padding: PerfilStyles.headerPadding,
      decoration: const BoxDecoration(
        color: GreenColors.dark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(PerfilStyles.headerRadius),
          bottomRight: Radius.circular(PerfilStyles.headerRadius),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: PerfilStyles.avatarSize,
                height: PerfilStyles.avatarSize,
                decoration: BoxDecoration(
                  color: GreenColors.light,
                  borderRadius: BorderRadius.circular(PerfilStyles.avatarRadius),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 52),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: PerfilStyles.cameraSize,
                  height: PerfilStyles.cameraSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(PerfilStyles.cameraRadius),
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      size: 16, color: GreenColors.dark),
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
            padding: PerfilStyles.roleBadgePadding,
            decoration: BoxDecoration(
              color: GreenColors.light,
              borderRadius: BorderRadius.circular(PerfilStyles.roleBadgeRadius),
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
      padding: PerfilStyles.statsPadding,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.recycling,
              iconColor: GreenColors.dark,
              iconBg: GreenColors.lightBg,
              value: '0',
              label: 'Reciclajes',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              icon: Icons.stars_rounded,
              iconColor: MaterialColors.amber,
              iconBg: MaterialBgColors.amber,
              value: '0',
              label: 'Puntos',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              icon: Icons.emoji_events_outlined,
              iconColor: MaterialColors.blue,
              iconBg: MaterialBgColors.blue,
              value: '0',
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
      padding: PerfilStyles.statCardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PerfilStyles.statCardRadius),
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
            width: PerfilStyles.statIconSize,
            height: PerfilStyles.statIconSize,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(PerfilStyles.statIconRadius),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: GreenColors.veryDark,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildProgreso() {
    return Container(
      margin: PerfilStyles.progresoMargin,
      padding: PerfilStyles.progresoPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PerfilStyles.progresoRadius),
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
                  color: GreenColors.veryDark,
                ),
              ),
              Text(
                '0 / 3,000 pts',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0,
              minHeight: 9,
              backgroundColor: GreenColors.lightBg,
              valueColor: AlwaysStoppedAnimation<Color>(GreenColors.light),
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
      margin: PerfilStyles.menuMargin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PerfilStyles.menuRadius),
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
            color: GreenColors.dark,
            bg: GreenColors.lightBg,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditarPerfilScreen()),
            ),
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 60),

          _buildMenuRow(
            icon: Icons.history,
            label: 'Mis entregas',
            color: MaterialColors.blue,
            bg: MaterialBgColors.blue,
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
            color: MaterialColors.amber,
            bg: MaterialBgColors.amber,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MisCanjesScreen(),
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 60),

          _buildMenuRow(
            icon: Icons.notifications_outlined,
            label: 'Notificaciones',
            color: MaterialColors.teal,
            bg: MaterialBgColors.teal,
            onTap: () {},
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 60),

          _buildMenuRow(
            icon: Icons.settings_outlined,
            label: 'Configuración',
            color: MaterialColors.grey,
            bg: MaterialBgColors.grey,
            onTap: () {},
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 60),

          _buildMenuRow(
            icon: Icons.help_outline,
            label: 'Ayuda',
            color: MaterialColors.grey,
            bg: MaterialBgColors.grey,
            onTap: () {},
          ),

          Divider(height: 1, color: Colors.grey.withOpacity(0.15)),

          _buildMenuRow(
            icon: Icons.logout,
            label: 'Cerrar sesión',
            color: SemanticColors.errorRed,
            bg: MaterialBgColors.red,
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
      borderRadius: BorderRadius.circular(PerfilStyles.menuRadius),
      child: Padding(
        padding: PerfilStyles.menuRowPadding,
        child: Row(
          children: [
            Container(
              width: PerfilStyles.menuIconSize,
              height: PerfilStyles.menuIconSize,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(PerfilStyles.menuIconRadius),
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
                  color: GreenColors.veryDark,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
