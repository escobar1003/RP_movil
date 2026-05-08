// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'main_navigation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombre   = TextEditingController();
  final _email    = TextEditingController();
  final _password = TextEditingController();
  bool _obscure   = true;

  void _register() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text('Únete a EcoRecicla 🌱',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 6),
            const Text('Crea tu cuenta y empieza a reciclar',
                style: TextStyle(color: AppColors.textMid, fontSize: 14)),
            const SizedBox(height: 36),

            _label('Nombre completo'),
            const SizedBox(height: 6),
            _field(controller: _nombre, hint: 'Ana Martínez', icon: Icons.person_outline),
            const SizedBox(height: 18),

            _label('Correo electrónico'),
            const SizedBox(height: 6),
            _field(controller: _email, hint: 'tu@correo.com', icon: Icons.email_outlined),
            const SizedBox(height: 18),

            _label('Contraseña'),
            const SizedBox(height: 6),
            _field(
              controller: _password,
              hint: '••••••••',
              icon: Icons.lock_outline,
              obscure: _obscure,
              suffix: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textLight, size: 20),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),

            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(onPressed: _register, child: const Text('Crear cuenta')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textMid));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) =>
      TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textLight),
          prefixIcon: Icon(icon, color: AppColors.textLight, size: 20),
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      );
}