// lib/screens/mis_canjes_screen.dart  (pantalla "Mis tarjetas")

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MisCanjesScreen extends StatefulWidget {
  const MisCanjesScreen({super.key});

  @override
  State<MisCanjesScreen> createState() => _MisCanjesScreenState();
}

class _MisCanjesScreenState extends State<MisCanjesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  final _canjes = [
    {
      'titulo': '10% de descuento',
      'comercio': 'SuperNorms',
      'monto': 'Descuento en toda la tienda',
      'fecha': '14 may. 2024 · 9:00 am',
      'puntos': '+350 puntos',
      'estado': 'Activo',
      'codigo': 'LUMA-LYFT',
    },
    {
      'titulo': 'Bono \$50,000',
      'comercio': 'SuperNorms',
      'monto': 'Descuento en compras mayores a \$100,000',
      'fecha': '20 oct. 2024 · 4:35 pm',
      'puntos': '+600 puntos',
      'estado': 'Usado',
      'codigo': 'XKOP-7845',
    },
    {
      'titulo': 'Protección gratis',
      'comercio': 'SuperNorms',
      'monto': 'Plan gratuito por 1 mes',
      'fecha': 'Orden 512 · 30 dic.',
      'puntos': '+300 puntos',
      'estado': 'Activo',
      'codigo': 'PLAN-FREE',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis tarjetas'),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Activos'),
            Tab(text: 'Usados'),
            Tab(text: 'Expirados'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _ListaCanjes(canjes: _canjes.where((c) => c['estado'] == 'Activo').toList()),
          _ListaCanjes(canjes: _canjes.where((c) => c['estado'] == 'Usado').toList()),
          const Center(child: Text('Sin canjes expirados', style: TextStyle(color: AppColors.textLight))),
        ],
      ),
    );
  }
}

class _ListaCanjes extends StatelessWidget {
  final List<Map<String, dynamic>> canjes;
  const _ListaCanjes({required this.canjes});

  @override
  Widget build(BuildContext context) {
    if (canjes.isEmpty) {
      return const Center(child: Text('Sin canjes', style: TextStyle(color: AppColors.textLight)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: canjes.length,
      itemBuilder: (_, i) => _CanjeCard(data: canjes[i]),
    );
  }
}

class _CanjeCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _CanjeCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final activo = data['estado'] == 'Activo';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.green100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_offer, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['titulo']!,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
                      Text(data['comercio']!,
                          style: const TextStyle(color: AppColors.textMid, fontSize: 12)),
                      Text(data['fecha']!,
                          style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: activo ? AppColors.green100 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    data['estado']!,
                    style: TextStyle(
                      color: activo ? AppColors.primary : Colors.grey,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (activo)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.green100,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Text(
                'Código: ${data['codigo']}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}