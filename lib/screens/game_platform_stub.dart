import 'package:flutter/material.dart';

class PlatformGameView extends StatelessWidget {
  final String url;
  const PlatformGameView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Plataforma no soportada'),
    );
  }
}
