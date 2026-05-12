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
      backgroundColor: const Color(0xFF1E3A0F), // verde muy oscuro del fondo
      body: SafeArea(
        child: Column(
          children: [

            // ── PARTE SUPERIOR: ilustración ─────────────────
            Expanded(
              flex: 5,
              child: Stack(
                alignment: Alignment.center,
                children: [

                  // Círculo verde medio de fondo
                  Positioned(
                    top: 30,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D5A1B),
                        borderRadius: BorderRadius.circular(130),
                      ),
                    ),
                  ),

                  // Hojas decorativas arriba izquierda
                  Positioned(
                    top: 10,
                    left: 40,
                    child: _buildLeaf(size: 50, angle: -0.5),
                  ),

                  // Hojas decorativas arriba derecha
                  Positioned(
                    top: 20,
                    right: 35,
                    child: _buildLeaf(size: 40, angle: 0.4),
                  ),

                  // Hojas pequeñas abajo
                  Positioned(
                    bottom: 60,
                    left: 55,
                    child: _buildLeaf(size: 30, angle: 0.8),
                  ),

                  // Ícono principal: cubo de reciclaje
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Cubo (simulado con ícono grande)
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D7A25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Símbolo de reciclaje debajo del cubo
                      const Icon(
                        Icons.recycling,
                        size: 36,
                        color: Color(0xFF7BC043),
                      ),
                    ],
                  ),

                ],
              ),
            ),

            // ── PARTE INFERIOR: textos y botones ────────────
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
                decoration: const BoxDecoration(
                  // Panel inferior ligeramente más oscuro
                  color: Color(0xFF162D0A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                  child: const Text('Comenzar'),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    // Título
                    const Text(
                      '¡Hola!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtítulo
                    const Text(
                      'Bienvenido reciclador',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'recicla y gana.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 14,
                      ),
                    ),

                    const Spacer(),

                    // ── BOTÓN COMENZAR ──────────────────────
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7BC043),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Comenzar',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── BOTÓN INICIAR SESIÓN ────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  // ── Hoja decorativa ──────────────────────────────────────
  // Usamos un Transform.rotate para darle ángulo a cada hoja
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