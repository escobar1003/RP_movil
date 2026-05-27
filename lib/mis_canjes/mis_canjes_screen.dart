// lib/mis_canjes/mis_canjes_screen.dart

import 'package:flutter/material.dart';
import '../styles/colors.dart';
import 'mis_canjes_style.dart';

class MisCanjesScreen extends StatefulWidget {
  const MisCanjesScreen({super.key});

  @override
  State<MisCanjesScreen> createState() => _MisCanjesScreenState();
}

class _MisCanjesScreenState extends State<MisCanjesScreen> {

  String _filtro = 'todos';

  final List<Map<String, dynamic>> _canjes = [
    {
      'tienda': 'SuperNorte',
      'descripcion': '10% de descuento en toda la tienda',
      'descuento': '10%',
      'puntos': 100,
      'fecha': '12 May 2026',
      'estado': 'activo',
      'vence': '31 Dic 2026',
    },
    {
      'tienda': 'Éxito',
      'descripcion': '5% en frutas y verduras',
      'descuento': '5%',
      'puntos': 50,
      'fecha': '05 May 2026',
      'estado': 'usado',
      'vence': '28 Feb 2026',
    },
    {
      'tienda': 'Jumbo',
      'descripcion': '15% en productos de aseo',
      'descuento': '15%',
      'puntos': 200,
      'fecha': '01 Abr 2026',
      'estado': 'vencido',
      'vence': '15 Ene 2026',
    },
  ];

  List<Map<String, dynamic>> get _filtrados {
    if (_filtro == 'todos') return _canjes;
    return _canjes.where((c) => c['estado'] == _filtro).toList();
  }

  Color _badgeColor(String estado) {
    switch (estado) {
      case 'activo': return GreenColors.medium;
      case 'usado':  return MaterialColors.grey;
      default:       return SemanticColors.errorRed;
    }
  }

  Color _badgeBg(String estado) {
    switch (estado) {
      case 'activo': return GreenColors.lightBg;
      case 'usado':  return MaterialBgColors.grey;
      default:       return MaterialBgColors.red;
    }
  }

  String _badgeLabel(String estado) {
    switch (estado) {
      case 'activo': return 'Activo';
      case 'usado':  return 'Usado';
      default:       return 'Vencido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MisCanjesStyles.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFiltros(),
            const SizedBox(height: 8),
            Expanded(child: _buildLista()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: MisCanjesStyles.headerPadding,
      decoration: const BoxDecoration(
        color: GreenColors.dark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(MisCanjesStyles.headerRadius),
          bottomRight: Radius.circular(MisCanjesStyles.headerRadius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Mis canjes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: MisCanjesStyles.headerGap),
          Container(
            padding: MisCanjesStyles.bannerPadding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(MisCanjesStyles.bannerRadius),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded,
                    color: GreenColors.light, size: 20),
                const SizedBox(width: 10),
                const Text(
                  'Puntos usados en canjes:',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const Spacer(),
                const Text(
                  '350 pts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    final filtros = [
      {'key': 'todos',   'label': 'Todos'},
      {'key': 'activo',  'label': 'Activos'},
      {'key': 'usado',   'label': 'Usados'},
      {'key': 'vencido', 'label': 'Vencidos'},
    ];

    return Padding(
      padding: MisCanjesStyles.filtroPadding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filtros.map((f) {
            final bool activo = _filtro == f['key'];
            return GestureDetector(
              onTap: () => setState(() => _filtro = f['key']!),
              child: Container(
                margin: MisCanjesStyles.filterChipMargin,
                padding: MisCanjesStyles.filterChipPadding,
                decoration: BoxDecoration(
                  color: activo ? GreenColors.dark : Colors.white,
                  borderRadius: BorderRadius.circular(MisCanjesStyles.filterChipRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: activo ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLista() {
    if (_filtrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard_outlined,
                size: MisCanjesStyles.emptyIconSize, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No tienes canjes aquí',
              style: TextStyle(color: Colors.grey[400], fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: MisCanjesStyles.listPadding,
      itemCount: _filtrados.length,
      itemBuilder: (context, i) => _buildCard(_filtrados[i]),
    );
  }

  Widget _buildCard(Map<String, dynamic> c) {
    final String estado = c['estado'] as String;

    return Container(
      margin: MisCanjesStyles.cardMargin,
      padding: MisCanjesStyles.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MisCanjesStyles.cardRadius),
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

          Container(
            width: MisCanjesStyles.discountSize,
            height: MisCanjesStyles.discountSize,
            decoration: BoxDecoration(
              color: GreenColors.lightBg,
              borderRadius: BorderRadius.circular(MisCanjesStyles.discountRadius),
            ),
            child: Center(
              child: Text(
                c['descuento'] as String,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: GreenColors.dark,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c['tienda'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: GreenColors.veryDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: MisCanjesStyles.badgePadding,
                      decoration: BoxDecoration(
                        color: _badgeBg(estado),
                        borderRadius: BorderRadius.circular(MisCanjesStyles.badgeRadius),
                      ),
                      child: Text(
                        _badgeLabel(estado),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _badgeColor(estado),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  c['descripcion'] as String,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.stars_rounded,
                        size: 13, color: Colors.grey[400]),
                    const SizedBox(width: 3),
                    Text(
                      '${c['puntos']} pts · Vence ${c['vence']}',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[400]),
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
}
