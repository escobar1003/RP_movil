// lib/screens/welcome_screen.dart

import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── Fondo verde oscuro como en tu diseño ────────────
      backgroundColor: const Color(0xFF2D5A1B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [

              const Spacer(flex: 2),

              // ── ILUSTRACIÓN (cubo de basura con hojas) ──
              // Usamos un ícono grande mientras no tenemos imagen
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF3D7A25),
                  borderRadius: BorderRadius.circular(80),
                ),
                child: const Icon(
                  Icons.recycling,
                  size: 90,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 40),

              // ── TÍTULO ──────────────────────────────────
              const Text(
                '¡Hola!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // ── SUBTÍTULO ────────────────────────────────
              const Text(
                'Bienvenido reciclador\nPor un planeta más limpio.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5, // ← espaciado entre líneas
                ),
              ),

              const Spacer(flex: 3),

              // ── BOTÓN COMENZAR (registro) ────────────────
              SizedBox(
                width: double.infinity, // ← ocupa todo el ancho
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Navega a registro
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7BC043), // verde claro
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Comenzar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── BOTÓN INICIAR SESIÓN ─────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const Spacer(),

            ],
          ),
        ),
      ),
    );
  }
}