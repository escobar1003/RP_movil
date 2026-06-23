// lib/screens/main_navigation.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/socket_service.dart';
import 'home.dart';
import 'reciclar_screen.dart';
import 'recompensas_screen.dart';
import 'perfil_screen.dart';
import 'historial_entregas_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _cargado = false;
  int _homeRefresh = 0;
  StreamSubscription? _subSocket;

  List<Widget> get _screens => [
    HomeScreen(key: ValueKey('home_$_homeRefresh')),
    const HistorialEntregasScreen(),
    const RecompensasScreen(),
    const PerfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _cargarTab();
    _subSocket = SocketService.instance.stream.listen((event) {
      _mostrarNotificacion(event.key, event.value);
    });
  }

  @override
  void dispose() {
    _subSocket?.cancel();
    super.dispose();
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

  void _mostrarNotificacion(String tipo, Map<String, dynamic> data) {
    if (!mounted) return;

    String icono;
    String titulo;
    String mensaje;
    Color color;

    switch (tipo) {
      case 'reserva_aceptada':
        icono = '✓';
        titulo = data['titulo'] ?? 'Reserva aceptada';
        mensaje = data['mensaje'] ?? 'Tu reserva fue confirmada por el encargado';
        color = const Color(0xFF3B6D11);
        break;
      case 'reserva_rechazada':
        icono = '✕';
        titulo = data['titulo'] ?? 'Reserva rechazada';
        mensaje = data['mensaje'] ?? 'Tu reserva fue rechazada por el encargado';
        color = const Color(0xFFA32D2D);
        break;
      case 'nueva_entrega':
        icono = '♻';
        titulo = 'Entrega registrada';
        final peso = data['pesoTotal'];
        final pts = data['puntosTotales'];
        mensaje = '${peso != null ? "${peso} kg — " : ""}${pts != null ? "$pts puntos" : ""}';
        color = const Color(0xFF3B6D11);
        break;
      case 'puntos_actualizados':
        icono = '★';
        titulo = 'Puntos actualizados';
        mensaje = 'Tienes ${data['puntosTotales'] ?? 0} puntos';
        color = const Color(0xFF854F0B);
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(icono, style: TextStyle(fontSize: 28, color: color)),
              ),
            ),
            const SizedBox(height: 16),
            Text(titulo,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 8),
            Text(mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF5F5E5A))),
            if (data['estado'] != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Estado: ${data['estado']}',
                    style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar',
                style: TextStyle(color: Color(0xFF6B7F66))),
          ),
        ],
      ),
    );
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

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        height: 70,
        notchMargin: 8,
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
                      label: 'Historial',
                      index: 1,
                      current: _currentIndex,
                      onTap: _setTab,
                    ),
                  ),
                  const SizedBox(width: 56),
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
    setState(() {
      _currentIndex = i;
      if (i == 0) _homeRefresh++;
    });
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
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: active ? AppColors.primary : AppColors.textLight,
                size: 18,
              ),
              const SizedBox(height: 1),
              Text(
                label,
                style: TextStyle(
                  color: active ? AppColors.primary : AppColors.textLight,
                  fontSize: 9,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
    );
  }
}
