import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:recycling_points/screens/reservas.dart';

import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/usuario_service.dart';

import 'mapa_puntos_screen.dart';
import 'reciclar_screen.dart';
import 'mis_canjes_screen.dart';
import 'configuracion_screen.dart';
import 'notificaciones_screen.dart';
import '../games/recycling_game_screen.dart';
import 'reservas.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _nombre = '';
  int _puntos = 0;
  int _reciclajes = 0;
  double _pesoTotal = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    _nombre = await AuthService.getNombre();

    try {
      final perfil = await UsuarioService.getPerfil();
      if (perfil['nombre'] != null) _nombre = perfil['nombre'];
    } catch (_) {}

    try {
      final puntos = await UsuarioService.getResumenPuntos();
      _puntos = puntos['saldo'] ?? 0;
    } catch (_) {}

    try {
      final entregas = await UsuarioService.getEntregas();
      final lista = entregas['entregas'] as List? ?? [];
      _reciclajes = lista.length;
      _pesoTotal = lista.fold(0.0, (sum, e) => sum + (e['pesoTotal'] ?? e['peso_total'] ?? 0).toDouble());
    } catch (_) {}

    if (mounted) setState(() {});
  }

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

              // ------------------ HEADER ------------------
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.green100,
                    child: Icon(
                      BootstrapIcons.person_fill,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nombre.isEmpty ? 'Hola' : 'Hola, $_nombre',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '¡Gracias por cuidar el planeta!',
                          style: TextStyle(fontSize: 13, color: AppColors.textMid),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificacionesScreen()));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: const Icon(BootstrapIcons.bell, size: 20, color: AppColors.textDark),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfiguracionScreen()));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: const Icon(BootstrapIcons.gear, size: 20, color: AppColors.textDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ------------------ CARD PUNTOS ------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E9E6F), Color(0xFF57C58A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 8))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Puntos disponibles', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(_puntos.toString(), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(50)),
                                child: const Icon(BootstrapIcons.coin, color: Colors.white, size: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text('Sigue así, cada acción suma un cambio.', style: TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                    const Icon(BootstrapIcons.recycle, color: Colors.white, size: 70),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ------------------ RESUMEN IMPACTO ------------------
              const Text('Resumen de impacto', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textDark)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _ImpactoItem(icon: BootstrapIcons.recycle, value: '${_pesoTotal.toStringAsFixed(1)} kg', label: 'Peso total reciclado', color: AppColors.primary)),
                        const SizedBox(width: 14),
                        Expanded(child: _ImpactoItem(icon: BootstrapIcons.truck, value: '$_reciclajes', label: 'Reciclajes', color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _ImpactoItem(icon: BootstrapIcons.leaf, value: '${(_pesoTotal * 1.5).toStringAsFixed(1)} kg', label: 'CO₂ evitado', color: Colors.lightGreen)),
                        const SizedBox(width: 14),
                        Expanded(child: _ImpactoItem(icon: BootstrapIcons.star_fill, value: '$_puntos', label: 'Puntos totales', color: Colors.amber)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ------------------ PROGRESO ------------------
              const Text('Tu progreso', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textDark)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Nivel: Verde', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        Text('$_puntos pts', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_puntos / 3000).clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: AppColors.green100,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('¡Genial! Aún puedes ganar más puntos y subir de nivel.', style: TextStyle(color: AppColors.textMid, fontSize: 13)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ------------------ ACCIONES RAPIDAS ------------------
              const Text('Acciones rápidas', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textDark)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _AccionCard(icon: BootstrapIcons.qr_code_scan, label: 'Clasificar', color: AppColors.green100, iconColor: AppColors.primary, onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const ReciclarScreen())); })),
                  const SizedBox(width: 12),
                  Expanded(child: _AccionCard(icon: BootstrapIcons.gift, label: 'Canjear', color: AppColors.yellow100, iconColor: Colors.orange, onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const MisCanjesScreen())); })),
                  const SizedBox(width: 12),
                  Expanded(child: _AccionCard(icon: BootstrapIcons.geo_alt, label: 'Mapa', color: const Color(0xFFE3F2FD), iconColor: Colors.blue, onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const MapaPuntosScreen(soloMapa: true))); })),
                ],
              ),

              const SizedBox(height: 24),

              // ------------------------- JUEGO -------------------------
              const Text('Mini juego', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textDark)),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecyclingGameScreen())),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF43A047), Color(0xFF66BB6A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.sports_esports, color: Colors.white, size: 36),
                      ),
                      const SizedBox(width: 18),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('¡Recicla jugando!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                            SizedBox(height: 4),
                            Text('Atrapa los residuos en el bote correcto.\nGana puntos y salva el planeta.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🧪 BOTÓN TEMPORAL DE PRUEBA — borrar después
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReservasScreen(
                          aliado: {
                            'idPunto': 1,
                            'nombre': 'Punto de prueba',
                            'direccion': 'Dirección de prueba',
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('🧪 Probar reserva'),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

// ------------------ IMPACTO ITEM ------------------
class _ImpactoItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ImpactoItem({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMid)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------ ACCION CARD ------------------
class _AccionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback? onTap;

  const _AccionCard({required this.icon, required this.label, required this.color, required this.iconColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: iconColor, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}