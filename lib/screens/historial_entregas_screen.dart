// lib/screens/historial_entregas_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class HistorialEntregasScreen extends StatefulWidget {
  const HistorialEntregasScreen({super.key});

  @override
  State<HistorialEntregasScreen> createState() =>
      _HistorialEntregasScreenState();
}

class _HistorialEntregasScreenState extends State<HistorialEntregasScreen> {

  // Filtro activo: 'todos', 'recientes', 'completados'
  String _filtro = 'todos';

  // Datos de prueba — vendrán del backend después
  final List<Map<String, dynamic>> _entregas = [
    {
      'supermercado': 'Éxito',
      'material': 'Plástico',
      'peso': '1.2 kg',
      'puntos': 120,
      'fecha': '12 May 2026',
      'estado': 'completado',
      'icon': Icons.water_drop_outlined,
      'color': const Color(0xFF185FA5),
      'bg': const Color(0xFFE6F1FB),
    },
    {
      'supermercado': 'D1',
      'material': 'Papel',
      'peso': '0.8 kg',
      'puntos': 80,
      'fecha': '10 May 2026',
      'estado': 'completado',
      'icon': Icons.description_outlined,
      'color': const Color(0xFF3B6D11),
      'bg': const Color(0xFFEAF3DE),
    },
    {
      'supermercado': 'Jumbo',
      'material': 'Vidrio',
      'peso': '2.1 kg',
      'puntos': 210,
      'fecha': '05 May 2026',
      'estado': 'completado',
      'icon': Icons.wine_bar_outlined,
      'color': const Color(0xFF0F6E56),
      'bg': const Color(0xFFE1F5EE),
    },
    {
      'supermercado': 'Carulla',
      'material': 'Cartón',
      'peso': '3.5 kg',
      'puntos': 350,
      'fecha': '01 May 2026',
      'estado': 'completado',
      'icon': Icons.inventory_2_outlined,
      'color': const Color(0xFF854F0B),
      'bg': const Color(0xFFFAEEDA),
    },
    {
      'supermercado': 'Éxito',
      'material': 'Metal',
      'peso': '0.5 kg',
      'puntos': 50,
      'fecha': '28 Abr 2026',
      'estado': 'completado',
      'icon': Icons.hardware_outlined,
      'color': const Color(0xFF5F5E5A),
      'bg': const Color(0xFFF1EFE8),
    },
  ];

  List<Map<String, dynamic>> get _filtradas {
    if (_filtro == 'todos') return _entregas;
    return _entregas.where((e) => e['estado'] == _filtro).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6EF),
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

  // ── HEADER ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF2D5A1B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
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
          // Stats grandes
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
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ── FILTROS ──────────────────────────────────────────────
  Widget _buildFiltros() {
    final filtros = [
      {'key': 'todos', 'label': 'Todos'},
      {'key': 'recientes', 'label': 'Recientes'},
      {'key': 'completado', 'label': 'Completados'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: filtros.map((f) {
          final bool activo = _filtro == f['key'];
          return GestureDetector(
            onTap: () => setState(() => _filtro = f['key']!),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: activo ? const Color(0xFF2D5A1B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
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

  // ── STATS ROW ────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
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

  // ── LISTA ────────────────────────────────────────────────
  Widget _buildLista() {
    if (_filtradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: _filtradas.length,
      itemBuilder: (context, i) => _buildCard(_filtradas[i]),
    );
  }

  // ── CARD de entrega ──────────────────────────────────────
  Widget _buildCard(Map<String, dynamic> e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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

          // Ícono del material
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: e['bg'] as Color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(e['icon'] as IconData,
                color: e['color'] as Color, size: 24),
          ),

          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e['material'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A0F),
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

          // Puntos y peso
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars_rounded,
                      size: 14, color: Color(0xFF7BC043)),
                  const SizedBox(width: 3),
                  Text(
                    '+${e['puntos']} pts',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5A1B),
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