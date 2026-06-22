// lib/screens/login_screen.dart

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'main_navigation.dart';
import 'recuperar_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _obscure = true;

  Future<void> _login() async {

    try {

      final response = await AuthService.login(
        correo: _email.text,
        password: _password.text,
      );

      // LOGIN EXITOSO
      if (response['token'] != null) {
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigation(),
          ),
          (_) => false,
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['mensaje'] ??
              'Error al iniciar sesión',
            ),
          ),
        );
      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

            const Text(
              'Bienvenido de nuevo ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Inicia sesión para continuar',
              style: TextStyle(
                color: AppColors.textMid,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 36),

            // EMAIL
            _label('Correo electrónico'),

            const SizedBox(height: 6),

            _field(
              controller: _email,
              hint: 'tu@correo.com',
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: 18),

            // PASSWORD
            _label('Contraseña'),

            const SizedBox(height: 6),

            _field(
              controller: _password,
              hint: '••••••••',
              icon: Icons.lock_outline,
              obscure: _obscure,

              suffix: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off
                      : Icons.visibility,

                  color: AppColors.textLight,
                  size: 20,
                ),

                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              ),
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecuperarPasswordScreen()),
                ),
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed: _login,
                child: const Text('Entrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LABEL
  Widget _label(String text) {

    return Text(
      text,

      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: AppColors.textMid,
      ),
    );
  }

  // INPUT
  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {

    return TextField(
      controller: controller,
      obscureText: obscure,

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: const TextStyle(
          color: AppColors.textLight,
        ),

        prefixIcon: Icon(
          icon,
          color: AppColors.textLight,
          size: 20,
        ),

        suffixIcon: suffix,

        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}