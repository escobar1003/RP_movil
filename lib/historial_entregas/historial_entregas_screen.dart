// lib/historial_entregas/historial_entregas_screen.dart

import 'package:flutter/material.dart';
import '../styles/colors.dart';
import 'historial_entregas_style.dart';

class HistorialEntregasScreen extends StatefulWidget {
  const HistorialEntregasScreen({super.key});

  @override
  State<HistorialEntregasScreen> createState() =>
      _HistorialEntregasScreenState();
}

class _HistorialEntregasScreenState extends State<HistorialEntregasScreen> {

  String _filtro = 'todos';

  final List<Map<String, dynamic>> _entregas = [
    {
      'supermercado': 'Éxito',
      'material': 'Plástico',
      'peso': '1.2 kg',
      'puntos': 120,
      'fecha': '12 May 2026',
      'estado': 'completado',
      'icon': Icons.water_drop_outlined,
      'color': MaterialColors.blue,
      'bg': MaterialBgColors.blue,
    },
    {
      'supermercado': 'D1',
      'material': 'Papel',
      'peso': '0.8 kg',
      'puntos': 80,
      'fecha': '10 May 2026',
      'estado': 'completado',
      'icon': Icons.description_outlined,
      'color': GreenColors.medium,
      'bg': GreenColors.lightBg,
    },
    {
      'supermercado': 'Jumbo',
      'material': 'Vidrio',
      'peso': '2.1 kg',
      'puntos': 210,
      'fecha': '05 May 2026',
      'estado': 'completado',
      'icon': Icons.wine_bar_outlined,
      'color': MaterialColors.teal,
      'bg': MaterialBgColors.teal,
    },
    {
      'supermercado': 'Carulla',
      'material': 'Cartón',
      'peso': '3.5 kg',
      'puntos': 350,
      'fecha': '01 May 2026',
      'estado': 'completado',
      'icon': Icons.inventory_2_outlined,
      'color': MaterialColors.amber,
      'bg': MaterialBgColors.amber,
    },
    {
      'supermercado': 'Éxito',
      'material': 'Metal',
      'peso': '0.5 kg',
      'puntos': 50,
      'fecha': '28 Abr 2026',
      'estado': 'completado',
      'icon': Icons.hardware_outlined,
      'color': MaterialColors.grey,
      'bg': MaterialBgColors.grey,
    },
  ];

  List<Map<String, dynamic>> get _filtradas {
    if (_filtro == 'todos') return _entregas;
    return _entregas.where((e) => e['estado'] == _filtro).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HistorialStyles.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFiltros(),
            _buildStatsRow(),
            Expanded(child: _buildLista()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: HistorialStyles.headerPadding,
      decoration: const BoxDecoration(
        color: GreenColors.dark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(HistorialStyles.headerRadius),
          bottomRight: Radius.circular(HistorialStyles.headerRadius),
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
                'Mis entregas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildHeaderStat('45.8 kg', 'Total reciclado'),
              const SizedBox(width: 32),
              _buildHeaderStat('23', 'Total entregas'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: HistorialStyles.statValueSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: HistorialStyles.statLabelSize,
          ),
        ),
      ],
    );
  }

  Widget _buildFiltros() {
    final filtros = [
      {'key': 'todos', 'label': 'Todos'},
      {'key': 'recientes', 'label': 'Recientes'},
      {'key': 'completado', 'label': 'Completados'},
    ];

    return Padding(
      padding: HistorialStyles.filtroPadding,
      child: Row(
        children: filtros.map((f) {
          final bool activo = _filtro == f['key'];
          return GestureDetector(
            onTap: () => setState(() => _filtro = f['key']!),
            child: Container(
              margin: HistorialStyles.filterChipMargin,
              padding: HistorialStyles.filterChipPadding,
              decoration: BoxDecoration(
                color: activo ? GreenColors.dark : Colors.white,
                borderRadius: BorderRadius.circular(HistorialStyles.filterChipRadius),
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
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: HistorialStyles.statsPadding,
      child: Row(
        children: [
          Text(
            '${_filtradas.length} entregas',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLista() {
    if (_filtradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: HistorialStyles.emptyIconSize, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No hay entregas aquí',
              style: TextStyle(color: Colors.grey[400], fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: HistorialStyles.listPadding,
      itemCount: _filtradas.length,
      itemBuilder: (context, i) => _buildCard(_filtradas[i]),
    );
  }

  Widget _buildCard(Map<String, dynamic> e) {
    return Container(
      margin: HistorialStyles.cardMargin,
      padding: HistorialStyles.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HistorialStyles.cardRadius),
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
            width: HistorialStyles.iconSize,
            height: HistorialStyles.iconSize,
            decoration: BoxDecoration(
              color: e['bg'] as Color,
              borderRadius: BorderRadius.circular(HistorialStyles.iconRadius),
            ),
            child: Icon(e['icon'] as IconData,
                color: e['color'] as Color, size: 24),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e['material'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: GreenColors.veryDark,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.store_outlined,
                        size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      e['supermercado'] as String,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      e['fecha'] as String,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars_rounded,
                      size: 14, color: GreenColors.light),
                  const SizedBox(width: 3),
                  Text(
                    '+${e['puntos']} pts',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: GreenColors.dark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                e['peso'] as String,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
