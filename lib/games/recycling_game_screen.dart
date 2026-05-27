import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../styles/colors.dart';

const double _itemSize = 60;

const Color _plasticColor = Color(0xFFFFC107);
const Color _glassColor = Color(0xFF4CAF50);
const Color _cartonColor = Color(0xFF2196F3);

enum ItemType { plastic, glass, carton }
enum GameState { start, playing, paused, gameOver }

class FallingItem {
  double x, y;
  final ItemType type;
  final int subType;
  final double speed;
  double rotation;
  final double rotationSpeed;
  final double scale;
  bool alive = true;

  FallingItem({
    required this.x,
    required this.y,
    required this.type,
    required this.subType,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
    required this.scale,
  });
}

class Particle {
  double x, y;
  double vx, vy;
  double life, maxLife;
  final Color color;
  final double size;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.maxLife,
    required this.color,
    required this.size,
  });

  bool get dead => life <= 0;
}

class FloatingScore {
  double x, y;
  double life;
  final int score;
  final bool correct;

  FloatingScore({
    required this.x,
    required this.y,
    required this.score,
    required this.correct,
    this.life = 1.0,
  });

  bool get dead => life <= 0;
}

class RecyclingGameScreen extends StatefulWidget {
  const RecyclingGameScreen({super.key});
  @override
  State<RecyclingGameScreen> createState() => _RecyclingGameScreenState();
}

class _RecyclingGameScreenState extends State<RecyclingGameScreen>
    with SingleTickerProviderStateMixin {
  int _score = 0;
  int _lives = 3;
  GameState _state = GameState.start;
  int _level = 1;
  double _timerSeconds = 90;
  final List<FallingItem> _items = [];
  final List<Particle> _particles = [];
  final List<FloatingScore> _floatingScores = [];
  double _elapsed = 0;
  double _spawnTimer = 0;
  double _spawnInterval = 1.5;
  int _maxConcurrent = 3;
  final Random _rng = Random();
  int _plasticCount = 0;
  int _glassCount = 0;
  int _cartonCount = 0;

  FallingItem? _draggedItem;

  Size _gameSize = const Size(360, 640);
  late double _binHeight;
  late double _binWidth;
  late double _binY;
  late List<double> _binCenters;

  late Ticker _ticker;
  Duration _lastTick = Duration.zero;
  Color _feedbackColor = Colors.transparent;
  double _feedbackOpacity = 0;
  int _frameCount = 0;
  bool _isWin = false;

  double _shakeOffset = 0;
  double _shakeIntensity = 0;
  List<double> _binGlow = [0, 0, 0];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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

  void _startGame() {
    setState(() {
      _state = GameState.playing;
      _score = 0;
      _lives = 3;
      _level = 1;
      _timerSeconds = 90;
      _items.clear();
      _particles.clear();
      _floatingScores.clear();
      _elapsed = 0;
      _spawnTimer = 0;
      _spawnInterval = 1.5;
      _maxConcurrent = 3;
      _plasticCount = 0;
      _glassCount = 0;
      _cartonCount = 0;
      _draggedItem = null;
      _lastTick = Duration.zero;
      _frameCount = 0;
      _isWin = false;
      _shakeOffset = 0;
      _shakeIntensity = 0;
      _binGlow = [0, 0, 0];
    });
  }

  void _onTick(Duration elapsed) {
    if (_state == GameState.start || _state == GameState.paused) {
      _lastTick = elapsed;
      return;
    }
    if (_state == GameState.gameOver) return;

    final dt = (elapsed - _lastTick).inMicroseconds / 1000000;
    _lastTick = elapsed;
    if (dt <= 0 || dt > 0.1) return;

    _elapsed += dt;
    _timerSeconds -= dt;

    if (_shakeIntensity > 0) {
      _shakeIntensity *= 0.85;
      if (_shakeIntensity < 0.5) _shakeIntensity = 0;
      _shakeOffset = sin(_elapsed * 60) * _shakeIntensity;
    }

    for (int i = 0; i < 3; i++) {
      if (_binGlow[i] > 0) _binGlow[i] = max(0, _binGlow[i] - dt * 3);
    }

    if (_timerSeconds <= 0) {
      _timerSeconds = 0;
      _state = GameState.gameOver;
      _isWin = true;
      setState(() {});
      return;
    }

    _level = 1 + (_elapsed / 30).floor();
    _maxConcurrent = 3 + (_level - 1);
    _spawnInterval = max(0.3, 1.5 - _level * 0.12);

    final aliveItems = _items.where((i) => i.alive).length;
    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval && aliveItems < _maxConcurrent) {
      _spawnTimer = 0;
      _spawnItem();
    }

    for (final item in _items) {
      if (item != _draggedItem && item.alive) {
        item.y += item.speed * dt;
        item.rotation += item.rotationSpeed * dt;
      }
    }

    for (int i = _items.length - 1; i >= 0; i--) {
      final item = _items[i];
      if (!item.alive) continue;
      if (item == _draggedItem) continue;

      if (item.y - _itemSize * item.scale / 2 > _gameSize.height) {
        _loseLife();
        item.alive = false;
        _items.removeAt(i);
      }
    }

    for (int i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 200 * dt;
      p.life -= dt;
      if (p.dead) _particles.removeAt(i);
    }

    for (int i = _floatingScores.length - 1; i >= 0; i--) {
      final fs = _floatingScores[i];
      fs.y -= 60 * dt;
      fs.life -= dt;
      if (fs.dead) _floatingScores.removeAt(i);
    }

    _frameCount++;
    if ((_frameCount & 1) == 0) {
      setState(() {});
    }
  }

  void _spawnItem() {
    final x = _rng.nextDouble() * (_gameSize.width - 80) + 40;
    final types = ItemType.values;
    final type = types[_rng.nextInt(types.length)];
    final subType = _rng.nextInt(3);
    final speed = (80 + _elapsed * 1.2) * (0.85 + _rng.nextDouble() * 0.3);
    final rotation = _rng.nextDouble() * 2 * pi;
    final rotationSpeed = (_rng.nextDouble() - 0.5) * 2;
    final scale = 0.75 + _rng.nextDouble() * 0.5;
    _items.add(FallingItem(
      x: x, y: -_itemSize * scale,
      type: type, subType: subType,
      speed: speed, rotation: rotation,
      rotationSpeed: rotationSpeed, scale: scale,
    ));
  }

  void _loseLife() {
    HapticFeedback.heavyImpact();
    _lives--;
    _shakeIntensity = 8;
    if (_lives <= 0) {
      _lives = 0;
      _state = GameState.gameOver;
      _isWin = false;
    }
    _flashFeedback(false);
  }

  void _scorePoint(ItemType type, double x, double y) {
    _score += 10 * _level;
    HapticFeedback.lightImpact();
    switch (type) {
      case ItemType.plastic: _plasticCount++; break;
      case ItemType.glass: _glassCount++; break;
      case ItemType.carton: _cartonCount++; break;
    }
    _floatingScores.add(FloatingScore(x: x, y: y, score: 10 * _level, correct: true));
    _spawnParticles(x, y, type == ItemType.plastic ? _plasticColor : type == ItemType.glass ? _glassColor : _cartonColor);
    _binGlow[ItemType.values.indexOf(type)] = 1.0;
    _flashFeedback(true);
  }

  void _spawnParticles(double x, double y, Color color) {
    for (int i = 0; i < 12; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 80 + _rng.nextDouble() * 120;
      _particles.add(Particle(
        x: x, y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 80,
        life: 0.6 + _rng.nextDouble() * 0.4,
        maxLife: 1.0,
        color: color.withValues(alpha: 0.7 + _rng.nextDouble() * 0.3),
        size: 3 + _rng.nextDouble() * 4,
      ));
    }
  }

  void _flashFeedback(bool correct) {
    _feedbackColor = correct ? Colors.green : Colors.red;
    _feedbackOpacity = 0.35;
    setState(() {});
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _feedbackOpacity = 0;
        setState(() {});
      }
    });
  }

  void _dropItem() {
    if (_draggedItem == null) return;
    final item = _draggedItem!;
    _draggedItem = null;

    final s = item.scale;
    final itemRect = Rect.fromCenter(
      center: Offset(item.x, item.y),
      width: _itemSize * s * 1.2,
      height: _itemSize * s * 1.2,
    );

    for (int b = 0; b < 3; b++) {
      final binRect = Rect.fromCenter(
        center: Offset(_binCenters[b], _binY),
        width: _binWidth,
        height: _binHeight,
      );
      if (itemRect.overlaps(binRect)) {
        if (item.type == ItemType.values[b]) {
          _scorePoint(item.type, item.x, item.y);
        } else {
          _loseLife();
        }
        item.alive = false;
        _items.remove(item);
        return;
      }
    }

    _loseLife();
    item.alive = false;
    _items.remove(item);
  }

  void _onTouchDown(TapDownDetails d) {
    if (_state != GameState.playing) return;
    final pos = d.localPosition;

    for (int i = _items.length - 1; i >= 0; i--) {
      final item = _items[i];
      if (!item.alive) continue;
      final dist = (Offset(item.x, item.y) - pos).distance;
      if (dist < _itemSize * item.scale / 2 + 8) {
        _draggedItem = item;
        return;
      }
    }
  }

  void _onTouchMove(DragUpdateDetails d) {
    if (_draggedItem == null) return;
    _draggedItem!.x = (_draggedItem!.x + d.delta.dx).clamp(
      _itemSize / 2, _gameSize.width - _itemSize / 2);
    _draggedItem!.y = (_draggedItem!.y + d.delta.dy).clamp(
      _itemSize / 2, _gameSize.height - _itemSize / 2);
  }

  void _onTouchUp() {
    _dropItem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F0E0),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _initLayout(Size(constraints.maxWidth, constraints.maxHeight));
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTapDown: _onTouchDown,
                  onPanStart: (d) => _onTouchDown(TapDownDetails(localPosition: d.localPosition)),
                  onPanUpdate: _onTouchMove,
                  onPanEnd: (_) => _onTouchUp(),
                  child: RepaintBoundary(
                    child: CustomPaint(
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
                        frameCount: _frameCount,
                        particles: _particles,
                        floatingScores: _floatingScores,
                        shakeOffset: _shakeOffset,
                        binGlow: _binGlow,
                        state: _state,
                      ),
                    ),
                  ),
                ),
              ),
              if (_state == GameState.start) _buildStartScreen(),
              if (_state == GameState.playing) ..._buildUI(),
              if (_state == GameState.paused) _buildPauseScreen(),
              if (_state == GameState.gameOver) _buildGameOver(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.recycling, size: 72, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text('EcoRecicla',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900,
              color: AppColors.primary, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text('¡Separa los residuos\nen la caneca correcta!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.4)),
          const SizedBox(height: 40),
          _buildStyledButton(
            text: 'JUGAR',
            icon: Icons.play_arrow_rounded,
            onTap: _startGame,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app, size: 18, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text('Arrastra cada residuo a su caneca',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseScreen() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 50),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, 10))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.pause_circle_filled, size: 52, color: AppColors.primary),
            const SizedBox(height: 12),
            const Text('Juego en pausa',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark)),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: _buildStyledButton(
              text: 'REANUDAR', icon: Icons.play_arrow_rounded,
              onTap: () => setState(() => _state = GameState.playing),
            )),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _state = GameState.start;
                  _items.clear();
                  _particles.clear();
                  _floatingScores.clear();
                });
              },
              icon: const Icon(Icons.home_outlined, size: 18),
              label: const Text('Salir al inicio'),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildStyledButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 200,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  List<Widget> _buildUI() {
    final minutes = (_timerSeconds / 60).floor();
    final seconds = _timerSeconds % 60;
    final timerStr = '$minutes:${seconds.toStringAsFixed(0).padLeft(2, '0')}';
    return [
      Positioned(top: 8, left: 8, child: _chip(Icons.score_outlined, '$_score')),
      Positioned(top: 8, left: 90, child: _chip(Icons.favorite_border, '$_lives')),
      Positioned(top: 8, right: 44, child: _chip(Icons.timer_outlined, timerStr)),
      Positioned(top: 34, right: 44, child: _chip(Icons.trending_up, 'Nv $_level')),
      Positioned(
        top: 8, right: 8,
        child: GestureDetector(
          onTap: () => setState(() => _state = GameState.paused),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.pause_rounded, color: Colors.white, size: 20),
          ),
        ),
      ),
      Positioned(
        bottom: 8, left: 0, right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Arrastra los residuos con el dedo',
              style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ),
      ),
    ];
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
      ]),
    );
  }

  Widget _buildGameOver() {
    final minutes = (_timerSeconds / 60).floor();
    final seconds = _timerSeconds % 60;
    final timerStr = '$minutes:${seconds.toStringAsFixed(0).padLeft(2, '0')}';
    final isWin = _isWin;
    return Container(
      color: Colors.black54,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, 10))],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (isWin) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset('assets/images/diego.jpeg', width: 120, height: 120, fit: BoxFit.cover),
                ),
                const SizedBox(height: 12),
                const Text('¡Ganaste!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.primary)),
                const SizedBox(height: 4),
                Text('Puntaje final: $_score',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              ] else ...[
                const Icon(Icons.sentiment_dissatisfied, size: 52, color: Colors.orange),
                const SizedBox(height: 10),
                const Text('Juego terminado',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text('Puntaje: $_score',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ],
              const SizedBox(height: 6),
              Text('Nivel $_level  •  $timerStr',
                style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
              const SizedBox(height: 14),
              _statRow(_plasticColor, 'Plástico', _plasticCount),
              _statRow(_glassColor, 'Vidrio', _glassCount),
              _statRow(_cartonColor, 'Cartón', _cartonCount),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: _buildStyledButton(
                text: 'REINTENTAR', icon: Icons.refresh_rounded,
                onTap: _startGame,
              )),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => setState(() => _state = GameState.start),
                icon: const Icon(Icons.home_outlined, size: 18),
                label: const Text('Ir al inicio'),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              ),
            ]),
          ),
        ),
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
// Game Painter
// ══════════════════════════════════════════════
class _GamePainter extends CustomPainter {
  final List<FallingItem> items;
  final FallingItem? draggedItem;
  final List<double> binCenters;
  final double binWidth, binHeight, binY;
  final Color feedbackColor;
  final double feedbackOpacity;
  final Size screenSize;
  final int frameCount;
  final List<Particle> particles;
  final List<FloatingScore> floatingScores;
  final double shakeOffset;
  final List<double> binGlow;
  final GameState state;

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
    required this.frameCount,
    required this.particles,
    required this.floatingScores,
    required this.shakeOffset,
    required this.binGlow,
    required this.state,
  });

  ui.Picture? _bgPicture;
  Size _bgSize = Size.zero;

  static final Paint _fillPaint = Paint();
  static final Paint _shinePaint = Paint();
  static final Paint _shadowPaint = Paint();
  static final Paint _strokePaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _glowPaint = Paint();

  void _ensureBackground(Canvas canvas, Size size) {
    if (_bgPicture != null && _bgSize == size) {
      canvas.drawPicture(_bgPicture!);
      return;
    }

    final recorder = ui.PictureRecorder();
    final c = Canvas(recorder);
    _drawStaticBackground(c, size);
    _bgPicture = recorder.endRecording();
    _bgSize = size;
    canvas.drawPicture(_bgPicture!);
  }

  void _drawStaticBackground(Canvas canvas, Size size) {
    final skyGrad = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [const Color(0xFF87CEEB), const Color(0xFFC8E6C9), const Color(0xFFE8F5E9)]);
    _fillPaint.shader = skyGrad.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fillPaint);
    _fillPaint.shader = null;

    _cloud(canvas, size.width * 0.12, size.height * 0.06, size.width * 0.09);
    _cloud(canvas, size.width * 0.7, size.height * 0.09, size.width * 0.07);
    _cloud(canvas, size.width * 0.38, size.height * 0.04, size.width * 0.06);

    _drawSun(canvas, size);

    _drawTree(canvas, size.width * 0.07, size.height * 0.5, size.width * 0.14);
    _drawTree(canvas, size.width * 0.93, size.height * 0.53, size.width * 0.12);

    final groundTop = size.height - 40;
    final groundGrad = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [const Color(0xFF6B8E23), const Color(0xFF556B2F)]);
    _fillPaint.shader = groundGrad.createShader(Rect.fromLTWH(0, groundTop, size.width, 40));
    canvas.drawRect(Rect.fromLTWH(0, groundTop, size.width, 40), _fillPaint);
    _fillPaint.shader = null;

    _strokePaint.color = const Color(0xFF4A7A2E);
    _strokePaint.strokeWidth = 2;
    for (double x = 0; x < size.width; x += 14) {
      final h = 4 + sin(x * 0.35) * 3;
      canvas.drawLine(Offset(x, groundTop), Offset(x, groundTop - h), _strokePaint);
    }
  }

  void _drawSun(Canvas canvas, Size size) {
    final cx = size.width * 0.85;
    final cy = size.height * 0.07;
    final r = size.width * 0.055;

    _fillPaint.color = const Color(0xFFFFF176);
    canvas.drawCircle(Offset(cx, cy), r, _fillPaint);

    _fillPaint.color = const Color(0xFFFFF176).withValues(alpha: 0.25);
    _fillPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(Offset(cx, cy), r * 1.8, _fillPaint);
    _fillPaint.maskFilter = null;

    _strokePaint.color = Colors.white.withValues(alpha: 0.35);
    _strokePaint.strokeWidth = 2;
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      canvas.drawLine(
        Offset(cx + cos(angle) * r * 1.3, cy + sin(angle) * r * 1.3),
        Offset(cx + cos(angle) * r * 2.0, cy + sin(angle) * r * 2.0),
        _strokePaint,
      );
    }
  }

  void _drawTree(Canvas canvas, double x, double y, double w) {
    _fillPaint.color = const Color(0xFF6D4C2A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y + w * 0.1), width: w * 0.1, height: w * 0.35),
        Radius.circular(3)),
      _fillPaint);

    _fillPaint.color = const Color(0xFF2E7D32);
    canvas.drawCircle(Offset(x - w * 0.1, y - w * 0.15), w * 0.25, _fillPaint);
    canvas.drawCircle(Offset(x + w * 0.1, y - w * 0.1), w * 0.2, _fillPaint);
    canvas.drawCircle(Offset(x, y - w * 0.25), w * 0.22, _fillPaint);
    canvas.drawCircle(Offset(x, y - w * 0.05), w * 0.16, _fillPaint);
  }

  void _cloud(Canvas canvas, double x, double y, double r) {
    _fillPaint.color = Colors.white.withValues(alpha: 0.55);
    canvas.drawCircle(Offset(x, y), r, _fillPaint);
    canvas.drawCircle(Offset(x + r * 0.8, y - r * 0.3), r * 0.7, _fillPaint);
    canvas.drawCircle(Offset(x - r * 0.7, y - r * 0.2), r * 0.6, _fillPaint);
    canvas.drawCircle(Offset(x + r * 0.4, y + r * 0.2), r * 0.5, _fillPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(shakeOffset, 0);

    _ensureBackground(canvas, size);
    _drawBins(canvas, size);

    for (final item in items) {
      if (item != draggedItem && item.alive) _drawItem(canvas, item);
    }
    if (draggedItem != null && draggedItem!.alive) {
      _drawItem(canvas, draggedItem!);
    }

    _drawParticles(canvas);
    _drawFloatingScores(canvas);
    _drawFeedback(canvas, size);

    canvas.restore();

    if (state == GameState.start) {
      _drawStartOverlay(canvas, size);
    }
  }

  void _drawStartOverlay(Canvas canvas, Size size) {
    _fillPaint.color = Colors.black.withValues(alpha: 0.08);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fillPaint);
  }

  void _drawBins(Canvas canvas, Size size) {
    final labels = ['PLÁSTICO', 'VIDRIO', 'CARTÓN'];
    final colors = [_plasticColor, _glassColor, _cartonColor];
    final lidColors = [
      const Color(0xFFF9A825),
      const Color(0xFF388E3C),
      const Color(0xFF1976D2),
    ];

    for (int i = 0; i < 3; i++) {
      final cx = binCenters[i];
      final left = cx - binWidth / 2;
      final top = binY - binHeight / 2;
      final glow = binGlow[i];

      if (glow > 0) {
        _glowPaint.color = colors[i].withValues(alpha: glow * 0.35);
        _glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(left - 6, top - 6, binWidth + 12, binHeight + 12), Radius.circular(14)),
          _glowPaint);
        _glowPaint.maskFilter = null;
      }

      _shadowPaint.color = Colors.black.withValues(alpha: 0.15);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(left + 3, top + 3, binWidth, binHeight), Radius.circular(10)),
        _shadowPaint);

      _fillPaint.color = colors[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(left, top, binWidth, binHeight), Radius.circular(10)),
        _fillPaint);

      _shinePaint.color = Colors.white.withValues(alpha: 0.1);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(left + 3, top + 4, binWidth * 0.1, binHeight * 0.45), Radius.circular(2)),
        _shinePaint);

      _fillPaint.color = lidColors[i];
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(left - 2, top - 5, binWidth + 4, binHeight * 0.16),
          topLeft: const Radius.circular(12), topRight: const Radius.circular(12)),
        _fillPaint);

      _fillPaint.color = lidColors[i].withValues(alpha: 0.85);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(left - 1, top - 7, binWidth + 2, 3), Radius.circular(1.5)),
        _fillPaint);

      _fillPaint.color = Colors.black.withValues(alpha: 0.18);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left + binWidth * 0.2, top + binHeight * 0.12, binWidth * 0.6, binHeight * 0.05),
          Radius.circular(3)),
        _fillPaint);

      _recycleIcon(canvas, cx, top + binHeight * 0.32, binWidth * 0.26);

      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: TextStyle(
          color: Colors.white, fontSize: binWidth * 0.1, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        textDirection: TextDirection.ltr, textAlign: TextAlign.center);
      tp.layout(maxWidth: binWidth - 4);
      tp.paint(canvas, Offset(cx - tp.width / 2, top + binHeight - binHeight * 0.2));
    }
  }

  void _recycleIcon(Canvas canvas, double cx, double y, double sz) {
    _strokePaint.color = Colors.white.withValues(alpha: 0.55);
    _strokePaint.strokeWidth = 2;
    _strokePaint.strokeCap = StrokeCap.round;
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
      const as = 4;
      path.moveTo(tip.dx, tip.dy);
      path.lineTo(tip.dx + cos(aa + 0.5) * as, tip.dy + sin(aa + 0.5) * as);
      path.moveTo(tip.dx, tip.dy);
      path.lineTo(tip.dx + cos(aa - 0.5) * as, tip.dy + sin(aa - 0.5) * as);
    }
    canvas.drawPath(path, _strokePaint);
  }

  void _drawItem(Canvas canvas, FallingItem item) {
    final scale = item == draggedItem ? 1.15 * item.scale : item.scale;
    canvas.save();
    canvas.translate(item.x, item.y);
    canvas.rotate(item.rotation);
    canvas.scale(scale, scale);

    if (item == draggedItem) {
      _fillPaint.color = Colors.yellow.withValues(alpha: 0.2);
      _fillPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(const Offset(0, 0), _itemSize * 0.55, _fillPaint);
      _fillPaint.maskFilter = null;
    }

    switch (item.type) {
      case ItemType.plastic:
        if (item.subType == 0) _paintBottle(canvas);
        else if (item.subType == 1) _paintBag(canvas);
        else _paintContainer(canvas);
        break;
      case ItemType.glass:
        if (item.subType == 0) _paintGlassBottle(canvas);
        else _paintJar(canvas);
        break;
      case ItemType.carton:
        if (item.subType == 0) _paintBox(canvas);
        else if (item.subType == 1) _paintSheet(canvas);
        else _paintCarton(canvas);
        break;
    }

    _strokePaint.color = Colors.white.withValues(alpha: 0.4);
    _strokePaint.strokeWidth = 2.5;
    _strokePaint.style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, 0), width: _itemSize * 0.85, height: _itemSize * 0.85),
        Radius.circular(6)),
      _strokePaint);
    _strokePaint.style = PaintingStyle.fill;

    canvas.restore();
  }

  void _drawShadow(Canvas canvas) {
    _fillPaint.color = Colors.black.withValues(alpha: 0.12);
    canvas.drawOval(Rect.fromCenter(center: const Offset(2, -2), width: _itemSize * 0.7, height: 4), _fillPaint);
  }

  void _drawParticles(Canvas canvas) {
    for (final p in particles) {
      final alpha = (p.life / p.maxLife).clamp(0, 1);
      _fillPaint.color = p.color.withValues(alpha: alpha.toDouble());
      canvas.drawCircle(Offset(p.x, p.y), p.size * alpha, _fillPaint);
    }
  }

  void _drawFloatingScores(Canvas canvas) {
    for (final fs in floatingScores) {
      final alpha = fs.life.clamp(0, 1);
      final tp = TextPainter(
        text: TextSpan(
          text: '+${fs.score}',
          style: TextStyle(
            color: fs.correct ? AppColors.primary : Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: Colors.black.withValues(alpha: 0.15 * alpha), blurRadius: 4)],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(fs.x - tp.width / 2, fs.y - 20));
    }
  }

  void _paintBottle(Canvas canvas) {
    _drawShadow(canvas);
    final s = _itemSize / 48;
    final w = 28 * s, h = 42 * s;
    final nw = 10 * s, nh = 10 * s, ch = 4 * s;
    final bh = h - nh - ch;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, bh / 2 - h / 2), width: w, height: bh), Radius.circular(w * 0.25));
    _fillPaint.shader = const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight,
      colors: [Color(0xFFFFF176), Color(0xFFFBC02D), Color(0xFFFFF176)]).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, _fillPaint);
    _fillPaint.shader = null;
    _fillPaint.color = const Color(0xFFF9A825);
    canvas.drawRect(Rect.fromCenter(center: Offset(0, -h / 2 + nh / 2 + ch), width: nw, height: nh), _fillPaint);
    _fillPaint.color = const Color(0xFFF57F17);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -h / 2 + ch / 2), width: nw + 3, height: ch),
        Radius.circular(2)), _fillPaint);
    _shinePaint.color = Colors.white.withValues(alpha: 0.3);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(-w * 0.22, 0), width: 4, height: bh * 0.6), Radius.circular(2)), _shinePaint);
    _shinePaint.color = Colors.white.withValues(alpha: 0.2);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, 0), width: w * 0.6, height: bh * 0.2), Radius.circular(2)), _shinePaint);
    _shinePaint.color = Colors.white.withValues(alpha: 0.25);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, bh * 0.15), width: w * 0.5, height: bh * 0.12), Radius.circular(2)), _shinePaint);
  }

  void _paintBag(Canvas canvas) {
    _drawShadow(canvas);
    final s = _itemSize / 48;
    final w = 34 * s, h = 36 * s;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, 0), width: w, height: h), Radius.circular(6));
    _fillPaint.shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFFFF9C4), Color(0xFFFBC02D), Color(0xFFF9A825)]).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, _fillPaint);
    _fillPaint.shader = null;
    final top = -h / 2;
    _fillPaint.color = const Color(0xFFF57F17);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w * 0.35, top - 2, w * 0.7, 6), Radius.circular(3)), _fillPaint);
    _strokePaint.color = const Color(0xFFF57F17);
    _strokePaint.strokeWidth = 3;
    _strokePaint.strokeCap = StrokeCap.round;
    final handle = Path()
      ..moveTo(-w * 0.25, top)
      ..quadraticBezierTo(-w * 0.1, top - h * 0.15, 0, top - h * 0.12)
      ..quadraticBezierTo(w * 0.1, top - h * 0.15, w * 0.25, top);
    canvas.drawPath(handle, _strokePaint);
    _strokePaint.color = Colors.white.withValues(alpha: 0.2);
    _strokePaint.strokeWidth = 1.5;
    canvas.drawLine(Offset(-w * 0.15, 2), Offset(w * 0.15, 2), _strokePaint);
    canvas.drawLine(Offset(-w * 0.1, 6), Offset(w * 0.1, 6), _strokePaint);
  }

  void _paintContainer(Canvas canvas) {
    _drawShadow(canvas);
    final s = _itemSize / 48;
    final w = 32 * s, h = 30 * s;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, 0), width: w, height: h), Radius.circular(8));
    _fillPaint.shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFFFF176), Color(0xFFFBC02D), Color(0xFFF9A825)]).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, _fillPaint);
    _fillPaint.shader = null;
    _fillPaint.color = const Color(0xFFF57F17);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, -h / 2 + 4), width: w * 0.5, height: 6), Radius.circular(2)), _fillPaint);
    _shinePaint.color = Colors.white.withValues(alpha: 0.2);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, h * 0.1), width: w * 0.6, height: h * 0.18), Radius.circular(2)), _shinePaint);
    _shinePaint.color = Colors.white.withValues(alpha: 0.15);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(-w * 0.2, -h * 0.1), width: 3, height: h * 0.35), Radius.circular(1.5)), _shinePaint);
  }

  void _paintGlassBottle(Canvas canvas) {
    _drawShadow(canvas);
    final s = _itemSize / 48;
    final w = 24 * s, h = 44 * s;
    final nw = 7 * s, nh = 14 * s, ch = 3 * s;
    final bh = h - nh - ch;
    final bp = Path();
    final bt = -h / 2 + ch + nh;
    final bb = h / 2;
    bp.moveTo(-w / 2, bt);
    bp.lineTo(-w / 2, bb - w / 3);
    bp.quadraticBezierTo(-w / 2, bb, 0, bb);
    bp.quadraticBezierTo(w / 2, bb, w / 2, bb - w / 3);
    bp.lineTo(w / 2, bt);
    bp.close();
    _fillPaint.shader = const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight,
      colors: [Color(0xFFA5D6A7), Color(0xFF4CAF50), Color(0xFFA5D6A7)])
      .createShader(Rect.fromCenter(center: const Offset(0, 0), width: w, height: bh));
    canvas.drawPath(bp, _fillPaint);
    _fillPaint.shader = null;
    _fillPaint.color = const Color(0xFF4CAF50);
    canvas.drawRect(Rect.fromCenter(center: Offset(0, -h / 2 + ch + nh / 2), width: nw, height: nh), _fillPaint);
    _fillPaint.color = const Color(0xFF9E9E9E);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, -h / 2 + ch / 2), width: nw + 3, height: ch), Radius.circular(1.5)), _fillPaint);
    _fillPaint.color = Colors.white.withValues(alpha: 0.2);
    canvas.drawPath(_bottleRidge(bt, bb), _fillPaint);
    _shinePaint.color = Colors.white.withValues(alpha: 0.18);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, bt + bh * 0.35), width: w * 0.55, height: bh * 0.18), Radius.circular(2)), _shinePaint);
  }

  Path _bottleRidge(double bt, double bb) {
    final rp = Path();
    rp.moveTo(-12, bt + 3);
    rp.lineTo(-8, bt + 3);
    rp.lineTo(-14, bb - 3);
    rp.lineTo(-10, bb - 3);
    rp.close();
    return rp;
  }

  void _paintJar(Canvas canvas) {
    _drawShadow(canvas);
    final s = _itemSize / 48;
    final w = 30 * s, h = 34 * s;
    final nw = 18 * s, nh = 6 * s;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, 0), width: w, height: h), Radius.circular(6));
    _fillPaint.shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFC8E6C9), Color(0xFF4CAF50), Color(0xFFC8E6C9)]).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, _fillPaint);
    _fillPaint.shader = null;
    _fillPaint.color = const Color(0xFF9E9E9E);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, -h / 2 + 2), width: nw, height: nh), Radius.circular(3)), _fillPaint);
    _fillPaint.color = const Color(0xFF757575);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, -h / 2 + 1), width: nw + 4, height: 3), Radius.circular(1.5)), _fillPaint);
    _shinePaint.color = Colors.white.withValues(alpha: 0.15);
    canvas.drawRect(Rect.fromCenter(center: Offset(-w * 0.2, h * 0.05), width: 3, height: h * 0.35), _shinePaint);
    _shinePaint.color = Colors.white.withValues(alpha: 0.1);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.15, -h * 0.05), width: 2, height: h * 0.2), _shinePaint);
  }

  void _paintBox(Canvas canvas) {
    _drawShadow(canvas);
    final s = _itemSize / 48;
    final w = 34 * s, h = 30 * s;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, 0), width: w, height: h), Radius.circular(3));
    _fillPaint.shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [const Color.fromARGB(255, 187, 222, 251), const Color(0xFF42A5F5), const Color.fromARGB(255, 187, 222, 251)])
      .createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, _fillPaint);
    _fillPaint.shader = null;
    _fillPaint.color = const Color(0xFF1E88E5).withValues(alpha: 0.7);
    final flap = Path();
    flap.moveTo(-w / 2, -h / 2);
    flap.lineTo(0, -h / 2 - h * 0.18);
    flap.lineTo(w / 2, -h / 2);
    flap.close();
    canvas.drawPath(flap, _fillPaint);
    _strokePaint.color = Colors.black.withValues(alpha: 0.08);
    _strokePaint.strokeWidth = 1.5;
    canvas.drawLine(Offset(0, -h / 2), Offset(0, -h / 2 - h * 0.18), _strokePaint);
    _strokePaint.color = Colors.white.withValues(alpha: 0.2);
    canvas.drawLine(Offset(-w * 0.2, h * 0.05), Offset(w * 0.2, h * 0.05), _strokePaint);
    canvas.drawLine(Offset(-w * 0.15, h * 0.13), Offset(w * 0.15, h * 0.13), _strokePaint);
    _shinePaint.color = Colors.white.withValues(alpha: 0.12);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(-w * 0.15, -h * 0.05), width: 3, height: h * 0.4), Radius.circular(1.5)), _shinePaint);
  }

  void _paintSheet(Canvas canvas) {
    _drawShadow(canvas);
    final s = _itemSize / 48;
    final w = 32 * s, h = 38 * s;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(2, 0), width: w, height: h), Radius.circular(2));
    _fillPaint.shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFE3F2FD), Color(0xFF90CAF9), Color(0xFF64B5F6)]).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, _fillPaint);
    _fillPaint.shader = null;
    _strokePaint.color = Colors.black.withValues(alpha: 0.06);
    _strokePaint.strokeWidth = 1;
    canvas.drawLine(Offset(-w * 0.3, -h * 0.3), Offset(w * 0.3, h * 0.3), _strokePaint);
    _strokePaint.color = Colors.black.withValues(alpha: 0.08);
    _strokePaint.strokeWidth = 1.5;
    canvas.drawLine(Offset(-w * 0.15, -h * 0.1), Offset(w * 0.15, -h * 0.1), _strokePaint);
    canvas.drawLine(Offset(-w * 0.1, 0), Offset(w * 0.1, 0), _strokePaint);
    _fillPaint.color = Colors.black.withValues(alpha: 0.1);
    canvas.drawRect(Rect.fromCenter(center: Offset(-w * 0.15, h * 0.12), width: 3, height: h * 0.08), _fillPaint);
  }

  void _paintCarton(Canvas canvas) {
    _drawShadow(canvas);
    final s = _itemSize / 48;
    final w = 34 * s, h = 38 * s;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, 0), width: w, height: h), Radius.circular(3));
    _fillPaint.shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF90CAF9), Color(0xFF42A5F5), Color(0xFF1E88E5)]).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, _fillPaint);
    _fillPaint.shader = null;
    _fillPaint.color = const Color(0xFF1E88E5).withValues(alpha: 0.85);
    final gp = Path();
    gp.moveTo(-w / 2, -h / 2);
    gp.lineTo(0, -h / 2 - h * 0.2);
    gp.lineTo(w / 2, -h / 2);
    gp.close();
    canvas.drawPath(gp, _fillPaint);
    _strokePaint.color = Colors.black.withValues(alpha: 0.12);
    _strokePaint.strokeWidth = 1.5;
    canvas.drawLine(Offset(0, -h / 2), Offset(0, -h / 2 - h * 0.2), _strokePaint);
    _fillPaint.color = const Color(0xFF1565C0);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, -h / 2 - h * 0.07), width: 5, height: 5), Radius.circular(1)), _fillPaint);
    _recycleIcon(canvas, 0, h * 0.1, w * 0.3);
    _strokePaint.color = Colors.white.withValues(alpha: 0.25);
    _strokePaint.strokeWidth = 1.5;
    canvas.drawLine(Offset(-w * 0.2, h * 0.25), Offset(w * 0.2, h * 0.25), _strokePaint);
    canvas.drawLine(Offset(-w * 0.15, h * 0.32), Offset(w * 0.12, h * 0.32), _strokePaint);
  }

  void _drawFeedback(Canvas canvas, Size size) {
    if (feedbackOpacity > 0) {
      _fillPaint.color = feedbackColor.withValues(alpha: feedbackOpacity);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GamePainter oldDelegate) {
    return oldDelegate.frameCount != frameCount ||
        oldDelegate.state != state;
  }
}
