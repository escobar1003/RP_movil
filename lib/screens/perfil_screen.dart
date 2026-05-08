// lib/screens/perfil_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header con foto y nombre ──────────────────
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: AppColors.green100,
                        child: const Icon(Icons.person, size: 46, color: AppColors.primary),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.edit, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Ana Martínez',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.green100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Nivel Verde',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Stats ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _StatCard(valor: '45.8 kg', label: 'Total reciclado', icon: Icons.eco)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(valor: '23', label: 'Total entregas', icon: Icons.local_shipping_outlined)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Progreso ──────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tu progreso',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  _ProgresoFila(label: 'Nivel Verde', porcentaje: 0.9),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Menú opciones ─────────────────────────────
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _MenuItem(icon: Icons.info_outline,        label: 'Mi información'),
                  _MenuItem(icon: Icons.emoji_events_outlined, label: 'Mis logros'),
                  _MenuItem(icon: Icons.history,             label: 'Historial'),
                  _MenuItem(icon: Icons.settings_outlined,   label: 'Ajustes y soporte'),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String valor, label;
  final IconData icon;
  const _StatCard({required this.valor, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 8),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textDark)),
          Text(label, style: const TextStyle(color: AppColors.textMid, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ProgresoFila extends StatelessWidget {
  final String label;
  final double porcentaje;
  const _ProgresoFila({required this.label, required this.porcentaje});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark)),
            Text('${(porcentaje * 100).toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: porcentaje,
            backgroundColor: AppColors.green100,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MenuItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: AppColors.green100, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
      onTap: () {},
    );
  }
}