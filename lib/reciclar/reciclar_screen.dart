// lib/reciclar/reciclar_screen.dart

import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../mapa_puntos/mapa_puntos_screen.dart';
import '../chat_ia/chat_ia_screen.dart';
import 'reciclar_style.dart';

class ReciclarScreen extends StatefulWidget {
  const ReciclarScreen({super.key});

  @override
  State<ReciclarScreen> createState() => _ReciclarScreenState();
}

class _ReciclarScreenState extends State<ReciclarScreen> {
  bool _mostrarResultado = false;
  bool _estaCargando = false;

  String _nombre = 'Detectando...';
  String _tipo = '';
  String _estado = 'Aprovechable';
  int _confianza = 0;
  String _caneco = 'Caneco Blanco';
  String _deposito = 'Aprovechable';
  String _descripcion = 'Vidrio, plástico, metal,\npapel y cartón.';
  String _cantidadEstimada = '1 unidad';
  String _pesoAproximado = '0.5 kg';
  String _nivelReciclabilidad = 'Alto';
  String _recomendacionIA = 'Enjuaga y aplasta antes de depositar.';

  Color _nivelColor(String nivel) {
    switch (nivel) {
      case 'Alto':
        return GreenColors.medium;
      case 'Medio':
        return Colors.orange;
      case 'Bajo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _nivelBg(String nivel) {
    switch (nivel) {
      case 'Alto':
        return GreenColors.lightBg;
      case 'Medio':
        return MaterialBgColors.amber;
      case 'Bajo':
        return MaterialBgColors.red;
      default:
        return Colors.grey[100]!;
    }
  }

  Future<void> _escanear() async {
    setState(() {
      _estaCargando = true;
      _mostrarResultado = false;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _confianza = 92;
        _mostrarResultado = true;
        _estaCargando = false;
        _nombre = 'Botella de plástico';
        _tipo = 'Plástico (PET)';
        _estado = 'Aprovechable';
        _caneco = 'Caneco Blanco';
        _deposito = 'Aprovechable';
        _descripcion = 'Plásticos, vidrio, metal, papel y cartón.';
        _cantidadEstimada = '1 unidad';
        _pesoAproximado = '0.5 kg';
        _nivelReciclabilidad = 'Alto';
        _recomendacionIA = 'Enjuaga y aplasta antes de depositar.';
      });
    }
  }

  Map<String, dynamic> get _datosIA => {
    'material': _nombre,
    'tipo': _tipo,
    'estado': _estado,
    'confianza': _confianza,
    'caneco': _caneco,
    'deposito': _deposito,
    'descripcion': _descripcion,
    'cantidadEstimada': _cantidadEstimada,
    'pesoAproximado': _pesoAproximado,
    'nivelReciclabilidad': _nivelReciclabilidad,
    'recomendacionIA': _recomendacionIA,
  };

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        elevation: 6,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatIaScreen()),
        ),
        icon: const Icon(Icons.chat_bubble_outline_rounded,
            color: Colors.white, size: 22),
        label: const Text('Chat IA',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      appBar: AppBar(
        title: const Text('Clasificar con IA'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Toma una foto del residuo',
                style: TextStyle(color: AppColors.textMid, fontSize: 13),
              ),
            ),

            Container(
              margin: ReciclarStyles.visorMargin,
              height: ReciclarStyles.visorHeight,
              decoration: BoxDecoration(
                color: SemanticColors.grey200,
                borderRadius: BorderRadius.circular(ReciclarStyles.visorRadius),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_estaCargando)
                    const CircularProgressIndicator(color: AppColors.primary)
                  else if (_mostrarResultado)
                    Container(
                      decoration: BoxDecoration(
                        color: GreenColors.lightBg,
                        borderRadius: BorderRadius.circular(ReciclarStyles.visorRadius),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 48, color: AppColors.primary),
                            SizedBox(height: 6),
                            Text('¡Material detectado!',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                    )
                  else
                    const Icon(Icons.camera_alt_outlined,
                        size: 56, color: Colors.black26),
                  const _ScannerFrame(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (_mostrarResultado) ...[

              _buildCard(
                margin: ReciclarStyles.cardMargin,
                child: Row(
                  children: [
                    Container(
                      width: ReciclarStyles.materialIconSize,
                      height: ReciclarStyles.materialIconSize,
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(ReciclarStyles.materialIconRadius),
                      ),
                      child: const Icon(Icons.local_drink, color: Colors.teal, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Material identificado',
                              style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                          const SizedBox(height: 2),
                          Text(_nombre,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark)),
                          Text(_tipo,
                              style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text('$_confianza%',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary)),
                        const Text('Confianza',
                            style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              _buildCard(
                margin: ReciclarStyles.cardMargin,
                child: Row(
                  children: [
                    _datoColumna(Icons.inventory_2_outlined, 'Cantidad', _cantidadEstimada),
                    Container(width: 1, height: 40, color: Colors.grey[200]),
                    _datoColumna(Icons.monitor_weight_outlined, 'Peso aprox.', _pesoAproximado),
                    Container(width: 1, height: 40, color: Colors.grey[200]),
                    _datoColumna(Icons.recycling, 'Reciclabilidad', _nivelReciclabilidad,
                        valueColor: _nivelColor(_nivelReciclabilidad)),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              _buildCard(
                margin: ReciclarStyles.cardMargin,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.green100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Recomendación IA',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                          const SizedBox(height: 3),
                          Text(_recomendacionIA,
                              style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              _buildCard(
                margin: ReciclarStyles.cardMargin,
                child: Row(
                  children: [
                    Container(
                      width: ReciclarStyles.smallIconSize,
                      height: ReciclarStyles.smallIconSize,
                      decoration: BoxDecoration(
                        color: AppColors.yellow100,
                        borderRadius: BorderRadius.circular(ReciclarStyles.smallIconRadius),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.orange),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_caneco,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
                          Text(_deposito,
                              style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                        ],
                      ),
                    ),
                    Container(
                      padding: ReciclarStyles.badgePadding,
                      decoration: BoxDecoration(
                        color: _nivelBg(_nivelReciclabilidad),
                        borderRadius: BorderRadius.circular(ReciclarStyles.badgeRadius),
                      ),
                      child: Text(_nivelReciclabilidad,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _nivelColor(_nivelReciclabilidad))),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],

            Padding(
              padding: ReciclarStyles.buttonPadding,
              child: SizedBox(
                width: double.infinity, height: ReciclarStyles.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _estaCargando ? null : _escanear,
                  icon: const Icon(Icons.qr_code_scanner, size: 20),
                  label: Text(_estaCargando
                      ? 'Analizando...'
                      : (_mostrarResultado ? 'Escanear otro' : 'Escanear')),
                ),
              ),
            ),

            if (_mostrarResultado)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity, height: ReciclarStyles.buttonHeight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.map, size: 20),
                    label: const Text('Reciclar ahora'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MapaPuntosScreen(
                            soloMapa: false,
                            datosIA: _datosIA,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _datoColumna(IconData icon, String label, String value, {Color? valueColor}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.textDark)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? margin}) {
    return Container(
      margin: margin,
      padding: ReciclarStyles.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ReciclarStyles.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Padding(
        padding: ReciclarStyles.scannerPadding,
        child: Stack(
          children: [
            Positioned(top: 0, left: 0, child: _Esquina(top: true, left: true)),
            Positioned(top: 0, right: 0, child: _Esquina(top: true, left: false)),
            Positioned(bottom: 0, left: 0, child: _Esquina(top: false, left: true)),
            Positioned(bottom: 0, right: 0, child: _Esquina(top: false, left: false)),
          ],
        ),
      ),
    );
  }
}

class _Esquina extends StatelessWidget {
  final bool top, left;
  const _Esquina({required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(ReciclarStyles.scannerCornerSize, ReciclarStyles.scannerCornerSize),
      painter: _EsquinaPainter(top: top, left: left),
    );
  }
}

class _EsquinaPainter extends CustomPainter {
  final bool top, left;
  _EsquinaPainter({required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = ReciclarStyles.scannerStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    final w = size.width;
    final h = size.height;

    if (top && left) {
      path.moveTo(0, h); path.lineTo(0, ReciclarStyles.scannerCornerRadius); path.quadraticBezierTo(0, 0, ReciclarStyles.scannerCornerRadius, 0); path.lineTo(w, 0);
    } else if (top && !left) {
      path.moveTo(0, 0); path.lineTo(w - ReciclarStyles.scannerCornerRadius, 0); path.quadraticBezierTo(w, 0, w, ReciclarStyles.scannerCornerRadius); path.lineTo(w, h);
    } else if (!top && left) {
      path.moveTo(0, 0); path.lineTo(0, h - ReciclarStyles.scannerCornerRadius); path.quadraticBezierTo(0, h, ReciclarStyles.scannerCornerRadius, h); path.lineTo(w, h);
    } else {
      path.moveTo(0, h); path.lineTo(w - ReciclarStyles.scannerCornerRadius, h); path.quadraticBezierTo(w, h, w, h - ReciclarStyles.scannerCornerRadius); path.lineTo(w, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
