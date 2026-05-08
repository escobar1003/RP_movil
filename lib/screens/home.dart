// lib/screens/home.dart

import 'package:flutter/material.dart';
import 'aliados_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F0), // ← fondo gris verdoso suave
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── 1. HEADER ────────────────────────────────
              _buildHeader(),

              const SizedBox(height: 20),

              // ── 2. TARJETA DE PUNTOS ─────────────────────
              _buildPointsCard(),

              const SizedBox(height: 20),

              // ── 3. RESUMEN DE IMPACTO ────────────────────
              _buildImpactSummary(),

              const SizedBox(height: 20),

              // ── 4. TU PROGRESO ───────────────────────────
              _buildProgress(),

              const SizedBox(height: 20),

              // ── 5. ACCIONES RÁPIDAS ──────────────────────
              _buildSectionTitle('Acciones rápidas'),
              const SizedBox(height: 12),
              _buildQuickActions(context),

              const SizedBox(height: 32),

            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // HEADER: saludo + avatar
  // ────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        // Saludo
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hola, Ana 👋',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A1B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Reciclador comprometido',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),

        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF7BC043),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF2D5A1B),
              width: 2,
            ),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 28),
        ),

      ],
    );
  }

  // ────────────────────────────────────────────────────────
  // TARJETA DE PUNTOS
  // ────────────────────────────────────────────────────────
  Widget _buildPointsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2D5A1B), // verde oscuro
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Etiqueta superior
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Tus puntos EcoRecicla',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),

          const SizedBox(height: 16),

          // Puntos grandes
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '2,560',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
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
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Divider
          Divider(color: Colors.white.withOpacity(0.2), height: 1),

          const SizedBox(height: 16),

          // Resumen inferior de la tarjeta
          Row(
            children: [
              _buildCardStat('8.4 kg', 'Reciclados'),
              const SizedBox(width: 24),
              _buildCardStat('2,560', 'Puntos ganados'),
            ],
          ),

        ],
      ),
    );
  }

  // Estadística pequeña dentro de la tarjeta
  Widget _buildCardStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────
  // RESUMEN DE IMPACTO (2 tarjetas lado a lado)
  // ────────────────────────────────────────────────────────
  Widget _buildImpactSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _buildSectionTitle('Resumen de impacto'),
        const SizedBox(height: 12),

        Row(
          children: [

            // Tarjeta kg reciclados
            Expanded(
              child: _buildImpactCard(
                icon: Icons.scale_outlined,
                iconColor: const Color(0xFF7BC043),
                value: '8.4 kg',
                label: 'Reciclados',
              ),
            ),

            const SizedBox(width: 12),

            // Tarjeta entregas
            Expanded(
              child: _buildImpactCard(
                icon: Icons.local_shipping_outlined,
                iconColor: const Color(0xFF2D5A1B),
                value: '23',
                label: 'Entregas',
              ),
            ),

          ],
        ),
      ],
    );
  }

  // Tarjeta individual de impacto
  Widget _buildImpactCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Sombra suave
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [

          // Ícono con fondo circular
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
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
                  color: Color(0xFF2D5A1B),
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),

        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // TU PROGRESO (barra de nivel)
  // ────────────────────────────────────────────────────────
  Widget _buildProgress() {
    // 90% de progreso hacia el siguiente nivel
    const double progress = 0.9;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Título de la sección + nivel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tu progreso',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5A1B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Nivel Verde',
                  style: TextStyle(
                    color: Color(0xFF3B6D11),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFEAF3DE),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF7BC043),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Texto de progreso
          Text(
            'Te faltan 500 puntos para el siguiente nivel',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),

        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // ACCIONES RÁPIDAS
  // ────────────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [

        // Botón: Ver aliados
        Expanded(
          child: _buildActionButton(
            icon: Icons.store_outlined,
            label: 'Ver aliados',
            color: const Color(0xFF2D5A1B),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AliadosScreen()),
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        // Botón: Mis puntos
        Expanded(
          child: _buildActionButton(
            icon: Icons.stars_outlined,
            label: 'Mis puntos',
            color: const Color(0xFF7BC043),
            onTap: () {
              // TODO: navegar a historial de puntos
            },
          ),
        ),

        const SizedBox(width: 12),

        // Botón: Reciclar
        Expanded(
          child: _buildActionButton(
            icon: Icons.recycling,
            label: 'Reciclar',
            color: const Color(0xFF4A90A4),
            onTap: () {
              // TODO: navegar a selección de materiales
            },
          ),
        ),

      ],
    );
  }

  // Botón de acción rápida individual
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // TÍTULO DE SECCIÓN reutilizable
  // ────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D5A1B),
      ),
    );
  }
}