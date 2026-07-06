// lib/screens/historial_entregas_screen.dart

import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../services/usuario_service.dart';

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
        UsuarioService.getHistorialPuntos(),
      ]);
      final entregasData = results[0];
      final reservasData = results[1];
      final historialPuntos = results[2];
      final listaEntregas = ((entregasData['entregas'] as List?) ?? []).map((e) => _normalizarEntrega(e as Map<String, dynamic>));
      final listaReservas = ((reservasData['reservas'] as List?) ?? []).map((r) => _normalizarReserva(r as Map<String, dynamic>));
      final listaMovimientos = ((historialPuntos['movimientos'] as List?) ?? []).map((m) => _normalizarMovimiento(m as Map<String, dynamic>));
      setState(() {
        _entregas = [...listaMovimientos, ...listaReservas, ...listaEntregas];
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
    final punto = r['puntoReciclaje'] as Map<String, dynamic>? ?? {};
    final nomEstado = (r['estado'] ?? '').toString();
    final estado = nomEstado == 'completada' ? 'completado' : nomEstado;
    return {
      'supermercado': punto['nombre'] ?? 'Sin punto',
      'material': 'Pendiente de entrega',
      'peso': '-',
      'pesoNum': 0.0,
      'puntos': 0,
      'fecha': _formatearFecha(r['fecha'] ?? ''),
      'estado': estado,
      'icon': BootstrapIcons.clock,
      'color': const Color(0xFFE67E22),
      'bg': const Color(0xFFFAEEDA),
    };
  }

  Map<String, dynamic> _normalizarMovimiento(Map<String, dynamic> m) {
    final tipo = m['tipoMovimiento'] as String? ?? 'ajuste';
    final puntos = m['puntos'] as num? ?? 0;
    final esGanado = tipo == 'ganados';

    IconData icon;
    Color color, bg;
    String label;

    switch (tipo) {
      case 'ganados':
        icon = BootstrapIcons.plus_circle;
        color = const Color(0xFF2D5A1B);
        bg = const Color(0xFFE8F5E0);
        label = 'Entrega registrada';
        break;
      case 'descontados':
        icon = BootstrapIcons.dash_circle;
        color = const Color(0xFFC0392B);
        bg = const Color(0xFFFDEDEC);
        label = 'Canje de recompensa';
        break;
      default:
        icon = BootstrapIcons.sliders;
        color = const Color.fromARGB(255, 235, 80, 8);
        bg = const Color.fromARGB(255, 234, 227, 214);
        label = 'Ajuste de puntos';
        break;
    }

    return {
      'supermercado': m['descripcion'] ?? label,
      'material': label,
      'peso': '-',
      'pesoNum': 0.0,
      'puntos': esGanado ? puntos : -puntos.abs(),
      'fecha': _formatearFecha(m['fechaMovimiento'] ?? ''),
      'estado': 'completado',
      'icon': icon,
      'color': color,
      'bg': bg,
    };
  }

  Map<String, dynamic> _normalizarEntrega(Map<String, dynamic> item) {
    final estadoObj = item['estadoEntrega'] as Map<String, dynamic>? ?? {};
    final nomEstado = (estadoObj['nombre'] ?? item['idEstadoEntrega'] ?? '').toString();
    final estado = nomEstado == 'completada' ? 'completado' : nomEstado;

    final punto = item['puntoReciclaje'] as Map<String, dynamic>? ?? {};
    final detalles = (item['detalles'] as List?) ?? [];
    String primerMaterial = 'Material';
    if (detalles.isNotEmpty) {
      final d = detalles[0] as Map<String, dynamic>?;
      final mat = d?['material'] as Map<String, dynamic>?;
      primerMaterial = mat?['nombre']?.toString() ?? 'Material';
    }
    final material = _materialConfig(primerMaterial);

    final rawPeso = item['pesoTotal'] ?? 0;
    final pesoNum = (rawPeso is num) ? rawPeso.toDouble() : 0.0;
    return {
      'supermercado': punto['nombre'] ?? 'Sin punto',
      'material': primerMaterial,
      'peso': _formatearPeso(pesoNum),
      'pesoNum': pesoNum,
      'puntos': item['puntosTotales'] ?? 0,
      'fecha': _formatearFecha(item['fechaEntrega'] ?? ''),
      'estado': estado,
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

  String _normalizarMaterial(String m) {
    return m.toLowerCase().trim()
        .replaceAll('á', 'a').replaceAll('é', 'e')
        .replaceAll('í', 'i').replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }

  Map<String, dynamic> _materialConfig(String material) {
    final map = {
      'plastico':   {'icon': BootstrapIcons.water,    'color': const Color(0xFF185FA5), 'bg': const Color(0xFFE6F1FB)},
      'papel':      {'icon': BootstrapIcons.file_text,   'color': const Color(0xFF3B6D11), 'bg': const Color(0xFFEAF3DE)},
      'vidrio':     {'icon': BootstrapIcons.cup_straw,      'color': const Color(0xFF0F6E56), 'bg': const Color(0xFFE1F5EE)},
      'carton':     {'icon': BootstrapIcons.box_seam,   'color': const Color(0xFF854F0B), 'bg': const Color(0xFFFAEEDA)},
      'metal':      {'icon': BootstrapIcons.tools,      'color': const Color(0xFF5F5E5A), 'bg': const Color(0xFFF1EFE8)},
      'organico':   {'icon': BootstrapIcons.tree,           'color': const Color(0xFF4A7C2E), 'bg': const Color(0xFFE8F5E0)},
      'electronico':{'icon': BootstrapIcons.device_ssd,       'color': const Color(0xFF6B3FA0), 'bg': const Color(0xFFF0E6FA)},
    };
    return map[_normalizarMaterial(material)] ?? {
      'icon': BootstrapIcons.recycle,
      'color': const Color(0xFF2D5A1B),
      'bg': const Color(0xFFE8F0E0),
    };
  }

  bool _estadoEnRecientes(String estado) {
    return estado == 'pendiente' || estado == 'confirmada';
  }

  List<Map<String, dynamic>> get _filtradas {
    if (_filtro == 'todos') return _entregas;
    return _entregas.where((e) {
      if (_filtro == 'recientes') {
        return _estadoEnRecientes(e['estado'] as String? ?? '');
      }
      return e['estado'] == _filtro;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 236, 230),
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
         gradient: LinearGradient(
           begin: Alignment.topLeft,
           end: Alignment.bottomRight,
        colors:[Color.fromARGB(255, 20, 125, 35),Color.fromARGB(255, 46, 158, 55), Color.fromARGB(255, 30, 220, 40),Color.fromARGB(255, 170, 225, 90)],
        stops: [0.0,0.35, 0.6, 1.0],
        ),
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
                child: const Icon(BootstrapIcons.chevron_left,
                    color: Color.fromARGB(255, 249, 251, 248), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                  'Historial',
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
            color: const Color.fromARGB(255, 8, 8, 8).withValues(alpha: 0.65),
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
                color: activo ? const Color.fromARGB(255, 201, 236, 168) : const Color.fromARGB(255, 206, 229, 185),
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
                  color: activo ? const Color.fromARGB(255, 12, 12, 12) : const Color.fromARGB(255, 17, 15, 15),
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
            '${_filtradas.length} movimientos',
            style: TextStyle(
              fontSize: 13,
              color: const Color.fromARGB(255, 41, 41, 41),
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
              Icon(BootstrapIcons.cloud_slash, size: 64, color: const Color.fromARGB(246, 188, 245, 127)),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: const Color.fromARGB(255, 32, 31, 31), fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _cargarEntregas,
                icon: const Icon(BootstrapIcons.arrow_clockwise),
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
            Icon(BootstrapIcons.inbox, size: 64, color: const Color.fromARGB(255, 225, 243, 212)),
            const SizedBox(height: 12),
          Text(
            'No hay movimientos aquí',
            style: TextStyle(color: const Color.fromARGB(255, 79, 78, 78), fontSize: 15),
          ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarEntregas,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: _filtradas.length,
        itemBuilder: (context, i) => _buildCard(_filtradas[i]),
      ),
    );
  }

  // ── CARD de entrega ──────────────────────────────────────
  Widget _buildCard(Map<String, dynamic> e) {
    return GestureDetector(
      onTap: () => _mostrarDetalle(e),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 237, 244, 234),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 20, 19, 19).withValues(alpha: 0.05),
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
                    color: Color.fromARGB(255, 13, 16, 11),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(BootstrapIcons.shop,
                        size: 12, color: const Color.fromARGB(255, 0, 0, 0)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        e['supermercado'] as String,
                        style: TextStyle(fontSize: 12, color: const Color.fromARGB(255, 20, 14, 14)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(BootstrapIcons.calendar,
                        size: 12, color: const Color.fromARGB(255, 19, 16, 16)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        e['fecha'] as String,
                        style: TextStyle(fontSize: 12, color: const Color.fromARGB(255, 17, 4, 4)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Puntos y peso
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(BootstrapIcons.star_fill,
                        size: 14, color: Color.fromARGB(255, 142, 235, 66)),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        (e['puntos'] as num) >= 0
                            ? '+${e['puntos']} pts'
                            : '${e['puntos']} pts',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: (e['puntos'] as num) >= 0
                              ? const Color.fromARGB(255, 8, 12, 7)
                              : const Color.fromARGB(255, 202, 38, 20),
                        ),
                        overflow: TextOverflow.ellipsis,
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
          ),

        ],
      ),
    ),
    );
  }

  void _mostrarDetalle(Map<String, dynamic> e) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 41, 39, 39),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: e['bg'] as Color,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(e['icon'] as IconData,
                    color: e['color'] as Color, size: 32),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                e['material'] as String,
                style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 34, 65, 17),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: (e['estado'] as String) == 'completado'
                      ? const Color.fromARGB(255, 203, 227, 171)
                      : const Color.fromARGB(255, 198, 222, 168),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (e['estado'] as String) == 'completado'
                      ? 'Completado' : 'Pendiente',
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: (e['estado'] as String) == 'completado'
                        ? const Color.fromARGB(255, 92, 162, 34) : const Color.fromARGB(255, 229, 89, 29),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _detalleFila(BootstrapIcons.shop, 'Supermercado', e['supermercado'] as String),
            const Divider(height: 20),
            _detalleFila(BootstrapIcons.calendar, 'Fecha', e['fecha'] as String),
            const Divider(height: 20),
            _detalleFila(BootstrapIcons.box, 'Peso', e['peso'] as String),
            const Divider(height: 20),
            _detalleFila(BootstrapIcons.star_fill, 'Puntos',
                '${((e['puntos'] is num ? e['puntos'] as num : num.tryParse('${e['puntos']}') ?? 0) >= 0 ? '+' : '')}${e['puntos']} pts'),
            const Divider(height: 20),
            _detalleFila(BootstrapIcons.info_circle, 'Estado',
                (e['estado'] as String) == 'completado'
                    ? 'Entregado' : 'Pendiente de confirmación'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detalleFila(IconData icon, String label, String valor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color.fromARGB(255, 8, 19, 6)),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(fontSize: 13, color: const Color.fromARGB(255, 32, 88, 13))),
        const SizedBox(width: 8),
        Expanded(
          child: Text(valor,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 25, 41, 17),
              )),
        ),
      ],
    );
  }
}