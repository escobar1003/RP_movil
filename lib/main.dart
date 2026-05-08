// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart'; // ← cambia este import

void main() {
  runApp(const EcoReciclaApp());
}

class EcoReciclaApp extends StatelessWidget {
  const EcoReciclaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoRecicla',
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const WelcomeScreen(), // ← ahora arranca aquí
    );
  }
}