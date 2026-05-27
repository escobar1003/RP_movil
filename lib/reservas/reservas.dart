// lib/reservas/reservas.dart

import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../styles/colors.dart';
import 'reservas_style.dart';

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
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${d.day} de ${meses[d.month - 1]} de ${d.year}';
  }

  String get _horaFormateada {
    final h = _horaSeleccionada;
    final hora = h.hour.toString().padLeft(2, '0');
    final min = h.minute.toString().padLeft(2, '0');
    return '$hora:$min';
  }

  Future<void> _confirmarReserva() async {
    setState(() => loading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        loading = false;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ReservasStyles.dialogRadius)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: GreenColors.lightBg,
                  borderRadius: BorderRadius.circular(ReservasStyles.dialogIconRadius),
                ),
                child: const Icon(Icons.check_circle, color: GreenColors.medium, size: ReservasStyles.dialogIconSize),
              ),
              const SizedBox(height: 16),
              const Text('¡Reserva confirmada!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Pendiente de confirmación por el encargado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text('Recibirás una notificación cuando sea aceptada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400])),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReservasStyles.bg,
      appBar: AppBar(
        title: const Text('Reservar entrega'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: ReservasStyles.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: ReservasStyles.cardPadding,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ReservasStyles.cardRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(ReservasStyles.iconContainerSize),
                        decoration: BoxDecoration(
                          color: GreenColors.lightBg,
                          borderRadius: BorderRadius.circular(ReservasStyles.iconContainerRadius),
                        ),
                        child: const Icon(Icons.store_rounded, color: GreenColors.medium, size: 24),
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
                                  child: Text(widget.aliado['direccion'],
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

            const SizedBox(height: ReservasStyles.gapSections),

            if (widget.datosIA != null) ...[
              Container(
                width: double.infinity,
                padding: ReservasStyles.iaCardPadding,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(ReservasStyles.iaCardRadius),
                  border: Border.all(color: GreenColors.lightBg, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: GreenColors.medium, size: 18),
                        const SizedBox(width: 6),
                        const Text('Material detectado por IA',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GreenColors.medium)),
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
              const SizedBox(height: ReservasStyles.gapSections),
            ],

            Container(
              width: double.infinity,
              padding: ReservasStyles.statusBannerPadding,
              decoration: BoxDecoration(
                color: MaterialBgColors.amber,
                borderRadius: BorderRadius.circular(ReservasStyles.statusBannerRadius),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
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

            const SizedBox(height: ReservasStyles.gapSections),

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
                  borderRadius: BorderRadius.circular(ReservasStyles.fieldRadius),
                ),
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: ReservasStyles.buttonHeight,
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
                    borderRadius: BorderRadius.circular(ReservasStyles.buttonRadius),
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
        padding: ReservasStyles.selectorPadding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ReservasStyles.selectorRadius),
        ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(ReservasStyles.selectorIconSize),
                    decoration: BoxDecoration(
                      color: GreenColors.lightBg,
                      borderRadius: BorderRadius.circular(ReservasStyles.selectorIconRadius),
                    ),
                    child: Icon(icon, color: GreenColors.medium, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      const SizedBox(height: 2),
                      Text(value,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
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
