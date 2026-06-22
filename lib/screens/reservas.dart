import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'resumen_entrega_screen.dart';
import '../services/api_service.dart';

class ReservasScreen extends StatefulWidget {
  final Map<String, dynamic> aliado;
  final Map<String, dynamic>? datosIA;

  const ReservasScreen({
    super.key,
    required this.aliado,
    this.datosIA,
  });

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  final TextEditingController observacionesController = TextEditingController();

  bool loading = false;

  DateTime _fechaSeleccionada = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _horaSeleccionada = const TimeOfDay(hour: 10, minute: 0);

  List<MaterialSeleccionado> materiales = [];

  @override
  void initState() {
    super.initState();

   

    if (widget.datosIA != null) {
      final material = (widget.datosIA!['tipo'] ?? '').toString().toLowerCase();
      for (var m in materiales) {
        if (material.contains(m.nombre.toLowerCase())) {
          m.seleccionado = true;
          break;
        }
      }
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _fechaSeleccionada = picked);
  }

  Future<void> _seleccionarHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada,
    );
    if (picked != null) setState(() => _horaSeleccionada = picked);
  }

  String get _fechaFormateada {
    final d = _fechaSeleccionada;
    final meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${d.day} ${meses[d.month - 1]} ${d.year}';
  }

  String get _horaFormateada {
    final h = _horaSeleccionada;
    final hora = h.hour.toString().padLeft(2, '0');
    final min = h.minute.toString().padLeft(2, '0');
    return '$hora:$min';
  }

  Future<void> _confirmarReserva() async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ResumenEntregaScreen(
        aliado: widget.aliado,
        datosIA: widget.datosIA,
        fecha: _fechaFormateada,
        hora: _horaFormateada,
        observaciones: observacionesController.text,
        onConfirmar: () async {
          setState(() => loading = true);
          try {
            final resultado = await ApiService.post(
              '/usuario/reservas',
              body: {
                'idPunto': widget.aliado['idPunto'] ?? widget.aliado['id'],
                'fecha': '${_fechaSeleccionada.year}-${_fechaSeleccionada.month.toString().padLeft(2,'0')}-${_fechaSeleccionada.day.toString().padLeft(2,'0')}',
                'hora': _horaFormateada,
                'notas': observacionesController.text,
              },
            );
            if (!mounted) return;
            setState(() => loading = false);
            final exito = resultado['idReserva'] != null || resultado['mensaje'] != null;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: exito ? const Color(0xFFEAF3DE) : const Color(0xFFFFEBEB),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        exito ? Icons.check_circle : Icons.error_outline,
                        color: exito ? const Color(0xFF3B6D11) : Colors.red,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(exito ? '¡Reserva confirmada!' : 'Error al reservar',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      exito ? 'Pendiente de confirmación por el encargado.' : resultado['message'] ?? 'Intenta de nuevo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (exito) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            );
          } catch (e) {
            if (!mounted) return;
            setState(() => loading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
            );
          }
        },
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7F5),
      appBar: AppBar(
        title: const Text('Reservar entrega'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Punto de reciclaje ────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3DE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.store_rounded, color: Color(0xFF3B6D11), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.aliado['nombre'],
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(BootstrapIcons.geo_alt_fill, color: Colors.green, size: 14),
                                const SizedBox(width: 4),
                                Expanded(
                                  child:                                   Text(widget.aliado['direccion'] ?? 'Sin dirección',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Datos de la IA ────────────────────────────
            if (widget.datosIA != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEAF3DE), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFF3B6D11), size: 18),
                        const SizedBox(width: 6),
                        const Text('Material detectado por IA',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3B6D11))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _infoIA('Material', widget.datosIA!['material'] ?? '-'),
                        _infoIA('Cantidad', widget.datosIA!['cantidadEstimada'] ?? '-'),
                        _infoIA('Peso aprox.', widget.datosIA!['pesoAproximado'] ?? '-'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Estado ────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    child: const Icon(Icons.schedule, color: Colors.orange, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text('Estado: ',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const Text('Pendiente de confirmación',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.orange)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Fecha y hora ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildSelector(
                    icon: Icons.calendar_month,
                    label: 'Fecha',
                    value: _fechaFormateada,
                    onTap: _seleccionarFecha,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSelector(
                    icon: Icons.access_time,
                    label: 'Hora',
                    value: _horaFormateada,
                    onTap: _seleccionarHora,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Observaciones ─────────────────────────────
            const Text('Observaciones',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: observacionesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Escribe detalles adicionales...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Botón confirmar ───────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: loading ? null : _confirmarReserva,
                icon: loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check_circle_outline),
                label: Text(loading ? 'Procesando...' : 'Confirmar reserva'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSelector({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3DE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF3B6D11), size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                Text(value,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoIA(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class MaterialSeleccionado {
  final int id;
  final String nombre;
  bool seleccionado;
  TextEditingController pesoController = TextEditingController();

  MaterialSeleccionado({
    required this.id,
    required this.nombre,
    this.seleccionado = false,
  });
}
