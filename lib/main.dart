// lib/main.dart
 
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';
 
void main() => runApp(const EcoReciclaApp());
 
class EcoReciclaApp extends StatelessWidget {
  const EcoReciclaApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoRecicla',
      theme: AppTheme.theme,
      home: const WelcomeScreen(),
    );
  }
}
 