// lib/screens/welcome_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [

          // ───────────── FONDO DEGRADADO SUAVE ─────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE8F5E9),
                  Color(0xFFF9FBF7),
                  Color(0xFFFFFFFF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ───────────── CÍRCULOS DECORATIVOS ─────────────
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: const Color(0xFF57C58A).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            top: 60,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF2E9E6F).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -60,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF2E9E6F).withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ───────────── CONTENIDO PRINCIPAL ─────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [

                  const Spacer(),

                  // ── Ilustración con la imagen PNG transparente ──
                  SizedBox(
                    height: size.height * 0.55,
                    child: Image.asset(
                      'assets/images/imagen_de_fondo.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Título ──
                  Text(
                    '¡Hola! 👋\nBienvenido reciclador',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Cada acción cuenta para\nun planeta más limpio.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textMid,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(),

                  // ── Botón Comenzar ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      child: const Text('Comenzar'),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Iniciar sesión ──
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    ),
                    child: Text(
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
        ],
      ),
    );
  }

  Widget _buildLeaf({required double size, required double angle}) {
    return Transform.rotate(
      angle: angle,
      child: Icon(
        Icons.eco,
        size: size,
        color: const Color(0xFF7BC043).withOpacity(0.85),
      ),
    );
  }
}