import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/gradients.dart';
import '../login/login_screen.dart';
import '../register/register_screen.dart';
import 'welcome_style.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [

          Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.welcomeBg,
            ),
          ),

          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: WelcomeStyles.circleTopRight,
              height: WelcomeStyles.circleTopRight,
              decoration: BoxDecoration(
                color: GreenColors.gradientB.withOpacity(WelcomeStyles.circleTopRightOpacity),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            top: 60,
            left: -50,
            child: Container(
              width: WelcomeStyles.circleTopLeft,
              height: WelcomeStyles.circleTopLeft,
              decoration: BoxDecoration(
                color: GreenColors.gradientA.withOpacity(WelcomeStyles.circleTopLeftOpacity),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -60,
            left: -40,
            child: Container(
              width: WelcomeStyles.circleBottomLeft,
              height: WelcomeStyles.circleBottomLeft,
              decoration: BoxDecoration(
                color: GreenColors.gradientA.withOpacity(WelcomeStyles.circleBottomLeftOpacity),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: WelcomeStyles.screenPadding,
              child: Column(
                children: [

                  const Spacer(),

                  SizedBox(
                    height: size.height * WelcomeStyles.imageRatio,
                    child: Image.asset(
                      'assets/images/imagen_de_fondo.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: WelcomeStyles.gapImageText),

                  Text(
                    '¡Hola! 👋\nBienvenido reciclador',
                    textAlign: TextAlign.center,
                    style: WelcomeStyles.title,
                  ),

                  const SizedBox(height: WelcomeStyles.gapTitleSubtitle),

                  Text(
                    'Cada acción cuenta para\nun planeta más limpio.',
                    textAlign: TextAlign.center,
                    style: WelcomeStyles.subtitle,
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: WelcomeStyles.buttonHeight,
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

                  const SizedBox(height: WelcomeStyles.gapButtonLink),

                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    ),
                    child: Text(
                      'Iniciar sesión',
                      style: WelcomeStyles.link,
                    ),
                  ),

                  const SizedBox(height: WelcomeStyles.gapBottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
