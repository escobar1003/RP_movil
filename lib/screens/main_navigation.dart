// lib/screens/main_navigation.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home.dart';
import 'reciclar_screen.dart';
import 'recompensas_screen.dart';
import 'perfil_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Solo 4 tabs reales (sin el "+" del centro)
  final List<Widget> _screens = const [
    HomeScreen(),
    RecompensasScreen(), // antes era index 2, ahora index 1
    RecompensasScreen(), // placeholder — reemplaza por Retos si tienes esa screen
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // ── FAB central ──────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReciclarScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── Bottom nav ───────────────────────────────────────────────
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        height: 70,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Inicio',
                  index: 0,
                  current: _currentIndex,
                  onTap: _setTab,
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Registros',
                  index: 1,
                  current: _currentIndex,
                  onTap: _setTab,
                ),
                // Espacio vacío para el FAB
                const SizedBox(width: 56),
                _NavItem(
                  icon: Icons.emoji_events_outlined,
                  label: 'Retos',
                  index: 2,
                  current: _currentIndex,
                  onTap: _setTab,
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                  index: 3,
                  current: _currentIndex,
                  onTap: _setTab,
                ),
              ],
        ),
      ),
    );
  }

  void _setTab(int i) => setState(() => _currentIndex = i);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active ? AppColors.primary : AppColors.textLight,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: active ? AppColors.primary : AppColors.textLight,
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}