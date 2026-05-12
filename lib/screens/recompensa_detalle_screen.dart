// lib/screens/recompensa_detalle_screen.dart

import 'package:flutter/material.dart';
import '../models/recompensa_model.dart';

class RecompensaDetalleScreen extends StatelessWidget {
  final RecompensaModel recompensa;

  const RecompensaDetalleScreen({super.key, required this.recompensa});

  @override
  Widget build(BuildContext context) {
    final bool esProducto = recompensa.descuentoPorcentaje == 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6EF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A0F)),
        title: Text(
          recompensa.tienda,
          style: const TextStyle(
            color: Color(0xFF1E3A0F),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      // ── Botón fijo al fondo ──────────────────────────────
      bottomNavigationBar: _buildBottomButton(context),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ── Bloque hero del descuento ──────────────────
            _buildHero(esProducto),

            // ── Disponibilidad ─────────────────────────────
            _buildInfoSection(),

            // ── Condiciones ────────────────────────────────
            _buildCondiciones(),

            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  // ── HERO: descuento grande centrado ─────────────────────
  Widget _buildHero(bool esProducto) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [

          // Logo tienda
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3DE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.store_rounded,
                color: Color(0xFF2D5A1B), size: 44),
          ),

          const SizedBox(height: 20),

          // Descuento grande
          esProducto
              ? const Text(
                  'Producto gratis',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A0F),
                  ),
                )
              : RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${recompensa.descuentoPorcentaje}%',
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D5A1B),
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
              color: Color(0xFF3B6D11),
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

  // ── INFO: disponibilidad y puntos ───────────────────────
  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
            iconColor: const Color(0xFF185FA5),
            label: 'Disponible',
            value: '${recompensa.disponibles} unidades',
          ),
          Divider(height: 20, color: Colors.grey.withOpacity(0.1)),
          _buildInfoRow(
            icon: Icons.stars_rounded,
            iconColor: const Color(0xFF7BC043),
            label: 'Puntos necesarios',
            value: '${recompensa.puntosRequeridos} puntos',
          ),
          Divider(height: 20, color: Colors.grey.withOpacity(0.1)),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            iconColor: const Color(0xFF854F0B),
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
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
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
                    color: Color(0xFF1E3A0F))),
          ],
        ),
      ],
    );
  }

  // ── CONDICIONES ─────────────────────────────────────────
  Widget _buildCondiciones() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
              color: Color(0xFF1E3A0F),
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
                      size: 16, color: Color(0xFF7BC043)),
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

  // ── BOTÓN FIJO AL FONDO ──────────────────────────────────
  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
        height: 54,
        child: ElevatedButton(
          onPressed: () {
            _mostrarConfirmacion(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D5A1B),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
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

  // ── MODAL de confirmación de canje ───────────────────────
  void _mostrarConfirmacion(BuildContext context) {
    showModalBottomSheet(
      context: context,
      // ← permite que el modal tenga esquinas redondeadas
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Línea handle
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            const Icon(Icons.stars_rounded,
                size: 52, color: Color(0xFF7BC043)),

            const SizedBox(height: 16),

            const Text(
              '¿Confirmar canje?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A0F),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Se descontarán ${recompensa.puntosRequeridos} puntos\nde tu saldo actual',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),

            const SizedBox(height: 28),

            // Botón confirmar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // cierra el modal
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Canje realizado con éxito! 🎉'),
                      backgroundColor: Color(0xFF2D5A1B),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5A1B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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

            // Botón cancelar
            SizedBox(
              width: double.infinity,
              height: 50,
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