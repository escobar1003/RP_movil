import 'package:flutter/material.dart';
import 'game_platform_stub.dart'
    if (dart.library.html) 'game_platform_web.dart'
    if (dart.library.io) 'game_platform_mobile.dart';

class JuegoScreen extends StatefulWidget {
  const JuegoScreen({super.key});

  @override
  State<JuegoScreen> createState() => _JuegoScreenState();
}

class _JuegoScreenState extends State<JuegoScreen> {
  final String _gameUrl = 'http://localhost:5173/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoRecicla'),
        backgroundColor: const Color(0xFF0f1726),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PlatformGameView(url: _gameUrl),
    );
  }
}
