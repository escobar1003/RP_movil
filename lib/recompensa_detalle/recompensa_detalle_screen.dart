// lib/recompensa_detalle/recompensa_detalle_screen.dart

import 'package:flutter/material.dart';
import '../models/recompensa_model.dart';
import '../styles/colors.dart';
import 'recompensa_detalle_style.dart';

class RecompensaDetalleScreen extends StatelessWidget {
  final RecompensaModel recompensa;

  const RecompensaDetalleScreen({super.key, required this.recompensa});

  @override
  Widget build(BuildContext context) {
    final bool esProducto = recompensa.descuentoPorcentaje == 0;

    return Scaffold(
      backgroundColor: RecompensaDetalleStyles.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: GreenColors.veryDark),
        title: Text(
          recompensa.tienda,
          style: const TextStyle(
            color: GreenColors.veryDark,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(context),
      body: SingleChildScrollView(
        child: Column(
          children: [

            _buildHero(esProducto),

            _buildInfoSection(),

            _buildCondiciones(),

            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  Widget _buildHero(bool esProducto) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: RecompensaDetalleStyles.heroPadding,
      child: Column(
        children: [

          Container(
            width: RecompensaDetalleStyles.logoSize,
            height: RecompensaDetalleStyles.logoSize,
            decoration: BoxDecoration(
              color: GreenColors.lightBg,
              borderRadius: BorderRadius.circular(RecompensaDetalleStyles.logoRadius),
            ),
            child: const Icon(Icons.store_rounded,
                color: GreenColors.dark, size: 44),
          ),

          const SizedBox(height: 20),

          esProducto
              ? const Text(
                  'Producto gratis',
                  style: TextStyle(
                    fontSize: RecompensaDetalleStyles.heroFontSize,
                    fontWeight: FontWeight.bold,
                    color: GreenColors.veryDark,
                  ),
                )
              : RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${recompensa.descuentoPorcentaje}%',
                        style: const TextStyle(
                          fontSize: RecompensaDetalleStyles.discountFontSize,
                          fontWeight: FontWeight.bold,
                          color: GreenColors.dark,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),

          const SizedBox(height: 8),

          Text(
            recompensa.descripcion,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: GreenColors.medium,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            recompensa.tienda,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),

        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: RecompensaDetalleStyles.sectionMargin,
      padding: RecompensaDetalleStyles.sectionPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RecompensaDetalleStyles.sectionRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.inventory_2_outlined,
            iconColor: MaterialColors.blue,
            label: 'Disponible',
            value: '${recompensa.disponibles} unidades',
          ),
          Divider(height: 20, color: Colors.grey.withOpacity(0.1)),
          _buildInfoRow(
            icon: Icons.stars_rounded,
            iconColor: GreenColors.light,
            label: 'Puntos necesarios',
            value: '${recompensa.puntosRequeridos} puntos',
          ),
          Divider(height: 20, color: Colors.grey.withOpacity(0.1)),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            iconColor: MaterialColors.amber,
            label: 'Válido hasta',
            value: recompensa.validoHasta,
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
  }) {
    return Row(
      children: [
        Container(
          width: RecompensaDetalleStyles.infoIconSize,
          height: RecompensaDetalleStyles.infoIconSize,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(RecompensaDetalleStyles.infoIconRadius),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: GreenColors.veryDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildCondiciones() {
    return Container(
      margin: RecompensaDetalleStyles.sectionMargin.copyWith(top: 14),
      padding: RecompensaDetalleStyles.sectionPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RecompensaDetalleStyles.sectionRadius),
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
          const Text(
            'Condiciones',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: GreenColors.veryDark,
            ),
          ),
          const SizedBox(height: 14),
          ...recompensa.condiciones.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 16, color: GreenColors.light),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      c,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: RecompensaDetalleStyles.bottomPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: RecompensaDetalleStyles.buttonHeight,
        child: ElevatedButton(
          onPressed: () {
            _mostrarConfirmacion(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: GreenColors.dark,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RecompensaDetalleStyles.buttonRadius),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.card_giftcard_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                'Canjear por ${recompensa.puntosRequeridos} puntos',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarConfirmacion(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(RecompensaDetalleStyles.modalRadius)),
      ),
      builder: (_) => Padding(
        padding: RecompensaDetalleStyles.modalPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              width: RecompensaDetalleStyles.handleWidth,
              height: RecompensaDetalleStyles.handleHeight,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(RecompensaDetalleStyles.handleRadius),
              ),
            ),

            const SizedBox(height: 24),

            const Icon(Icons.stars_rounded,
                size: RecompensaDetalleStyles.modalIconSize, color: GreenColors.light),

            const SizedBox(height: 16),

            const Text(
              '¿Confirmar canje?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: GreenColors.veryDark,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Se descontarán ${recompensa.puntosRequeridos} puntos\nde tu saldo actual',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: RecompensaDetalleStyles.modalButtonHeight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Canje realizado con éxito! 🎉'),
                      backgroundColor: GreenColors.dark,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GreenColors.dark,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RecompensaDetalleStyles.modalButtonRadius),
                  ),
                ),
                child: const Text(
                  'Sí, canjear',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: RecompensaDetalleStyles.modalButtonHeight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
