import 'dart:math';
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../theme/app_theme.dart';

const double _itemSize = 52;

const Color _plasticColor = Color(0xFF2196F3);
const Color _glassColor = Color(0xFF4CAF50);
const Color _cartonColor = Color(0xFF8D6E63);

enum ItemType { plastic, glass, carton }

class FallingItem {
  double x, y;
  final ItemType type;
  final double speed;
  bool alive = true;

  FallingItem({
    required this.x,
    required this.y,
    required this.type,
    required this.speed,
  });
}

class RecyclingGameScreen extends StatefulWidget {
  const RecyclingGameScreen({super.key});
  @override
  State<RecyclingGameScreen> createState() => _RecyclingGameScreenState();
}

class _RecyclingGameScreenState extends State<RecyclingGameScreen>
    with TickerProviderStateMixin {
  int _score = 0;
  int _lives = 3;
  bool _isGameOver = false;
  final List<FallingItem> _items = [];
  double _elapsed = 0;
  double _spawnTimer = 0;
  double _spawnInterval = 1.5;
  final Random _rng = Random();
  int _plasticCount = 0;
  int _glassCount = 0;
  int _cartonCount = 0;

  // Drag state
  FallingItem? _draggedItem;

  // Layout
  Size _gameSize = const Size(360, 640);
  late double _binHeight;
  late double _binWidth;
  late double _binY;
  late List<double> _binCenters;

  late Ticker _ticker;
  Duration _lastTick = Duration.zero;
  Color _feedbackColor = Colors.transparent;
  double _feedbackOpacity = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _initLayout(Size size) {
    _gameSize = size;
    _binHeight = size.height * 0.14;
    _binWidth = size.width * 0.22;
    _binY = size.height - _binHeight / 2 - 30;
    final spacing = size.width * 0.055;
    _binCenters = [
      size.width / 2 - _binWidth - spacing,
      size.width / 2,
      size.width / 2 + _binWidth + spacing,
    ];
  }

  void _onTick(Duration elapsed) {
    if (_isGameOver) return;

    final dt = (elapsed - _lastTick).inMicroseconds / 1000000;
    _lastTick = elapsed;
    if (dt <= 0 || dt > 0.1) return;

    _elapsed += dt;

    _spawnInterval = max(0.4, 1.5 - _elapsed / 60);
    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnItem();
    }

    for (final item in _items) {
      if (item != _draggedItem) {
        item.y += item.speed * dt;
      }
    }

    for (int i = _items.length - 1; i >= 0; i--) {
      final item = _items[i];
      if (!item.alive) continue;

      if (item == _draggedItem) continue;

      if (item.y + _itemSize / 2 > _gameSize.height) {
        _loseLife();
        item.alive = false;
        _items.removeAt(i);
      }
    }

    setState(() {});
  }

  void _spawnItem() {
    final x = _rng.nextDouble() * (_gameSize.width - 60) + 30;
    final types = ItemType.values;
    final type = types[_rng.nextInt(types.length)];
    final speed = 80 + _elapsed * 1.2;
    _items.add(FallingItem(x: x, y: -_itemSize, type: type, speed: speed));
  }

  void _loseLife() {
    _lives--;
    if (_lives <= 0) {
      _lives = 0;
      _isGameOver = true;
    }
    _flashFeedback(false);
    setState(() {});
  }

  void _scorePoint(ItemType type) {
    _score += 10;
    switch (type) {
      case ItemType.plastic: _plasticCount++; break;
      case ItemType.glass: _glassCount++; break;
      case ItemType.carton: _cartonCount++; break;
    }
    _flashFeedback(true);
    setState(() {});
  }

  void _flashFeedback(bool correct) {
    _feedbackColor = correct ? Colors.green : Colors.red;
    _feedbackOpacity = 0.35;
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _feedbackOpacity = 0;
        setState(() {});
      }
    });
  }

  void _restart() {
    setState(() {
      _score = 0;
      _lives = 3;
      _isGameOver = false;
      _items.clear();
      _elapsed = 0;
      _spawnTimer = 0;
      _spawnInterval = 1.5;
      _plasticCount = 0;
      _glassCount = 0;
      _cartonCount = 0;
      _draggedItem = null;
      _lastTick = Duration.zero;
    });
  }

  // ── Drag handlers ───────────────────────────
  void _onTapDown(TapDownDetails d) {
    if (_isGameOver) return;
    final pos = d.localPosition;

    for (int i = _items.length - 1; i >= 0; i--) {
      final item = _items[i];
      if (!item.alive) continue;
      final dist = (Offset(item.x, item.y) - pos).distance;
      if (dist < _itemSize / 2 + 8) {
        _draggedItem = item;
        return;
      }
    }
  }

  void _onTapMove(DragUpdateDetails d) {
    if (_draggedItem == null) return;
    _draggedItem!.x = (_draggedItem!.x + d.delta.dx).clamp(_itemSize / 2, _gameSize.width - _itemSize / 2);
    _draggedItem!.y = (_draggedItem!.y + d.delta.dy).clamp(_itemSize / 2, _gameSize.height - _itemSize / 2);
    setState(() {});
  }

  void _onTapUp(TapUpDetails d) {
    if (_draggedItem == null) return;
    _dropItem(d.localPosition);
  }

  void _onTapCancel() {
    if (_draggedItem == null) return;
    _dropItem(Offset(_draggedItem!.x, _draggedItem!.y + 50));
  }

  void _dropItem(Offset pos) {
    if (_draggedItem == null) return;
    final item = _draggedItem!;
    _draggedItem = null;

    for (int b = 0; b < 3; b++) {
      final binRect = Rect.fromCenter(
        center: Offset(_binCenters[b], _binY),
        width: _binWidth,
        height: _binHeight,
      );
      if (binRect.contains(pos)) {
        if (item.type == ItemType.values[b]) {
          _scorePoint(item.type);
        } else {
          _loseLife();
        }
        item.alive = false;
        _items.remove(item);
        setState(() {});
        return;
      }
    }

    // Dropped outside any bin → lose life
    _loseLife();
    item.alive = false;
    _items.remove(item);
    setState(() {});
  }

  // ── Build ───────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F0E0),
      appBar: AppBar(
        title: const Text('Recicla con EcoRecicla', style: TextStyle(fontSize: 16)),
        actions: [
          if (_isGameOver)
            IconButton(icon: const Icon(Icons.refresh), onPressed: _restart),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _initLayout(Size(constraints.maxWidth, constraints.maxHeight));
          return GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onPanStart: (d) => _onTapDown(TapDownDetails(localPosition: d.localPosition)),
            onPanUpdate: _onTapMove,
            onPanEnd: (_) => _onTapUp(TapUpDetails(kind: PointerDeviceKind.touch, localPosition: Offset(_draggedItem?.x ?? 0, _draggedItem?.y ?? 0))),
            child: Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: _GamePainter(
                    items: _items,
                    draggedItem: _draggedItem,
                    binCenters: _binCenters,
                    binWidth: _binWidth,
                    binHeight: _binHeight,
                    binY: _binY,
                    feedbackColor: _feedbackColor,
                    feedbackOpacity: _feedbackOpacity,
                    screenSize: _gameSize,
                  ),
                ),
                if (!_isGameOver) ..._buildUI(),
                if (_isGameOver) _buildGameOver(),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildUI() {
    return [
      Positioned(top: 8, left: 8, child: _chip(Icons.score_outlined, '$_score')),
      Positioned(top: 8, left: 90, child: _chip(Icons.favorite_border, '$_lives')),
      if (_draggedItem != null)
        Positioned(
          bottom: 8, left: 0, right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Suelta sobre el bote correcto',
                style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ),
    ];
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
      ]),
    );
  }

  Widget _buildGameOver() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.recycling, size: 52, color: AppColors.primary),
          const SizedBox(height: 10),
          const Text('¡Tiempo terminado!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text('Puntaje: $_score',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary)),
          const SizedBox(height: 12),
          _statRow(_plasticColor, 'Botellas plástico', _plasticCount),
          _statRow(_glassColor, 'Botellas vidrio', _glassCount),
          _statRow(_cartonColor, 'Envases cartón', _cartonCount),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: _restart,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          )),
        ]),
      ),
    );
  }

  Widget _statRow(Color color, String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label: $count', style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════
// Custom Painter
// ══════════════════════════════════════════════
class _GamePainter extends CustomPainter {
  final List<FallingItem> items;
  final FallingItem? draggedItem;
  final List<double> binCenters;
  final double binWidth, binHeight, binY;
  final Color feedbackColor;
  final double feedbackOpacity;
  final Size screenSize;

  _GamePainter({
    required this.items,
    required this.draggedItem,
    required this.binCenters,
    required this.binWidth,
    required this.binHeight,
    required this.binY,
    required this.feedbackColor,
    required this.feedbackOpacity,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawBins(canvas, size);

    // Draw items (non-dragged first, dragged on top)
    for (final item in items) {
      if (item != draggedItem && item.alive) _drawItem(canvas, item);
    }
    if (draggedItem != null && draggedItem!.alive) {
      _drawItem(canvas, draggedItem!);
    }

    _drawFeedback(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final skyGrad = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [const Color(0xFF87CEEB), const Color(0xFFD4E7C5)]);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = skyGrad.createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    // Clouds
    _cloud(canvas, size.width * 0.15, size.height * 0.06, size.width * 0.08);
    _cloud(canvas, size.width * 0.7, size.height * 0.1, size.width * 0.06);

    // Ground
    final groundTop = size.height - 35;
    final groundGrad = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [const Color(0xFF6B8E23), const Color(0xFF556B2F)]);
    canvas.drawRect(Rect.fromLTWH(0, groundTop, size.width, 35),
      Paint()..shader = groundGrad.createShader(Rect.fromLTWH(0, groundTop, size.width, 35)));

    // Grass
    final gp = Paint()..color = const Color(0xFF4A7A2E)..strokeWidth = 2..style = PaintingStyle.stroke;
    for (double x = 0; x < size.width; x += 16) {
      final h = 5 + sin(x * 0.3) * 3;
      canvas.drawLine(Offset(x, groundTop), Offset(x, groundTop - h), gp);
    }
  }

  void _cloud(Canvas canvas, double x, double y, double r) {
    final p = Paint()..color = Colors.white.withOpacity(0.5);
    canvas.drawCircle(Offset(x, y), r, p);
    canvas.drawCircle(Offset(x + r * 0.8, y - r * 0.3), r * 0.7, p);
    canvas.drawCircle(Offset(x - r * 0.7, y - r * 0.2), r * 0.6, p);
    canvas.drawCircle(Offset(x + r * 0.4, y + r * 0.2), r * 0.5, p);
  }

  void _drawBins(Canvas canvas, Size size) {
    final labels = ['PLÁSTICO', 'VIDRIO', 'CARTÓN'];
    final colors = [_plasticColor, _glassColor, _cartonColor];

    for (int i = 0; i < 3; i++) {
      final cx = binCenters[i];
      final left = cx - binWidth / 2;
      final top = binY - binHeight / 2;

      // Shadow
      final shadowRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left + 4, top + 4, binWidth, binHeight), Radius.circular(10));
      canvas.drawPath(Path()..addRRect(shadowRect), Paint()..color = Colors.black.withOpacity(0.1));

      // Body
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, binWidth, binHeight), Radius.circular(10));
      canvas.drawRRect(rect, Paint()..color = colors[i]);

      // Lid
      final lidRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, top, binWidth, binHeight * 0.15),
        topLeft: const Radius.circular(10), topRight: const Radius.circular(10));
      canvas.drawRRect(lidRect, Paint()..color = colors[i].withOpacity(0.75));

      // Opening
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left + binWidth * 0.2, top + binHeight * 0.15, binWidth * 0.6, binHeight * 0.06),
          Radius.circular(3)),
        Paint()..color = Colors.black.withOpacity(0.25));

      // Highlight edge
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left + 2, top + 2, 3, binHeight * 0.8), Radius.circular(1.5)),
        Paint()..color = Colors.white.withOpacity(0.12));

      // Icon
      _recycleIcon(canvas, cx, top + binHeight * 0.35, binWidth * 0.28);

      // Label
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: TextStyle(
          color: Colors.white, fontSize: binWidth * 0.1, fontWeight: FontWeight.w900, letterSpacing: 1)),
        textDirection: TextDirection.ltr, textAlign: TextAlign.center);
      tp.layout(maxWidth: binWidth - 4);
      tp.paint(canvas, Offset(cx - tp.width / 2, top + binHeight - binHeight * 0.22));
    }
  }

  void _recycleIcon(Canvas canvas, double cx, double y, double sz) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round;
    final path = Path();
    final s = sz * 0.5;
    for (int i = 0; i < 3; i++) {
      final a = -pi / 2 + i * 2 * pi / 3;
      final na = -pi / 2 + (i + 1) * 2 * pi / 3;
      final tip = Offset(cx + cos(a) * s, y + sin(a) * s);
      final m1 = Offset(cx + cos(a + 0.4) * s * 0.6, y + sin(a + 0.4) * s * 0.6);
      final m2 = Offset(cx + cos(na - 0.4) * s * 0.6, y + sin(na - 0.4) * s * 0.6);
      final end = Offset(cx + cos(na) * s, y + sin(na) * s);
      path.moveTo(tip.dx, tip.dy); path.lineTo(m1.dx, m1.dy);
      path.moveTo(end.dx, end.dy); path.lineTo(m2.dx, m2.dy);
      final aa = a + pi / 3;
      final as = 4;
      path.moveTo(tip.dx, tip.dy);
      path.lineTo(tip.dx + cos(aa + 0.5) * as, tip.dy + sin(aa + 0.5) * as);
      path.moveTo(tip.dx, tip.dy);
      path.lineTo(tip.dx + cos(aa - 0.5) * as, tip.dy + sin(aa - 0.5) * as);
    }
    canvas.drawPath(path, p);
  }

  void _drawItem(Canvas canvas, FallingItem item) {
    final scale = item == draggedItem ? 1.15 : 1.0;
    canvas.save();
    canvas.translate(item.x, item.y);
    canvas.scale(scale, scale);

    if (item == draggedItem) {
      final glow = Paint()..color = Colors.yellow.withOpacity(0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(const Offset(0, 0), _itemSize * 0.55, glow);
    }

    switch (item.type) {
      case ItemType.plastic: _paintBottle(canvas); break;
      case ItemType.glass: _paintGlassBottle(canvas); break;
      case ItemType.carton: _paintCarton(canvas); break;
    }

    canvas.restore();
  }

  void _paintBottle(Canvas canvas) {
    final s = _itemSize / 48;
    final w = 28 * s, h = 42 * s;
    final nw = 10 * s, nh = 10 * s, ch = 4 * s;
    final bh = h - nh - ch;

    canvas.drawOval(Rect.fromCenter(center: const Offset(2, -2), width: w * 0.7, height: 4),
      Paint()..color = Colors.black.withOpacity(0.15));

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, bh / 2 - h / 2), width: w, height: bh), Radius.circular(w * 0.25));
    final bg = LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight,
      colors: [const Color(0xFF64B5F6), const Color(0xFF2196F3), const Color(0xFF64B5F6)]);
    canvas.drawRRect(bodyRect, Paint()..shader = bg.createShader(bodyRect.outerRect));

    canvas.drawRect(Rect.fromCenter(center: Offset(0, -h / 2 + nh / 2 + ch), width: nw, height: nh),
      Paint()..color = const Color(0xFF2196F3));

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -h / 2 + ch / 2), width: nw + 3, height: ch),
        Radius.circular(2)), Paint()..color = const Color(0xFF1565C0));

    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(-w * 0.22, 0), width: 4, height: bh * 0.6), Radius.circular(2)),
      Paint()..color = Colors.white.withOpacity(0.3));

    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, 0), width: w * 0.6, height: bh * 0.2), Radius.circular(2)),
      Paint()..color = Colors.white.withOpacity(0.2));
  }

  void _paintGlassBottle(Canvas canvas) {
    final s = _itemSize / 48;
    final w = 24 * s, h = 44 * s;
    final nw = 7 * s, nh = 14 * s, ch = 3 * s;
    final bh = h - nh - ch;

    canvas.drawOval(Rect.fromCenter(center: const Offset(2, -2), width: w * 0.6, height: 4),
      Paint()..color = Colors.black.withOpacity(0.15));

    final bp = Path();
    final bt = -h / 2 + ch + nh;
    final bb = h / 2;
    bp.moveTo(-w / 2, bt);
    bp.lineTo(-w / 2, bb - w / 3);
    bp.quadraticBezierTo(-w / 2, bb, 0, bb);
    bp.quadraticBezierTo(w / 2, bb, w / 2, bb - w / 3);
    bp.lineTo(w / 2, bt);
    bp.close();
    final bg = LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight,
      colors: [const Color(0xFF81C784), const Color(0xFF4CAF50), const Color(0xFF81C784)]);
    canvas.drawPath(bp, Paint()..shader = bg.createShader(Rect.fromCenter(center: const Offset(0, 0), width: w, height: bh)));

    canvas.drawRect(Rect.fromCenter(center: Offset(0, -h / 2 + ch + nh / 2), width: nw, height: nh),
      Paint()..color = const Color(0xFF4CAF50));

    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, -h / 2 + ch / 2), width: nw + 3, height: ch), Radius.circular(1.5)),
      Paint()..color = const Color(0xFF9E9E9E));

    // Reflection
    final rp = Path();
    rp.moveTo(-w / 2 + 4, bt + 3);
    rp.lineTo(-w / 2 + 8, bt + 3);
    rp.lineTo(-w / 2 + 2, bb - 3);
    rp.lineTo(-w / 2 + 6, bb - 3);
    rp.close();
    canvas.drawPath(rp, Paint()..color = Colors.white.withOpacity(0.2));

    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, bt + bh * 0.35), width: w * 0.55, height: bh * 0.18), Radius.circular(2)),
      Paint()..color = Colors.white.withOpacity(0.18));
  }

  void _paintCarton(Canvas canvas) {
    final s = _itemSize / 48;
    final w = 34 * s, h = 38 * s;

    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(2, -2), width: w, height: h), Radius.circular(3)),
      Paint()..color = Colors.black.withOpacity(0.15));

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, 0), width: w, height: h), Radius.circular(3));
    final bg = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [const Color(0xFFBCAAA4), const Color(0xFF8D6E63), const Color(0xFF6D4C41)]);
    canvas.drawRRect(bodyRect, Paint()..shader = bg.createShader(bodyRect.outerRect));

    // Gable top
    final gp = Path();
    gp.moveTo(-w / 2, -h / 2);
    gp.lineTo(0, -h / 2 - h * 0.2);
    gp.lineTo(w / 2, -h / 2);
    gp.close();
    canvas.drawPath(gp, Paint()..color = const Color(0xFF8D6E63).withOpacity(0.85));

    canvas.drawLine(Offset(0, -h / 2), Offset(0, -h / 2 - h * 0.2),
      Paint()..color = Colors.black.withOpacity(0.12)..strokeWidth = 1.5);

    canvas.drawRect(Rect.fromCenter(center: Offset(0, -h / 2 - h * 0.07), width: 5, height: 5),
      Paint()..color = const Color(0xFF5D4037));

    _recycleIcon(canvas, 0, h * 0.1, w * 0.3);

    final lp = Paint()..color = Colors.white.withOpacity(0.25)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawLine(Offset(-w * 0.2, h * 0.25), Offset(w * 0.2, h * 0.25), lp);
    canvas.drawLine(Offset(-w * 0.15, h * 0.32), Offset(w * 0.12, h * 0.32), lp);
  }

  void _drawFeedback(Canvas canvas, Size size) {
    if (feedbackOpacity > 0) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = feedbackColor.withOpacity(feedbackOpacity));
    }
  }

  @override
  bool shouldRepaint(covariant _GamePainter oldDelegate) => true;
}
