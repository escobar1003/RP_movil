// lib/screens/home.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header saludo ──────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Hola, Ana 👋',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        SizedBox(height: 2),
                        Text('Reciclador comprometido',
                            style: TextStyle(fontSize: 13, color: AppColors.textMid)),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.green100,
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Card de puntos ─────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tus puntos', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text('2,560',
                            style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900)),
                        SizedBox(width: 8),
                        Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text('pts', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Resumen de Impacto',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _ImpactoItem(icon: Icons.eco, value: '8.4 kg', label: 'Reciclado'),
                        const SizedBox(width: 24),
                        _ImpactoItem(icon: Icons.star, value: '2,560', label: 'Puntos'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Tu progreso ────────────────────────────────
              const Text('Tu progreso',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _ProgresoFila(label: 'Nivel Verde', porcentaje: 0.9, color: AppColors.primary),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    const Text(
                      'Te faltan 440 puntos para alcanzar el siguiente nivel',
                      style: TextStyle(color: AppColors.textMid, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Acciones rápidas ───────────────────────────
              const Text('Acciones rápidas',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _AccionCard(icon: Icons.qr_code_scanner, label: 'Clasificar', color: AppColors.green100, iconColor: AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: _AccionCard(icon: Icons.card_giftcard, label: 'Canjear', color: AppColors.yellow100, iconColor: Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _AccionCard(icon: Icons.map_outlined, label: 'Mapa', color: const Color(0xFFE3F2FD), iconColor: Colors.blue)),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImpactoItem extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _ImpactoItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 20),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

class _ProgresoFila extends StatelessWidget {
  final String label;
  final double porcentaje;
  final Color color;
  const _ProgresoFila({required this.label, required this.porcentaje, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark)),
                  Text('${(porcentaje * 100).toInt()}%',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: porcentaje,
                  backgroundColor: AppColors.green100,
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, iconColor;
  const _AccionCard({required this.icon, required this.label, required this.color, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: iconColor, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}