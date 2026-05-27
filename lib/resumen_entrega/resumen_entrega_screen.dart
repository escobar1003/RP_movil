// lib/resumen_entrega/resumen_entrega_screen.dart

import 'package:flutter/material.dart';
import '../styles/colors.dart';
import 'resumen_entrega_style.dart';

class ResumenEntregaScreen extends StatelessWidget {
  final Map<String, dynamic> aliado;
  final Map<String, dynamic>? datosIA;
  final String fecha;
  final String hora;
  final String observaciones;
  final VoidCallback onConfirmar;

  const ResumenEntregaScreen({
    super.key,
    required this.aliado,
    this.datosIA,
    required this.fecha,
    required this.hora,
    required this.observaciones,
    required this.onConfirmar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResumenEntregaStyles.bg,
      appBar: AppBar(
        title: const Text('Resumen de entrega'),
        backgroundColor: GreenColors.dark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: ResumenEntregaStyles.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(ResumenEntregaStyles.iconContainerSize),
                    decoration: BoxDecoration(
                      color: GreenColors.lightBg,
                      borderRadius: BorderRadius.circular(ResumenEntregaStyles.iconContainerRadius),
                    ),
                    child: const Icon(Icons.check_circle_outline,
                        color: GreenColors.dark, size: 40),
                  ),
                  const SizedBox(height: 10),
                  const Text('Revisa los detalles de tu entrega',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: GreenColors.veryDark,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    'Confirma que toda la información sea correcta',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildSection(
              icon: Icons.store_rounded,
              color: GreenColors.dark,
              title: 'Punto de reciclaje',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(aliado['nombre'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: GreenColors.veryDark,
                      )),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: GreenColors.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          aliado['direccion'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: GreenColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            if (datosIA != null)
              _buildSection(
                icon: Icons.auto_awesome,
                color: MaterialColors.blue,
                title: 'Material a reciclar',
                child: Row(
                  children: [
                    _itemResumen('Material', datosIA!['material'] ?? '-'),
                    _itemResumen('Cantidad', datosIA!['cantidadEstimada'] ?? '-'),
                    _itemResumen('Peso', datosIA!['pesoAproximado'] ?? '-'),
                  ],
                ),
              ),

            if (datosIA != null) const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _buildSection(
                    icon: Icons.calendar_month,
                    color: MaterialColors.amber,
                    title: 'Fecha',
                    child: Text(fecha,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: GreenColors.veryDark,
                        )),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSection(
                    icon: Icons.access_time,
                    color: SemanticColors.darkGreen2,
                    title: 'Hora',
                    child: Text(hora,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: GreenColors.veryDark,
                        )),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (observaciones.isNotEmpty)
              _buildSection(
                icon: Icons.notes_rounded,
                color: SemanticColors.grey600,
                title: 'Observaciones',
                child: Text(observaciones,
                    style: const TextStyle(
                      fontSize: 14,
                      color: GreenColors.veryDark,
                      height: 1.4,
                    )),
              ),

            if (observaciones.isNotEmpty) const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: ResumenEntregaStyles.statusBannerPadding,
              decoration: BoxDecoration(
                color: MaterialBgColors.amber,
                borderRadius: BorderRadius.circular(ResumenEntregaStyles.statusBannerRadius),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(ResumenEntregaStyles.statusIconSize),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(ResumenEntregaStyles.statusIconRadius),
                    ),
                    child: const Icon(Icons.schedule, color: Colors.orange, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Estado',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const Text('Pendiente de confirmación',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: ResumenEntregaStyles.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () {
                  onConfirmar();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirmar entrega'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GreenColors.dark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResumenEntregaStyles.buttonRadius),
                  ),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: ResumenEntregaStyles.secondaryButtonHeight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Editar detalles',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color color,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: ResumenEntregaStyles.sectionPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResumenEntregaStyles.sectionRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ResumenEntregaStyles.sectionIconSize),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ResumenEntregaStyles.sectionIconRadius),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _itemResumen(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: GreenColors.veryDark,
              )),
        ],
      ),
    );
  }
}
