// lib/screens/welcome_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),

              // ── Ilustración central ─────────────────────────
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.green100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.recycling, size: 90, color: AppColors.primary),
              ),

              const SizedBox(height: 32),

              // ── Título ──────────────────────────────────────
              const Text(
                '¡Hola!\nBienvenido reciclador',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Cada acción cuenta para\nun planeta más limpio.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textMid,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // ── Botón Comenzar ──────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text('Comenzar'),
                ),
              ),

              const SizedBox(height: 14),

              // ── Enlace Iniciar sesión ────────────────────────
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}