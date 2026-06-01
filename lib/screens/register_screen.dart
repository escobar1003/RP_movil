// lib/screens/register_screen.dart

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _telefono = TextEditingController();

  bool _obscure = true;

  Future<void> _register() async {

    if (_nombre.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _password.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Color(0xFFA32D2D),
        ),
      );
      return;
    }

    if (_password.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener mínimo 10 caracteres'),
          backgroundColor: Color(0xFFA32D2D),
        ),
      );
      return;
    }

    try {

      final response =
          await AuthService.register(
        nombre: _nombre.text,
        correo: _email.text,
        password: _password.text,
        telefono: _telefono.text.isNotEmpty ? _telefono.text : null,
      );

      // REGISTER EXITOSO
      if (response['token'] != null) {

        if (!mounted) return;

        // IR AL LOGIN
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const LoginScreen(),
          ),
          (_) => false,
        );

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              response['mensaje'] ??
              'Error al registrarse',
            ),
          ),
        );
      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
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
        title: const Text('Crear cuenta'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 20),

            const Text(
              'Únete a EcoRecicla 🌱',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Crea tu cuenta y empieza a reciclar',
              style: TextStyle(
                color: AppColors.textMid,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 36),

            // NOMBRE
            _label('Nombre completo'),

            const SizedBox(height: 6),

            _field(
              controller: _nombre,
              hint: 'Ana Martínez',
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 18),

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

            const SizedBox(height: 18),

            // TELÉFONO
            _label('Teléfono (opcional)'),

            const SizedBox(height: 6),

            _field(
              controller: _telefono,
              hint: '300 123 4567',
              icon: Icons.phone_outlined,
            ),

            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed: _register,
                child:
                    const Text('Crear cuenta'),
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

        contentPadding:
            const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}