// lib/screens/recompensas_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RecompensasScreen extends StatefulWidget {
  const RecompensasScreen({super.key});

  @override
  State<RecompensasScreen> createState() => _RecompensasScreenState();
}

class _RecompensasScreenState extends State<RecompensasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  final _recompensas = [
    {'titulo': '10% de descuento', 'subtitulo': 'SuperNorms', 'descripcion': '10% de descuento en toda la tienda', 'puntos': 100, 'disponibles': 500, 'logo': Icons.store},
    {'titulo': 'Bono \$20,000',     'subtitulo': 'SuperNorms', 'descripcion': 'Descuento en compras mayores a \$50,000', 'puntos': 200, 'disponibles': 300, 'logo': Icons.local_offer},
    {'titulo': 'Bono \$50,000',     'subtitulo': 'SuperNorms', 'descripcion': 'Descuento en compras mayores a \$100,000', 'puntos': 400, 'disponibles': 150, 'logo': Icons.card_giftcard},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recompensas'),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Disponibles'),
            Tab(text: 'Canjeados'),
            Tab(text: 'Próximos'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Banner de puntos ───────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.star, color: AppColors.accent, size: 22),
                const SizedBox(width: 8),
                const Text('Tus puntos:', style: TextStyle(color: AppColors.textMid, fontSize: 13)),
                const SizedBox(width: 6),
                const Text('2,560',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18)),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                // Tab 1: Disponibles
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _recompensas.length,
                  itemBuilder: (_, i) => _RecompensaCard(
                    data: _recompensas[i],
                    onCanjear: () => _mostrarDetalle(context, _recompensas[i]),
                  ),
                ),
                // Tab 2 y 3: placeholder
                const Center(child: Text('Sin canjes aún', style: TextStyle(color: AppColors.textLight))),
                const Center(child: Text('Próximamente', style: TextStyle(color: AppColors.textLight))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDetalle(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DetalleBottomSheet(data: data),
    );
  }
}

class _RecompensaCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onCanjear;
  const _RecompensaCard({required this.data, required this.onCanjear});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCanjear,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: AppColors.green100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(data['logo'] as IconData, color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['titulo']!,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
                  Text(data['subtitulo']!,
                      style: const TextStyle(color: AppColors.textMid, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('${data['puntos']} puntos',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
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

class _DetalleBottomSheet extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DetalleBottomSheet({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.green100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(data['logo'] as IconData, color: AppColors.primary, size: 40),
            ),
          ),
          const SizedBox(height: 20),
          Text(data['titulo']!,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(data['subtitulo']!,
              style: const TextStyle(color: AppColors.textMid, fontSize: 14)),
          const SizedBox(height: 12),
          Text(data['descripcion']!,
              style: const TextStyle(color: AppColors.textMid, fontSize: 14, height: 1.5)),
          const SizedBox(height: 8),
          Text('Disponible: ${data['disponibles']} unidades',
              style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Canjear · ${data['puntos']} puntos'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}