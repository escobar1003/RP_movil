// lib/screens/home.dart

import 'package:flutter/material.dart';
import 'aliados_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6EF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildHeader(),
              const SizedBox(height: 20),
              _buildPointsCard(),
              const SizedBox(height: 16),
              _buildImpactRow(),
              const SizedBox(height: 16),
              _buildProgressCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('Acciones rápidas'),
              const SizedBox(height: 12),
              _buildQuickActions(context),
              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hola, Ana 👋',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A0F),
              ),
            ),
            const SizedBox(height: 4),
            // Badge "Reciclador comprometido"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3DE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Reciclador comprometido',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF3B6D11),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        // Avatar con foto (usamos ícono por ahora)
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF7BC043),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFF3B6D11), width: 2),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 30),
        ),

      ],
    );
  }

  // ── TARJETA DE PUNTOS ────────────────────────────────────
  Widget _buildPointsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF2D5A1B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [

          // Hoja decorativa fondo
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.eco,
              size: 100,
              color: Colors.white.withOpacity(0.06),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Label superior
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Tus puntos EcoRecicla',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),

              const SizedBox(height: 14),

              // Número grande de puntos
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '2,560',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'pts',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 20,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.green100,
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Divider(color: Colors.white.withOpacity(0.15), height: 1),
              const SizedBox(height: 16),

              // Stats inferiores dentro de la tarjeta
              Row(
                children: [
                  _buildCardStat(
                    icon: Icons.scale_outlined,
                    value: '8.4 kg',
                    label: 'Reciclados',
                  ),
                  const SizedBox(width: 28),
                  _buildCardStat(
                    icon: Icons.stars_outlined,
                    value: '2,560',
                    label: 'Puntos ganados',
                  ),
                ],
              ),

            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7BC043), size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── RESUMEN DE IMPACTO (fila de 2 tarjetas) ─────────────
  Widget _buildImpactRow() {
    return Row(
      children: [
        Expanded(
          child: _buildImpactCard(
            icon: Icons.scale_outlined,
            iconBg: const Color(0xFFEAF3DE),
            iconColor: const Color(0xFF3B6D11),
            value: '45.8 kg',
            label: 'Total reciclado',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildImpactCard(
            icon: Icons.local_shipping_outlined,
            iconBg: const Color(0xFFE6F1FB),
            iconColor: const Color(0xFF185FA5),
            value: '23',
            label: 'Entregas',
          ),
        ),
      ],
    );
  }

  Widget _buildImpactCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A0F),
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── PROGRESO ─────────────────────────────────────────────
  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tu progreso',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A0F),
                ),
              ),
              // Badge nivel
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.eco, size: 13, color: Color(0xFF3B6D11)),
                    const SizedBox(width: 4),
                    const Text(
                      'Flor Verde',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF3B6D11),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.9,
              minHeight: 9,
              backgroundColor: const Color(0xFFEAF3DE),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF7BC043),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Te faltan 500 puntos para el siguiente nivel',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),

        ],
      ),
    );
  }

  // ── ACCIONES RÁPIDAS ────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.store_outlined,
        'label': 'Ver aliados',
        'color': const Color(0xFF2D5A1B),
        'bg': const Color(0xFFEAF3DE),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AliadosScreen()),
            ),
      },
      {
        'icon': Icons.recycling,
        'label': 'Reciclar',
        'color': const Color(0xFF185FA5),
        'bg': const Color(0xFFE6F1FB),
        'onTap': () {},
      },
      {
        'icon': Icons.card_giftcard_outlined,
        'label': 'Recompensas',
        'color': const Color(0xFF854F0B),
        'bg': const Color(0xFFFAEEDA),
        'onTap': () {},
      },
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: a['onTap'] as VoidCallback,
            child: Container(
              margin: actions.indexOf(a) < actions.length - 1
                  ? const EdgeInsets.only(right: 10)
                  : EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: a['bg'] as Color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(a['icon'] as IconData,
                      color: a['color'] as Color, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    a['label'] as String,
                    style: TextStyle(
                      color: a['color'] as Color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E3A0F),
      ),
    );
  }
}