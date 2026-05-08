// lib/screens/reciclar_screen.dart

import 'package:flutter/material.dart';

class ReciclarScreen extends StatelessWidget {
  const ReciclarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reciclar'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      // ── Centro de pantalla con ícono y mensaje ──────────
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.recycling, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Módulo de reciclaje',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Próximamente...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}