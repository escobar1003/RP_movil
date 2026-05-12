// lib/screens/reciclar_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReciclarScreen extends StatefulWidget {
  const ReciclarScreen({super.key});

  @override
  State<ReciclarScreen> createState() => _ReciclarScreenState();
}

class _ReciclarScreenState extends State<ReciclarScreen> {
  bool _mostrarResultado = false;

  // ✅ FIX: variables tipadas en lugar de Map<String, dynamic>
  final String _nombre      = 'Botella de plástico';
  final String _tipo        = 'Plástico (PET)';
  final String _estado      = 'Aprovechable';
  final int    _confianza   = 98;
  final String _caneco      = 'Caneco Blanco';
  final String _deposito    = 'Aprovechable';
  final String _descripcion = 'Vidrio, vidrio, metal,\npapel y cartón.';

  void _escanear() {
    setState(() => _mostrarResultado = false);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _mostrarResultado = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Clasificar con IA'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text('Toma una foto del residuo',
                  style: TextStyle(color: AppColors.textMid, fontSize: 13)),
            ),

            // ── Visor ──────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: 260,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_mostrarResultado)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/PET_bottle_01_Pengo.jpg/400px-PET_bottle_01_Pengo.jpg',
                        fit: BoxFit.contain,
                        height: 220,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.local_drink, size: 80, color: Colors.teal),
                      ),
                    )
                  else
                    const Icon(Icons.camera_alt_outlined, size: 56, color: Colors.black26),
                  const _ScannerFrame(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (_mostrarResultado) ...[
              // Tarjeta resultado
              _buildCard(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_drink, color: Colors.teal),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_nombre,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
                          Text(_tipo,
                              style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.green100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(_estado,
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text('$_confianza%',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
                        const Text('Confianza', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Tarjeta depósito
              _buildCard(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Depositar en:',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textMid)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.yellow100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.orange),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_caneco,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
                            Text(_deposito,
                                style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                            Text(_descripcion,
                                style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],

            // ── Botón ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton.icon(
                  onPressed: _escanear,
                  icon: const Icon(Icons.qr_code_scanner, size: 20),
                  label: Text(_mostrarResultado ? 'Escanear otro' : 'Escanear'),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? margin}) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }
}

// ── Frame del escáner ────────────────────────────────────────
class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Stack(children: [
          Positioned(top: 0, left: 0,   child: _Esquina(top: true,  left: true)),
          Positioned(top: 0, right: 0,  child: _Esquina(top: true,  left: false)),
          Positioned(bottom: 0, left: 0,  child: _Esquina(top: false, left: true)),
          Positioned(bottom: 0, right: 0, child: _Esquina(top: false, left: false)),
        ]),
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
      size: const Size(28, 28),
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
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final w = size.width; final h = size.height;
    const r = 6.0;

    if (top && left) {
      path.moveTo(0, h); path.lineTo(0, r);
      path.quadraticBezierTo(0, 0, r, 0); path.lineTo(w, 0);
    } else if (top && !left) {
      path.moveTo(0, 0); path.lineTo(w - r, 0);
      path.quadraticBezierTo(w, 0, w, r); path.lineTo(w, h);
    } else if (!top && left) {
      path.moveTo(0, 0); path.lineTo(0, h - r);
      path.quadraticBezierTo(0, h, r, h); path.lineTo(w, h);
    } else {
      path.moveTo(0, h); path.lineTo(w - r, h);
      path.quadraticBezierTo(w, h, w, h - r); path.lineTo(w, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}