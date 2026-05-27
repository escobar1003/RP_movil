// lib/recompensas/recompensas_screen.dart

import 'package:flutter/material.dart';
import '../data/puntos_reciclaje_data.dart';
import '../styles/colors.dart';
import 'recompensas_style.dart';

class RecompensasScreen extends StatelessWidget {
  const RecompensasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecompensasStyles.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                padding: RecompensasStyles.listPadding,
                itemCount: puntosReciclaje.length,
                itemBuilder: (context, index) =>
                    _buildCard(context, puntosReciclaje[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: RecompensasStyles.headerPadding,
      decoration: const BoxDecoration(
        color: GreenColors.dark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(RecompensasStyles.headerRadius),
          bottomRight: Radius.circular(RecompensasStyles.headerRadius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recompensas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Puntos de reciclaje cercanos',
            style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13),
          ),
          const SizedBox(height: 20),
          Container(
            padding: RecompensasStyles.bannerPadding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(RecompensasStyles.bannerRadius),
            ),
            child: Row(
              children: [
                Container(
                  width: RecompensasStyles.bannerIconSize,
                  height: RecompensasStyles.bannerIconSize,
                  decoration: BoxDecoration(
                    color: GreenColors.light,
                    borderRadius: BorderRadius.circular(RecompensasStyles.bannerIconRadius),
                  ),
                  child: const Icon(Icons.stars_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tus puntos disponibles',
                      style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12),
                    ),
                    const Text(
                      '2,560 pts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> punto) {
    return Container(
      margin: RecompensasStyles.cardMargin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RecompensasStyles.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: RecompensasStyles.cardPadding,
        child: Row(
          children: [
            Container(
              width: RecompensasStyles.storeIconSize,
              height: RecompensasStyles.storeIconSize,
              decoration: BoxDecoration(
                color: AppColors.green100,
                borderRadius: BorderRadius.circular(RecompensasStyles.storeIconRadius),
              ),
              child: const Icon(Icons.store_rounded,
                  color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    punto['nombre'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: GreenColors.veryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: AppColors.textLight),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          punto['direccion'],
                          style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: RecompensasStyles.badgePadding,
                    decoration: BoxDecoration(
                      color: GreenColors.lightBg,
                      borderRadius: BorderRadius.circular(RecompensasStyles.badgeRadius),
                    ),
                    child: Text(
                      punto['materiales'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: GreenColors.medium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
