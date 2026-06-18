// lib/screens/historial_entregas_screen.dart

import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../theme/app_theme.dart';

class HistorialEntregasScreen extends StatefulWidget {
  const HistorialEntregasScreen({super.key});

  @override
  State<HistorialEntregasScreen> createState() =>
      _HistorialEntregasScreenState();
}

class _HistorialEntregasScreenState extends State<HistorialEntregasScreen> {
  String _filtro = 'todos';
  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _entregas = [];

  @override
  void initState() {
    super.initState();
    _cargarEntregas();
  }

  Future<void> _cargarEntregas() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        UsuarioService.getEntregas(),
        UsuarioService.getReservas(),
      ]);
      final entregasData = results[0];
      final reservasData = results[1];
      final listaEntregas = ((entregasData['entregas'] as List?) ?? []).map((e) => _normalizarEntrega(e as Map<String, dynamic>));
      final listaReservas = ((reservasData['reservas'] as List?) ?? []).map((r) => _normalizarReserva(r as Map<String, dynamic>));
      setState(() {
        _entregas = [...listaReservas, ...listaEntregas];
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudieron cargar las entregas';
        _cargando = false;
      });
    }
  }

  Map<String, dynamic> _normalizarReserva(Map<String, dynamic> r) {
    final punto = r['punto'] as Map<String, dynamic>? ?? r['aliado'] as Map<String, dynamic>? ?? {};
    return {
      'supermercado': punto['nombre'] ?? r['nombrePunto'] ?? 'Sin punto',
      'material': 'Pendiente de entrega',
      'peso': '-',
      'pesoNum': 0.0,
      'puntos': 0,
      'fecha': _formatearFecha(r['fecha'] ?? ''),
      'estado': 'pendiente',
      'icon': Icons.schedule_outlined,
      'color': const Color(0xFFE67E22),
      'bg': const Color(0xFFFAEEDA),
    };
  }

  Map<String, dynamic> _normalizarEntrega(Map<String, dynamic> item) {
    final material = _materialConfig(item['material'] ?? '');
    final punto = item['punto'] as Map<String, dynamic>? ?? {};
    final rawPeso = item['pesoTotal'] ?? item['peso_total'] ?? 0;
    final pesoNum = (rawPeso is num) ? rawPeso.toDouble() : 0.0;
    return {
      'supermercado': punto['nombre'] ?? item['supermercado'] ?? 'Sin punto',
      'material': item['material'] ?? 'Material',
      'peso': _formatearPeso(pesoNum),
      'pesoNum': pesoNum,
      'puntos': item['puntos'] ?? item['puntosObtenidos'] ?? 0,
      'fecha': _formatearFecha(item['fecha'] ?? ''),
      'estado': item['estado'] ?? 'pendiente',
      'icon': material['icon'],
      'color': material['color'],
      'bg': material['bg'],
    };
  }

  String _formatearPeso(double kg) {
    if (kg >= 1) return '${kg.toStringAsFixed(1)} kg';
    return '${(kg * 1000).toStringAsFixed(0)} g';
  }

  String _formatearFecha(String fecha) {
    if (fecha.isEmpty) return '';
    try {
      final dt = DateTime.parse(fecha);
      final meses = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      return '${dt.day} ${meses[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return fecha;
    }
  }

  Map<String, dynamic> _materialConfig(String material) {
    final map = {
      'plastico':   {'icon': Icons.water_drop_outlined,    'color': const Color(0xFF185FA5), 'bg': const Color(0xFFE6F1FB)},
      'papel':      {'icon': Icons.description_outlined,   'color': const Color(0xFF3B6D11), 'bg': const Color(0xFFEAF3DE)},
      'vidrio':     {'icon': Icons.wine_bar_outlined,      'color': const Color(0xFF0F6E56), 'bg': const Color(0xFFE1F5EE)},
      'carton':     {'icon': Icons.inventory_2_outlined,   'color': const Color(0xFF854F0B), 'bg': const Color(0xFFFAEEDA)},
      'metal':      {'icon': Icons.hardware_outlined,      'color': const Color(0xFF5F5E5A), 'bg': const Color(0xFFF1EFE8)},
      'organico':   {'icon': Icons.eco_outlined,           'color': const Color(0xFF4A7C2E), 'bg': const Color(0xFFE8F5E0)},
      'electronico':{'icon': Icons.devices_outlined,       'color': const Color(0xFF6B3FA0), 'bg': const Color(0xFFF0E6FA)},
    };
    return map[material.toLowerCase().trim()] ?? {
      'icon': Icons.recycling_outlined,
      'color': const Color(0xFF2D5A1B),
      'bg': const Color(0xFFE8F0E0),
    };
  }

  List<Map<String, dynamic>> get _filtradas {
    if (_filtro == 'todos') return _entregas;
    return _entregas.where((e) {
      if (_filtro == 'recientes') {
        return e['estado'] == 'completado' || e['estado'] == 'pendiente';
      }
      return e['estado'] == _filtro;
    }).toList();
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

  Widget _buildHeader() {
    final totalKg = _entregas.fold<double>(0.0, (sum, e) => sum + (e['pesoNum'] as double));
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
          Row(
            children: [
              _buildHeaderStat('${totalKg.toStringAsFixed(1)} kg', 'Total reciclado'),
              const SizedBox(width: 32),
              _buildHeaderStat('${_entregas.length}', 'Total entregas'),
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
            color: Colors.white.withValues(alpha: 0.65),
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
                    color: Colors.black.withValues(alpha: 0.04),
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
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_outlined, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Colors.grey[400], fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _cargarEntregas,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

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
            color: Colors.black.withValues(alpha: 0.05),
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