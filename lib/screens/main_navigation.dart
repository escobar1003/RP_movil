// lib/screens/main_navigation.dart

import 'package:flutter/material.dart';

// ── Importamos todas las pantallas principales ──────────
import 'home.dart';
import 'reciclar_screen.dart';
import 'recompensas_screen.dart';
import 'perfil_screen.dart';

// ── StatefulWidget porque el índice del tab CAMBIA ──────
// Un StatelessWidget no puede "recordar" en qué tab estás
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {

  // ── Esta variable guarda en qué tab estamos (0, 1, 2 o 3)
  int _currentIndex = 0;

  // ── Lista de pantallas en el mismo orden que los tabs ──
  // Índice 0 → Inicio, 1 → Reciclar, 2 → Recompensas, 3 → Perfil
  final List<Widget> _screens = const [
    HomeScreen(),
    ReciclarScreen(),
    RecompensasScreen(),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ── Muestra la pantalla que corresponde al tab activo
      body: _screens[_currentIndex],

      // ── La barra de navegación inferior ────────────────
      bottomNavigationBar: BottomNavigationBar(

        currentIndex: _currentIndex, // ← cuál tab está activo

        // ── Se ejecuta cuando el usuario toca un tab ─────
        onTap: (index) {
          setState(() {
            // setState le dice a Flutter: "algo cambió, redibuja"
            _currentIndex = index;
          });
        },

        // ── Color del ícono y texto del tab ACTIVO ────────
        selectedItemColor: Colors.green,

        // ── Color de los tabs INACTIVOS ───────────────────
        unselectedItemColor: Colors.grey,

        // ── Siempre mostrar texto debajo del ícono ────────
        type: BottomNavigationBarType.fixed,

        // ── Los 4 tabs ───────────────────────────────────
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recycling),
            label: 'Reciclar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Recompensas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}