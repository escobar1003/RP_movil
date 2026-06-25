import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../models/recompensa_model.dart';

class RecompensaDetalleScreen extends StatelessWidget {
  final RecompensaModel recompensa;

  const RecompensaDetalleScreen({super.key, required this.recompensa});

  @override
  Widget build(BuildContext context) {
    final r = recompensa;
    final esProducto = r.tipoRecompensa?.toLowerCase() == 'producto';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6EF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A0F)),
        title: Text(
          r.aliado ?? 'Recompensa',
          style: const TextStyle(
            color: Color(0xFF1E3A0F),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
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
    final r = recompensa;
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3DE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              esProducto ? BootstrapIcons.gift : BootstrapIcons.percent,
              color: const Color(0xFF2D5A1B), size: 44,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            r.nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A0F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            r.descripcion ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
          ),
          if (r.aliado != null) ...[
            const SizedBox(height: 4),
            Text(
              r.aliado!,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final r = recompensa;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: BootstrapIcons.box_seam,
            iconColor: const Color(0xFF185FA5),
            label: 'Disponible',
            value: r.stock != null ? '${r.stock} unidades' : 'Ilimitado',
          ),
          Divider(height: 20, color: Colors.grey.withValues(alpha: 0.1)),
          _buildInfoRow(
            icon: BootstrapIcons.star_fill,
            iconColor: const Color(0xFF7BC043),
            label: 'Puntos necesarios',
            value: '${r.puntosRequeridos} puntos',
          ),
          if (r.fechaFin != null) ...[
            Divider(height: 20, color: Colors.grey.withValues(alpha: 0.1)),
            _buildInfoRow(
              icon: BootstrapIcons.calendar,
              iconColor: const Color(0xFF854F0B),
              label: 'Válido hasta',
              value: r.fechaFin!,
            ),
          ],
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
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
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

  Widget _buildCondiciones() {
    final r = recompensa;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A0F),
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoDot('Tipo: ${r.tipoRecompensa ?? "No especificado"}'),
          _buildInfoDot('Puntos requeridos: ${r.puntosRequeridos}'),
          if (r.stock != null) _buildInfoDot('Stock disponible: ${r.stock}'),
          if (r.fechaInicio != null) _buildInfoDot('Inicia: ${r.fechaInicio}'),
          if (r.fechaFin != null) _buildInfoDot('Vence: ${r.fechaFin}'),
        ],
      ),
    );
  }

  Widget _buildInfoDot(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(BootstrapIcons.check_circle, size: 16, color: Color(0xFF7BC043)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
              style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
