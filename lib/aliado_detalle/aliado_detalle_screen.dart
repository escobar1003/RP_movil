// lib/aliado_detalle/aliado_detalle_screen.dart

import 'package:flutter/material.dart';
import '../models/aliado_model.dart';
import '../styles/colors.dart';
import 'aliado_detalle_style.dart';

class AliadoDetalleScreen extends StatelessWidget {
  final AliadoModel aliado;

  const AliadoDetalleScreen({super.key, required this.aliado});

  static const Map<String, Color> _materialColors = {
    'Plástico': MaterialColors.blue,
    'Cartón':   MaterialColors.amber,
    'Vidrio':   MaterialColors.teal,
    'Papel':    GreenColors.medium,
    'Metal':    MaterialColors.grey,
  };

  static const Map<String, Color> _materialBgColors = {
    'Plástico': MaterialBgColors.blue,
    'Cartón':   MaterialBgColors.amber,
    'Vidrio':   MaterialBgColors.teal,
    'Papel':    GreenColors.lightBg,
    'Metal':    MaterialBgColors.grey,
  };

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
      backgroundColor: AliadoDetalleStyles.bg,
      body: CustomScrollView(
        slivers: [

          SliverAppBar(
            expandedHeight: AliadoDetalleStyles.expandedHeight,
            pinned: true,
            backgroundColor: GreenColors.dark,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [

                  Container(color: GreenColors.dark),

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

                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          width: AliadoDetalleStyles.logoSize,
                          height: AliadoDetalleStyles.logoSize,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AliadoDetalleStyles.logoRadius),
                          ),
                          child: const Icon(
                            Icons.store_rounded,
                            color: GreenColors.dark,
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

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _buildInfoCard(),
                  const SizedBox(height: 16),

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

                  _buildSection(
                    title: 'Materiales aceptados',
                    child: Column(
                      children: aliado.materiales.map((m) {
                        final color = _materialColors[m] ?? Colors.grey;
                        final bg = _materialBgColors[m] ?? Colors.grey[100]!;
                        final icon = _materialIcons[m] ?? Icons.recycling;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: AliadoDetalleStyles.materialItemPadding,
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(AliadoDetalleStyles.materialItemRadius),
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

                  SizedBox(
                    width: double.infinity,
                    height: AliadoDetalleStyles.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Próximamente: reciclar en ${aliado.nombre}'),
                            backgroundColor: GreenColors.dark,
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
                        backgroundColor: GreenColors.dark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AliadoDetalleStyles.buttonRadius),
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
            iconColor: GreenColors.dark,
            label: 'Dirección',
            value: aliado.direccion,
            isFirst: true,
          ),
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            iconColor: MaterialColors.amber,
            label: 'Horario',
            value: aliado.horario,
          ),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            iconColor: MaterialColors.blue,
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
          padding: AliadoDetalleStyles.infoRowPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AliadoDetalleStyles.infoRowIconSize,
                height: AliadoDetalleStyles.infoRowIconSize,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AliadoDetalleStyles.infoRowRadius),
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
                        color: GreenColors.veryDark,
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

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: AliadoDetalleStyles.sectionTitleSize,
            fontWeight: FontWeight.bold,
            color: GreenColors.veryDark,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
