// lib/home/home.dart

import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../styles/colors.dart';
import '../styles/gradients.dart';
import '../services/auth_service.dart';
import '../mapa_puntos/mapa_puntos_screen.dart';
import '../reciclar/reciclar_screen.dart';
import '../mis_canjes/mis_canjes_screen.dart';
import '../games/recycling_game_screen.dart';
import 'home_style.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String _nombre = '';

  @override
  void initState() {
    super.initState();
    _cargarNombre();
  }

  Future<void> _cargarNombre() async {
    final nombre = await AuthService.getNombre();
    setState(() => _nombre = nombre);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SemanticColors.altBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: HomeStyles.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  const CircleAvatar(
                    radius: HomeStyles.avatarRadius,
                    backgroundColor: AppColors.green100,
                    child: Icon(
                      BootstrapIcons.person_fill,
                      color: AppColors.primary,
                      size: HomeStyles.avatarIconSize,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nombre.isEmpty ? 'Hola ' : 'Hola, $_nombre ',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '¡Gracias por cuidar el planeta!',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: HomeStyles.notifPadding,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(HomeStyles.notifRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      BootstrapIcons.gear,
                      size: 20,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: HomeStyles.puntosCardPadding,
                decoration: BoxDecoration(
                  gradient: AppGradients.pointsCard,
                  borderRadius: BorderRadius.circular(HomeStyles.puntosCardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Puntos disponibles',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text(
                                '2,560',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  BootstrapIcons.coin,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Sigue así, cada acción suma un cambio.',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const Icon(BootstrapIcons.recycle, color: Colors.white, size: 70),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Resumen de impacto',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: HomeStyles.impactoCardPadding,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(HomeStyles.impactoCardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _ImpactoItem(
                            icon: BootstrapIcons.recycle,
                            value: '12.5 kg',
                            label: 'Plástico reciclado',
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _ImpactoItem(
                            icon: BootstrapIcons.truck,
                            value: '8',
                            label: 'Reciclajes',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _ImpactoItem(
                            icon: BootstrapIcons.leaf,
                            value: '8.4 kg',
                            label: 'CO₂ evitado',
                            color: Colors.lightGreen,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _ImpactoItem(
                            icon: BootstrapIcons.star_fill,
                            value: '2,560',
                            label: 'Puntos totales',
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Tu progreso',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: HomeStyles.progresoCardPadding,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(HomeStyles.progresoCardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Nivel: Verde',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        Text(
                          '80%',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 0.8,
                        minHeight: 10,
                        backgroundColor: AppColors.green100,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '¡Genial! Aún puedes ganar más puntos y subir de nivel.',
                      style: TextStyle(color: AppColors.textMid, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Acciones rápidas',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _AccionCard(
                      icon: BootstrapIcons.qr_code_scan,
                      label: 'Clasificar',
                      color: AppColors.green100,
                      iconColor: AppColors.primary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReciclarScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AccionCard(
                      icon: BootstrapIcons.gift,
                      label: 'Canjear',
                      color: AppColors.yellow100,
                      iconColor: Colors.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MisCanjesScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AccionCard(
                      icon: BootstrapIcons.geo_alt,
                      label: 'Mapa',
                      color: MaterialBgColors.blue,
                      iconColor: Colors.blue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MapaPuntosScreen(soloMapa: true),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Mini juego',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecyclingGameScreen(),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: HomeStyles.gameCardPadding,
                  decoration: BoxDecoration(
                    gradient: AppGradients.gameCard,
                    borderRadius: BorderRadius.circular(HomeStyles.gameCardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: HomeStyles.gameIconPadding,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(HomeStyles.gameIconRadius),
                        ),
                        child: const Icon(
                          Icons.sports_esports,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 18),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Recicla jugando!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Atrapa los residuos en el bote correcto.\nGana puntos y salva el planeta.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white54,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImpactoItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ImpactoItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: HomeStyles.impactoItemPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HomeStyles.impactoItemRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(HomeStyles.impactoIconContainer),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(HomeStyles.impactoIconContainerRadius),
            ),
            child: Icon(icon, color: color, size: HomeStyles.impactoIconSize),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMid),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback? onTap;

  const _AccionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: HomeStyles.accionCardPadding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(HomeStyles.accionCardRadius),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
