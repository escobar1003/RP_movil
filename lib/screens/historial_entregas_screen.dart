import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../services/auth_service.dart';

class HistorialEntregasScreen extends StatefulWidget {
  const HistorialEntregasScreen({super.key});

  @override
  State<HistorialEntregasScreen> createState() => _HistorialEntregasScreenState();
}

class _HistorialEntregasScreenState extends State<HistorialEntregasScreen> {
  String _filtro = 'todos';
  List<Map<String, dynamic>> _entregas = [];
  bool _cargando = true;
  double _totalKg = 0;
  int _totalEntregas = 0;

  @override
  void initState() {
    super.initState();
    _cargarEntregas();
  }

  Future<void> _cargarEntregas() async {
    setState(() => _cargando = true);
    try {
      final data = await UsuarioService.getEntregas();
      final lista = data['entregas'] ?? data['data'] ?? [];
      _entregas = List<Map<String, dynamic>>.from(lista);
      _totalKg = (data['totalKg'] ?? data['kgReciclados'] ?? 0).toDouble();
      _totalEntregas = data['totalEntregas'] ?? data['entregas'] ?? _entregas.length;
    } catch (_) {
      _entregas = [];
    }
    if (mounted) setState(() => _cargando = false);
  }

  List<Map<String, dynamic>> get _filtradas {
    if (_filtro == 'todos') return _entregas;
    return _entregas.where((e) {
      final estado = (e['estado'] ?? '').toString().toLowerCase();
      if (_filtro == 'recientes') return estado == 'pendiente' || estado == 'proceso';
      return estado == _filtro;
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
            if (!_cargando) _buildStatsRow(),
            Expanded(child: _cargando ? const Center(child: CircularProgressIndicator()) : _buildLista()),
          ],
        ),
      ),
    );
  }

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
          Row(
            children: [
              _buildHeaderStat('${_totalKg.toStringAsFixed(1)} kg', 'Total reciclado'),
              const SizedBox(width: 32),
              _buildHeaderStat('$_totalEntregas', 'Total entregas'),
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

  Widget _buildCard(Map<String, dynamic> e) {
    final material = e['material'] ?? e['nombreMaterial'] ?? '';
    final supermercado = e['supermercado'] ?? e['punto'] ?? e['aliado'] ?? '';
    final fecha = e['fecha'] ?? e['createdAt'] ?? '';
    final peso = e['peso'] ?? e['kg'] ?? 0;
    final puntos = e['puntos'] ?? 0;

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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3DE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.recycling, color: Color(0xFF2D5A1B), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.toString(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A0F),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.store_outlined, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(supermercado.toString(),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(width: 8),
                    Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(fecha.toString(),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
                  const Icon(Icons.stars_rounded, size: 14, color: Color(0xFF7BC043)),
                  const SizedBox(width: 3),
                  Text(
                    '+$puntos pts',
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
                '${peso} kg',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
