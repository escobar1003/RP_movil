import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _gameOver = false;
  int _score = 0;
  int _correct = 0;
  int _wrong = 0;
  int _plasticCount = 0;
  int _glassCount = 0;
  int _paperCount = 0;
  int _organicCount = 0;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  Future<void> _initGame() async {
    final html = await rootBundle.loadString('assets/babylon_game/index.html');
    final css = await rootBundle.loadString('assets/babylon_game/game.css');
    final js = await rootBundle.loadString('assets/babylon_game/game.js');

    final composedHtml = html
        .replaceFirst('/* CSS */', css)
        .replaceFirst('/* JS */', js);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('GameChannel', onMessageReceived: _onGameMessage)
      ..setNavigationDelegate(
        NavigationDelegate(onPageFinished: (_) {
          setState(() => _isLoading = false);
        }),
      )
      ..loadHtmlString(composedHtml);

    setState(() {});
  }

  void _onGameMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      switch (data['action'] as String) {
        case 'updateScore':
          setState(() {
            _score = data['score'] as int;
            _correct = data['correct'] as int;
            _wrong = data['wrong'] as int;
          });
          break;
        case 'gameOver':
          setState(() {
            _gameOver = true;
            _score = data['score'] as int;
            _correct = data['correct'] as int;
            _wrong = data['wrong'] as int;
            _plasticCount = data['plastic'] as int;
            _glassCount = data['glass'] as int;
            _paperCount = data['paper'] as int;
            _organicCount = data['organic'] as int;
          });
          break;
        case 'feedback':
          _showFeedback(data['correct'] as bool);
          break;
      }
    } catch (_) {}
  }

  void _showFeedback(bool correct) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(correct ? '+10 puntos!' : '-5 puntos'),
        backgroundColor: correct ? Colors.green : Colors.red,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _sendGameCommand(String command, [Map<String, dynamic>? args]) {
    final json = jsonEncode({'command': command, 'args': args ?? {}});
    _controller?.runJavaScript('onFlutterCommand($json)');
  }

  void _restartGame() {
    setState(() {
      _gameOver = false;
      _score = 0;
      _correct = 0;
      _wrong = 0;
      _plasticCount = 0;
      _glassCount = 0;
      _paperCount = 0;
      _organicCount = 0;
    });
    _sendGameCommand('restart');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _gameOver
            ? null
            : AppBar(
                backgroundColor: Colors.black.withValues(alpha: 0.7),
                elevation: 0,
                title: Text('Puntos: $_score',
                    style:
                        const TextStyle(color: Colors.white, fontSize: 16)),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _correct + _wrong > 0
                          ? const Color(0xFF4CAF50)
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_correct}/${_correct + _wrong}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
        body: Stack(
          children: [
            if (_controller != null)
              WebViewWidget(controller: _controller!),
            if (_isLoading)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF4CAF50)),
                    SizedBox(height: 16),
                    Text('Cargando juego 3D...',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            if (_gameOver) _buildGameOver(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.recycling, size: 56, color: Color(0xFF4CAF50)),
            const SizedBox(height: 8),
            const Text('Juego terminado',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF263238))),
            const SizedBox(height: 4),
            Text('Puntaje: $_score',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4CAF50))),
            const SizedBox(height: 12),
            _statRow(const Color(0xFFFBC02D), 'Plástico', _plasticCount),
            _statRow(const Color(0xFF4CAF50), 'Vidrio', _glassCount),
            _statRow(const Color(0xFF2196F3), 'Papel', _paperCount),
            _statRow(const Color(0xFF8D6E63), 'Orgánico', _organicCount),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _restartGame,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver',
                  style: TextStyle(color: Color(0xFF78909C))),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _statRow(Color color, String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label: $count',
            style: const TextStyle(
                fontSize: 14, color: Color(0xFF455A64))),
      ]),
    );
  }
}
