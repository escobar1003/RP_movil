// lib/main_navigation/main_navigation.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/colors.dart';
import '../home/home.dart';
import '../reciclar/reciclar_screen.dart';
import '../recompensas/recompensas_screen.dart';
import '../perfil/perfil_screen.dart';
import '../historial_entregas/historial_entregas_screen.dart';
import 'main_navigation_style.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _cargado = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    HistorialEntregasScreen(),
    RecompensasScreen(),
    PerfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _cargarTab();
  }

  Future<void> _cargarTab() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('tab_index') ?? 0;
    if (mounted) setState(() { _currentIndex = saved; _cargado = true; });
  }

  Future<void> _guardarTab(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tab_index', index);
  }

  @override
  Widget build(BuildContext context) {
    if (!_cargado) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: NavStyles.fabElevation,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReciclarScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: NavStyles.fabIconSize),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: NavStyles.bottomAppBarElevation,
        height: NavStyles.bottomAppBarHeight,
        notchMargin: NavStyles.notchMargin,
        shape: const CircularNotchedRectangle(),
          child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Inicio',
                      index: 0,
                      current: _currentIndex,
                      onTap: _setTab,
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.receipt_long_outlined,
                      label: 'Registros',
                      index: 1,
                      current: _currentIndex,
                      onTap: _setTab,
                    ),
                  ),
                  const SizedBox(width: NavStyles.notchMargin * 7),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.emoji_events_outlined,
                      label: 'Recompensas',
                      index: 2,
                      current: _currentIndex,
                      onTap: _setTab,
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.person_rounded,
                      label: 'Perfil',
                      index: 3,
                      current: _currentIndex,
                      onTap: _setTab,
                    ),
                  ),
                ],
          ),
      ),
    );
  }

  void _setTab(int i) {
    _guardarTab(i);
    setState(() => _currentIndex = i);
  }
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: NavStyles.navItemPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: NavStyles.navColor(active),
                size: NavStyles.navIconSize,
              ),
              const SizedBox(height: NavStyles.navIconLabelGap),
              Text(
                label,
                style: TextStyle(
                  color: NavStyles.navColor(active),
                  fontSize: NavStyles.navLabelFontSize,
                  fontWeight: NavStyles.navWeight(active),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
