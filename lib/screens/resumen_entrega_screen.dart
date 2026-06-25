import 'package:flutter/material.dart';
import '../data/materiales_data.dart';

class ResumenEntregaScreen extends StatelessWidget {
  final Map<String, dynamic> aliado;
  final Map<String, dynamic>? datosIA;
  final List<Map<String, dynamic>>? materialesIA;
  final String fecha;
  final String hora;
  final String observaciones;
  final VoidCallback onConfirmar;

  const ResumenEntregaScreen({
    super.key,
    required this.aliado,
    this.datosIA,
    this.materialesIA,
    required this.fecha,
    required this.hora,
    required this.observaciones,
    required this.onConfirmar,
  });

  List<Map<String, dynamic>> get _listaMateriales =>
      materialesIA ?? (datosIA != null ? [datosIA!] : []);

  bool get _tieneMateriales => _listaMateriales.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text('Resumen de entrega'),
        backgroundColor: const Color(0xFF2D5A1B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Encabezado ──────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3DE),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(Icons.check_circle_outline,
                        color: Color(0xFF2D5A1B), size: 40),
                  ),
                  const SizedBox(height: 10),
                  const Text('Revisa los detalles de tu entrega',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A0F),
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

            // ── Punto de reciclaje ──────────────────────────
            _buildSection(
              icon: Icons.store_rounded,
              color: const Color(0xFF2D5A1B),
              title: 'Punto de reciclaje',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(aliado['nombre'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A0F),
                      )),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: Color(0xFF6B7F66)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          aliado['direccion'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7F66),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Materiales a reciclar ─────────────────────
            if (_tieneMateriales)
              _buildSection(
                icon: Icons.inventory_2_outlined,
                color: const Color(0xFF185FA5),
                title: 'Materiales a reciclar (${_listaMateriales.length})',
                child: Column(
                  children: List.generate(_listaMateriales.length, (i) {
                    final m = _listaMateriales[i];
                    return Container(
                      margin: i < _listaMateriales.length - 1 ? const EdgeInsets.only(bottom: 8) : EdgeInsets.zero,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FBF7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF3DE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.recycling, size: 18, color: Color(0xFF3B6D11)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m['material'] ?? '-',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Text('${m['cantidadEstimada']} · ${m['pesoAproximado']}',
                                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: MaterialData.nivelBg(m['nivelReciclabilidad'] ?? 'Bajo'),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(m['nivelReciclabilidad'] ?? '',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                                    color: MaterialData.nivelColor(m['nivelReciclabilidad'] ?? 'Bajo'))),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

            if (_tieneMateriales) const SizedBox(height: 14),

            // ── Fecha y hora ────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildSection(
                    icon: Icons.calendar_month,
                    color: const Color(0xFF854F0B),
                    title: 'Fecha',
                    child: Text(fecha,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E3A0F),
                        )),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSection(
                    icon: Icons.access_time,
                    color: const Color(0xFF2E7D32),
                    title: 'Hora',
                    child: Text(hora,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E3A0F),
                        )),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Observaciones ───────────────────────────────
            if (observaciones.isNotEmpty)
              _buildSection(
                icon: Icons.notes_rounded,
                color: const Color(0xFF616161),
                title: 'Observaciones',
                child: Text(observaciones,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E3A0F),
                      height: 1.4,
                    )),
              ),

            if (observaciones.isNotEmpty) const SizedBox(height: 24),

            // ── Estado ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAEEDA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
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

            // ── Botones ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  onConfirmar();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirmar entrega'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5A1B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
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
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
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
                color: Color(0xFF1E3A0F),
              )),
        ],
      ),
    );
  }
}
