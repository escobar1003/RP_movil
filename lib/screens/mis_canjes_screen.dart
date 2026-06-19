import 'package:flutter/material.dart';
import '../services/usuario_service.dart';

class MisCanjesScreen extends StatefulWidget {
  const MisCanjesScreen({super.key});

  @override
  State<MisCanjesScreen> createState() => _MisCanjesScreenState();
}

class _MisCanjesScreenState extends State<MisCanjesScreen> {
  String _filtro = 'todos';
  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _canjes = [];
  int _puntosUsados = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final res = await UsuarioService.getCanjes();
      final lista = (res['canjes'] as List?) ?? [];
      int totalPts = 0;
      final parsed = lista.map((j) {
        final c = j as Map<String, dynamic>;
        final r = c['recompensa'] as Map<String, dynamic>? ?? {};
        final e = c['estadoCanje'] as Map<String, dynamic>? ?? {};
        final pts = c['puntosUsados'] ?? 0;
        totalPts += (pts is int ? pts : 0);
        return {
          'tienda': r['nombre'] ?? 'Recompensa',
          'descripcion': r['descripcion'] ?? '',
          'descuento': '${r['puntosRequeridos'] ?? pts} pts',
          'puntos': pts,
          'fecha': _formatearFecha(c['fechaCanje']?.toString() ?? ''),
          'estado': _mapEstado(e['nombre']?.toString() ?? ''),
          'vence': c['codigoCanje'] ?? '',
        };
      }).toList();
      setState(() {
        _canjes = parsed;
        _puntosUsados = totalPts;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar canjes: $e';
        _cargando = false;
      });
    }
  }

  String _formatearFecha(String fecha) {
    if (fecha.isEmpty) return '';
    try {
      final dt = DateTime.parse(fecha);
      final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return '${dt.day} ${meses[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return fecha;
    }
  }

  String _mapEstado(String? nombre) {
    switch (nombre?.toLowerCase()) {
      case 'pendiente':
      case 'activo':
        return 'activo';
      case 'completado':
      case 'usado':
      case 'canjeado':
        return 'usado';
      case 'vencido':
      case 'cancelado':
        return 'vencido';
      default:
        return 'activo';
    }
  }

  List<Map<String, dynamic>> get _filtrados {
    if (_filtro == 'todos') return _canjes;
    return _canjes.where((c) => c['estado'] == _filtro).toList();
  }

  Color _badgeColor(String estado) {
    switch (estado) {
      case 'activo': return const Color(0xFF3B6D11);
      case 'usado':  return const Color(0xFF5F5E5A);
      default:       return const Color(0xFFA32D2D);
    }
  }

  Color _badgeBg(String estado) {
    switch (estado) {
      case 'activo': return const Color(0xFFEAF3DE);
      case 'usado':  return const Color(0xFFF1EFE8);
      default:       return const Color(0xFFFCEBEB);
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
      backgroundColor: const Color(0xFFF4F6EF),
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
                'Mis canjes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded,
                    color: Color(0xFF7BC043), size: 20),
                const SizedBox(width: 10),
                const Text(
                  'Puntos usados en canjes:',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const Spacer(),
                Text(
                  '$_puntosUsados pts',
                  style: const TextStyle(
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filtros.map((f) {
            final bool activo = _filtro == f['key'];
            return GestureDetector(
              onTap: () => setState(() => _filtro = f['key']!),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
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
      ),
    );
  }

  Widget _buildLista() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2D5A1B)),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 16),
              TextButton(onPressed: _cargarDatos, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }
    if (_filtrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard_outlined,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No tienes canjes aquí',
              style: TextStyle(color: Colors.grey[400], fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        itemCount: _filtrados.length,
        itemBuilder: (context, i) => _buildCard(_filtrados[i]),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> c) {
    final String estado = c['estado'] as String;

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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3DE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                c['descuento'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5A1B),
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
                          color: Color(0xFF1E3A0F),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _badgeBg(estado),
                        borderRadius: BorderRadius.circular(10),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.stars_rounded,
                        size: 13, color: Colors.grey[400]),
                    const SizedBox(width: 3),
                    Text(
                      '${c['puntos']} pts · ${c['vence']}',
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