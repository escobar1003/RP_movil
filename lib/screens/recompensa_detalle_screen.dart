import 'package:flutter/material.dart';
import '../models/recompensa_model.dart';
import '../services/usuario_service.dart';

class RecompensaDetalleScreen extends StatefulWidget {
  final RecompensaModel recompensa;

  const RecompensaDetalleScreen({super.key, required this.recompensa});

  @override
  State<RecompensaDetalleScreen> createState() => _RecompensaDetalleScreenState();
}

class _RecompensaDetalleScreenState extends State<RecompensaDetalleScreen> {
  bool _canjeando = false;

  Future<void> _canjear() async {
    setState(() => _canjeando = true);
    try {
      await UsuarioService.canjearRecompensa(widget.recompensa.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Canje realizado con éxito!'),
            backgroundColor: Color(0xFF2D5A1B),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _canjeando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.recompensa;
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
    final r = widget.recompensa;
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
              esProducto ? Icons.card_giftcard : Icons.store_rounded,
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
    final r = widget.recompensa;
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
            icon: Icons.inventory_2_outlined,
            iconColor: const Color(0xFF185FA5),
            label: 'Disponible',
            value: r.stock != null ? '${r.stock} unidades' : 'Ilimitado',
          ),
          Divider(height: 20, color: Colors.grey.withValues(alpha: 0.1)),
          _buildInfoRow(
            icon: Icons.stars_rounded,
            iconColor: const Color(0xFF7BC043),
            label: 'Puntos necesarios',
            value: '${r.puntosRequeridos} puntos',
          ),
          if (r.fechaFin != null) ...[
            Divider(height: 20, color: Colors.grey.withValues(alpha: 0.1)),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
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
    final r = widget.recompensa;
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
          const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF7BC043)),
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

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _canjeando ? null : () => _mostrarConfirmacion(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D5A1B),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _canjeando
              ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.card_giftcard_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Canjear por ${widget.recompensa.puntosRequeridos} puntos',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
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
            const SizedBox(height: 24),
            const Icon(Icons.stars_rounded, size: 52, color: Color(0xFF7BC043)),
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
              'Se descontarán ${widget.recompensa.puntosRequeridos} puntos\nde tu saldo actual',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _canjeando ? null : _canjear,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5A1B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _canjeando
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Sí, canjear',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}