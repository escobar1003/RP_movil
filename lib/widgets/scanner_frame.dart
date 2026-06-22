import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScannerFrame extends StatelessWidget {
  const ScannerFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
    final w = size.width;
    final h = size.height;
    const r = 6.0;
    if (top && left) {
      path.moveTo(0, h);
      path.lineTo(0, r);
      path.quadraticBezierTo(0, 0, r, 0);
      path.lineTo(w, 0);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(w - r, 0);
      path.quadraticBezierTo(w, 0, w, r);
      path.lineTo(w, h);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, h - r);
      path.quadraticBezierTo(0, h, r, h);
      path.lineTo(w, h);
    } else {
      path.moveTo(0, h);
      path.lineTo(w - r, h);
      path.quadraticBezierTo(w, h, w, h - r);
      path.lineTo(w, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
