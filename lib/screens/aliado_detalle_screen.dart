// lib/screens/aliado_detalle_screen.dart

import 'package:flutter/material.dart';
import '../models/aliado_model.dart';

class AliadoDetalleScreen extends StatelessWidget {
  // Recibimos el aliado completo desde la pantalla anterior
  final AliadoModel aliado;

  const AliadoDetalleScreen({super.key, required this.aliado});

  static const Map<String, Color> _materialColors = {
    'Plástico': Color(0xFF185FA5),
    'Cartón':   Color(0xFF854F0B),
    'Vidrio':   Color(0xFF0F6E56),
    'Papel':    Color(0xFF3B6D11),
    'Metal':    Color(0xFF5F5E5A),
  };

  static const Map<String, Color> _materialBgColors = {
    'Plástico': Color(0xFFE6F1FB),
    'Cartón':   Color(0xFFFAEEDA),
    'Vidrio':   Color(0xFFE1F5EE),
    'Papel':    Color(0xFFEAF3DE),
    'Metal':    Color(0xFFF1EFE8),
  };

  // Ícono por material
  static const Map<String, IconData> _materialIcons = {
    'Plástico': Icons.water_drop_outlined,
    'Cartón':   Icons.inventory_2_outlined,
    'Vidrio':   Icons.wine_bar_outlined,
    'Papel':    Icons.description_outlined,
    'Metal':    Icons.hardware_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6EF),
      body: CustomScrollView(
        slivers: [

          // ── AppBar con imagen de fondo verde ──────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true, // ← se queda visible al hacer scroll
            backgroundColor: const Color(0xFF2D5A1B),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [

                  // Fondo verde con patrón
                  Container(color: const Color(0xFF2D5A1B)),

                  // Decoración de hojas
                  Positioned(
                    right: 20,
                    top: 40,
                    child: Icon(Icons.eco,
                        size: 120,
                        color: Colors.white.withOpacity(0.07)),
                  ),
                  Positioned(
                    left: -20,
                    bottom: 0,
                    child: Icon(Icons.eco,
                        size: 80,
                        color: Colors.white.withOpacity(0.05)),
                  ),

                  // Logo del supermercado centrado
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.store_rounded,
                            color: Color(0xFF2D5A1B),
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          aliado.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),

          // ── Contenido ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Info rápida ─────────────────────────────
                  _buildInfoCard(),
                  const SizedBox(height: 16),

                  // ── Descripción ─────────────────────────────
                  _buildSection(
                    title: 'Sobre este punto',
                    child: Text(
                      aliado.descripcion,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Materiales aceptados ────────────────────
                  _buildSection(
                    title: 'Materiales aceptados',
                    child: Column(
                      children: aliado.materiales.map((m) {
                        final color = _materialColors[m] ?? Colors.grey;
                        final bg = _materialBgColors[m] ?? Colors.grey[100]!;
                        final icon = _materialIcons[m] ?? Icons.recycling;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(icon, color: color, size: 22),
                              const SizedBox(width: 12),
                              Text(
                                m,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.check_circle_outline,
                                  color: color, size: 18),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ── Botón reciclar aquí ─────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: navegar a selección de materiales
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Próximamente: reciclar en ${aliado.nombre}'),
                            backgroundColor: const Color(0xFF2D5A1B),
                          ),
                        );
                      },
                      icon: const Icon(Icons.recycling),
                      label: const Text(
                        'Reciclar aquí',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5A1B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  // ── Tarjeta de info rápida (dirección, horario, teléfono)
  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            iconColor: const Color(0xFF2D5A1B),
            label: 'Dirección',
            value: aliado.direccion,
            isFirst: true,
          ),
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFF854F0B),
            label: 'Horario',
            value: aliado.horario,
          ),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            iconColor: const Color(0xFF185FA5),
            label: 'Teléfono',
            value: aliado.telefono,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        if (!isFirst)
          Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.1),
            indent: 56,
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1E3A0F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Sección con título ───────────────────────────────────
  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A0F),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}