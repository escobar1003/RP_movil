import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_navigation.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EcoReciclaApp());
}

class EcoReciclaApp extends StatelessWidget {
  const EcoReciclaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoRecicla',
      theme: AppTheme.theme,
      home: const _InicioApp(),
    );
  }
}

class _InicioApp extends StatefulWidget {
  const _InicioApp();

  @override
  State<_InicioApp> createState() => _InicioAppState();
}

class _InicioAppState extends State<_InicioApp> {
  late Future<bool> _verificarSesion;

  @override
  void initState() {
    super.initState();
    _verificarSesion = _tieneSesion();
  }

  Future<bool> _tieneSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _verificarSesion,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/imagen_de_fondo.png',
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(color: AppColors.primary),
                ],
              ),
            ),
          );
        }
        if (snapshot.data == true) {
          return const MainNavigation();
        }
        return const WelcomeScreen();
      },
    );
  }
}
