// lib/screens/notificaciones_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../models/notificacion_model.dart';
import '../services/usuario_service.dart';
import '../services/socket_service.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  List<NotificacionModel> _todas = [];
  String _filtroActivo = 'Todas';
  bool _cargando = true;
  String? _error;

  final List<String> _filtros = [
    'Todas', 'Citas', 'Puntos', 'Canjes', 'Logros', 'Sistema'
  ];

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
    _subSocket = SocketService.instance.stream.listen((_) => _cargarNotificaciones());
  }

  @override
  void dispose() {
    _subSocket?.cancel();
    super.dispose();
  }

  StreamSubscription? _subSocket;

  Future<void> _cargarNotificaciones() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final data = await UsuarioService.getNotificaciones();
      final lista = (data['notificaciones'] as List?) ?? [];
      setState(() {
        _todas = lista.map((e) => NotificacionModel.fromJson(e as Map<String, dynamic>)).toList();
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudieron cargar las notificaciones';
        _cargando = false;
      });
    }
  }

  Future<void> _marcarLeida(int id) async {
    try {
      await UsuarioService.marcarNotificacionLeida(id);
    } catch (_) {}
    setState(() {
      final i = _todas.indexWhere((n) => n.id == id);
      if (i != -1) _todas[i] = _todas[i].marcarLeida();
    });
  }

  Future<void> _marcarTodasLeidas() async {
    try {
      await UsuarioService.marcarTodasNotificacionesLeidas();
    } catch (_) {}
    setState(() {
      _todas = _todas.map((n) => n.marcarLeida()).toList();
    });
  }

  List<NotificacionModel> get _filtradas {
    switch (_filtroActivo) {
      case 'Citas':
        return _todas.where((n) =>
          n.tipo == TipoNotificacion.citaAceptada ||
          n.tipo == TipoNotificacion.citaRechazada ||
          n.tipo == TipoNotificacion.citaRecordatorio ||
          n.tipo == TipoNotificacion.citaCompletada).toList();
      case 'Puntos':
        return _todas.where((n) =>
          n.tipo == TipoNotificacion.puntosGanados).toList();
      case 'Canjes':
        return _todas.where((n) =>
          n.tipo == TipoNotificacion.canjeExitoso).toList();
      case 'Logros':
        return _todas.where((n) =>
          n.tipo == TipoNotificacion.logroNivel ||
          n.tipo == TipoNotificacion.logroEntrega).toList();
      case 'Sistema':
        return _todas.where((n) =>
          n.tipo == TipoNotificacion.sistemaInfo).toList();
      default:
        return _todas;
    }
  }

  int get _noLeidas => _todas.where((n) => !n.leida).length;

  Map<String, List<NotificacionModel>> _agrupar(List<NotificacionModel> lista) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final ayer = hoy.subtract(const Duration(days: 1));

    final Map<String, List<NotificacionModel>> grupos = {};
    for (final n in lista) {
      final d = DateTime(n.fecha.year, n.fecha.month, n.fecha.day);
      String key;
      if (d == hoy)  key = 'Hoy';
      else if (d == ayer) key = 'Ayer';
      else key = '${n.fecha.day}/${n.fecha.month}/${n.fecha.year}';
      grupos.putIfAbsent(key, () => []).add(n);
    }
    return grupos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D5A1B),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Text('Notificaciones'),
            if (!_cargando && _noLeidas > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF7BC043),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$_noLeidas nuevas',
                    style: const TextStyle(fontSize: 11, color: Colors.white)),
              ),
            ],
          ],
        ),
        actions: [
          if (!_cargando && _noLeidas > 0)
            TextButton(
              onPressed: _marcarTodasLeidas,
              child: const Text('Leer todas',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
              Icon(BootstrapIcons.cloud_slash, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Colors.grey[400], fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _cargarNotificaciones,
                icon: const Icon(BootstrapIcons.arrow_clockwise),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final grupos = _agrupar(_filtradas);

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filtros.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final activo = _filtros[i] == _filtroActivo;
              return GestureDetector(
                onTap: () => setState(() => _filtroActivo = _filtros[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: activo ? const Color(0xFF2D5A1B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: activo ? const Color(0xFF2D5A1B) : const Color(0xFFD3D1C7),
                    ),
                  ),
                  child: Text(_filtros[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: activo ? Colors.white : const Color(0xFF5F5E5A),
                      )),
                ),
              );
            },
          ),
        ),

        Expanded(
          child: grupos.isEmpty
              ? _buildVacia()
              : RefreshIndicator(
                  onRefresh: _cargarNotificaciones,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                    children: grupos.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
                            child: Text(entry.key,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF9DB8A0),
                                    letterSpacing: 0.5)),
                          ),
                          ...entry.value.map((n) => _NotifCard(
                                notif: n,
                                onTap: () => _marcarLeida(n.id),
                              )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildVacia() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(BootstrapIcons.bell,
              size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text('Sin notificaciones',
              style: TextStyle(color: Color(0xFF9DB8A0), fontSize: 15)),
        ],
      ),
    );
  }
}

// ── Card individual de notificación ──────────────────────
class _NotifCard extends StatelessWidget {
  final NotificacionModel notif;
  final VoidCallback onTap;

  const _NotifCard({required this.notif, required this.onTap});

  _IconConfig get _config {
    switch (notif.tipo) {
      case TipoNotificacion.citaAceptada:
      case TipoNotificacion.citaCompletada:
        return _IconConfig(BootstrapIcons.check_circle,
            const Color(0xFFEAF3DE), const Color(0xFF3B6D11));
      case TipoNotificacion.citaRechazada:
        return _IconConfig(BootstrapIcons.x_circle,
            const Color(0xFFFCEBEB), const Color(0xFFA32D2D));
      case TipoNotificacion.citaRecordatorio:
        return _IconConfig(BootstrapIcons.clock_fill,
            const Color(0xFFFAEEDA), const Color(0xFF854F0B));
      case TipoNotificacion.puntosGanados:
        return _IconConfig(BootstrapIcons.star,
            const Color(0xFFEAF3DE), const Color(0xFF3B6D11));
      case TipoNotificacion.canjeExitoso:
        return _IconConfig(BootstrapIcons.gift,
            const Color(0xFFE6F1FB), const Color(0xFF185FA5));
      case TipoNotificacion.logroNivel:
      case TipoNotificacion.logroEntrega:
        return _IconConfig(BootstrapIcons.trophy,
            const Color(0xFFE1F5EE), const Color(0xFF0F6E56));
      case TipoNotificacion.sistemaInfo:
        return _IconConfig(BootstrapIcons.info_circle,
            const Color(0xFFF1EFE8), const Color(0xFF5F5E5A));
    }
  }

  _PillConfig get _pill {
    switch (notif.tipo) {
      case TipoNotificacion.citaAceptada:
      case TipoNotificacion.citaCompletada:
        return _PillConfig('Aceptada', const Color(0xFFEAF3DE), const Color(0xFF3B6D11));
      case TipoNotificacion.citaRechazada:
        return _PillConfig('Rechazada', const Color(0xFFFCEBEB), const Color(0xFFA32D2D));
      case TipoNotificacion.citaRecordatorio:
        return _PillConfig('Recordatorio', const Color(0xFFFAEEDA), const Color(0xFF854F0B));
      case TipoNotificacion.puntosGanados:
        return _PillConfig('Puntos', const Color(0xFFEAF3DE), const Color(0xFF3B6D11));
      case TipoNotificacion.canjeExitoso:
        return _PillConfig('Canje', const Color(0xFFE6F1FB), const Color(0xFF185FA5));
      case TipoNotificacion.logroNivel:
      case TipoNotificacion.logroEntrega:
        return _PillConfig('Logro', const Color(0xFFE1F5EE), const Color(0xFF0F6E56));
      case TipoNotificacion.sistemaInfo:
        return _PillConfig('Sistema', const Color(0xFFF1EFE8), const Color(0xFF5F5E5A));
    }
  }

  String _tiempoRelativo(DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24)   return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1)    return 'Ayer ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    return '${fecha.day}/${fecha.month} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cfg  = _config;
    final pill = _pill;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: notif.leida
              ? null
              : const Border(
                  left: BorderSide(color: Color(0xFF2D5A1B), width: 3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cfg.fondo,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(cfg.icono, color: cfg.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif.titulo,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E3A0F))),
                  const SizedBox(height: 3),
                  Text(notif.descripcion,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5F5E5A),
                          height: 1.4)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(_tiempoRelativo(notif.fecha),
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF9DB8A0))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: pill.fondo,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(pill.texto,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: pill.color)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!notif.leida)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF7BC043),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _IconConfig {
  final IconData icono;
  final Color fondo;
  final Color color;
  const _IconConfig(this.icono, this.fondo, this.color);
}

class _PillConfig {
  final String texto;
  final Color fondo;
  final Color color;
  const _PillConfig(this.texto, this.fondo, this.color);
}
