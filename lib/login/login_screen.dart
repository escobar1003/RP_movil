// lib/login/login_screen.dart

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../styles/colors.dart';
import '../main_navigation/main_navigation.dart';
import 'login_style.dart';

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
        padding: LoginStyles.screenPadding,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: LoginStyles.gapTitle),

            const Text(
              'Bienvenido de nuevo 👋',
              style: LoginStyles.title,
            ),

            const SizedBox(height: LoginStyles.gapTitleSubtitle),

            const Text(
              'Inicia sesión para continuar',
              style: LoginStyles.subtitle,
            ),

            const SizedBox(height: LoginStyles.gapBeforeField),

            _label('Correo electrónico'),

            const SizedBox(height: LoginStyles.gapLabelField),

            _field(
              controller: _email,
              hint: 'tu@correo.com',
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: LoginStyles.gapBetweenFields),

            _label('Contraseña'),

            const SizedBox(height: LoginStyles.gapLabelField),

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
                  size: LoginStyles.iconSize,
                ),

                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              ),
            ),

            const SizedBox(height: LoginStyles.gapBeforeButton),

            SizedBox(
              width: double.infinity,
              height: LoginStyles.buttonHeight,

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

  Widget _label(String text) {

    return Text(
      text,
      style: LoginStyles.label,
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

        hintStyle: LoginStyles.hint,

        prefixIcon: Icon(
          icon,
          color: AppColors.textLight,
          size: LoginStyles.iconSize,
        ),

        suffixIcon: suffix,

        filled: true,
        fillColor: Colors.white,

        contentPadding: LoginStyles.fieldPadding,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LoginStyles.fieldRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
