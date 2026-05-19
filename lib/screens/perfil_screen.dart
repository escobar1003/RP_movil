// lib/screens/perfil_screen.dart

import 'dart:typed_data'; // ← para manejar bytes de imagen en web
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'historial_entregas_screen.dart';
import 'mis_canjes_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {

  // ── En web usamos bytes en lugar de File ─────────────────
  Uint8List? _fotoBytes;

  final ImagePicker _picker = ImagePicker();

  Future<void> _elegirFoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Foto de perfil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A0F),
                ),
              ),

              const SizedBox(height: 16),

              ListTile(
                leading: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3DE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: Color(0xFF2D5A1B)),
                ),
                title: const Text('Elegir de la galería'),
                onTap: () async {
                  Navigator.pop(context);
                  await _tomarFoto(ImageSource.gallery);
                },
              ),

              ListTile(
                leading: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F1FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: Color(0xFF185FA5)),
                ),
                title: const Text('Tomar una foto'),
                onTap: () async {
                  Navigator.pop(context);
                  await _tomarFoto(ImageSource.camera);
                },
              ),

              if (_fotoBytes != null)
                ListTile(
                  leading: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCEBEB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: Color(0xFFA32D2D)),
                  ),
                  title: const Text(
                    'Eliminar foto',
                    style: TextStyle(color: Color(0xFFA32D2D)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _fotoBytes = null);
                  },
                ),

            ],
          ),
        ),
      ),
    );
  }

  Future<void> _tomarFoto(ImageSource source) async {
    try {
      final XFile? imagen = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 512,
      );

      if (imagen == null) return;

      // ── En web leemos los bytes directamente ─────────────
      final bytes = await imagen.readAsBytes();

      setState(() {
        _fotoBytes = bytes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo acceder a las fotos'),
            backgroundColor: Color(0xFFA32D2D),
          ),
        );
      }
    }
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

          GestureDetector(
            onTap: _elegirFoto,
            child: Stack(
              children: [

                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7BC043),
                    borderRadius: BorderRadius.circular(45),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(45),
                    child: _fotoBytes != null
                        // ── Web: usa Image.memory con los bytes ──
                        ? Image.memory(
                            _fotoBytes!,
                            fit: BoxFit.cover,
                            width: 90,
                            height: 90,
                          )
                        : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 52,
                          ),
                  ),
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
                      border: Border.all(
                        color: const Color(0xFF2D5A1B),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 15,
                      color: Color(0xFF2D5A1B),
                    ),
                  ),
                ),

              ],
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Ana Martínez',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF7BC043),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco, size: 14, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  'Flor Verde',
                  style: TextStyle(
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
              value: '23',
              label: 'Reciclajes',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              icon: Icons.stars_rounded,
              iconColor: const Color(0xFF854F0B),
              iconBg: const Color(0xFFFAEEDA),
              value: '2,560',
              label: 'Puntos',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              icon: Icons.emoji_events_outlined,
              iconColor: const Color(0xFF185FA5),
              iconBg: const Color(0xFFE6F1FB),
              value: '4',
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
                '2,560 / 3,000 pts',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.85,
              minHeight: 9,
              backgroundColor: Color(0xFFEAF3DE),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7BC043)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Te faltan 440 puntos para alcanzar el nivel Árbol',
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
            onTap: () {},
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 60),

          _buildMenuRow(
            icon: Icons.history,
            label: 'Mis entregas',
            color: const Color(0xFF185FA5),
            bg: const Color(0xFFE6F1FB),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HistorialEntregasScreen())),
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 60),

          _buildMenuRow(
            icon: Icons.card_giftcard_outlined,
            label: 'Mis canjes',
            color: const Color(0xFF854F0B),
            bg: const Color(0xFFFAEEDA),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MisCanjesScreen())),
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 60),

          _buildMenuRow(
            icon: Icons.notifications_outlined,
            label: 'Notificaciones',
            color: const Color(0xFF0F6E56),
            bg: const Color(0xFFE1F5EE),
            onTap: () {},
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 60),

          _buildMenuRow(
            icon: Icons.settings_outlined,
            label: 'Configuración',
            color: const Color(0xFF5F5E5A),
            bg: const Color(0xFFF1EFE8),
            onTap: () {},
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
            onTap: () {},
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
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}