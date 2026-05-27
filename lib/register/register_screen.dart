// lib/register/register_screen.dart

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../styles/colors.dart';
import '../login/login_screen.dart';
import 'register_style.dart';

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

  bool _obscure = true;

  Future<void> _register() async {

    if (_nombre.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _password.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: SemanticColors.errorRed,
        ),
      );
      return;
    }

    if (_password.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener mínimo 10 caracteres'),
          backgroundColor: SemanticColors.errorRed,
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
      );

      if (response['token'] != null) {

        if (!mounted) return;

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
        padding: RegisterStyles.screenPadding,

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const SizedBox(height: RegisterStyles.gapTitle),

            const Text(
              'Únete a EcoRecicla 🌱',
              style: RegisterStyles.title,
            ),

            const SizedBox(height: RegisterStyles.gapTitleSubtitle),

            const Text(
              'Crea tu cuenta y empieza a reciclar',
              style: RegisterStyles.subtitle,
            ),

            const SizedBox(height: RegisterStyles.gapBeforeField),

            _label('Nombre completo'),

            const SizedBox(height: RegisterStyles.gapLabelField),

            _field(
              controller: _nombre,
              hint: 'Ana Martínez',
              icon: Icons.person_outline,
            ),

            const SizedBox(height: RegisterStyles.gapBetweenFields),

            _label('Correo electrónico'),

            const SizedBox(height: RegisterStyles.gapLabelField),

            _field(
              controller: _email,
              hint: 'tu@correo.com',
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: RegisterStyles.gapBetweenFields),

            _label('Contraseña'),

            const SizedBox(height: RegisterStyles.gapLabelField),

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
                  size: RegisterStyles.iconSize,
                ),

                onPressed: () {

                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              ),
            ),

            const SizedBox(height: RegisterStyles.gapBeforeButton),

            SizedBox(
              width: double.infinity,
              height: RegisterStyles.buttonHeight,

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

  Widget _label(String text) {

    return Text(
      text,
      style: RegisterStyles.label,
    );
  }

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

        hintStyle: RegisterStyles.hint,

        prefixIcon: Icon(
          icon,
          color: AppColors.textLight,
          size: RegisterStyles.iconSize,
        ),

        suffixIcon: suffix,

        filled: true,
        fillColor: Colors.white,

        contentPadding:
            RegisterStyles.fieldPadding,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(RegisterStyles.fieldRadius),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
