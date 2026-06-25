// lib/screens/mapa_puntos_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'reservas.dart';
import 'package:geolocator/geolocator.dart';
class MapaPuntosScreen extends StatefulWidget {
  final bool soloMapa;
  final Map<String, dynamic>? datosIA;
  final List<Map<String, dynamic>>? materialesIA;

  const MapaPuntosScreen({
    super.key,
    this.soloMapa = false,
    this.datosIA,
    this.materialesIA,
  });

  @override
  State<MapaPuntosScreen> createState() => _MapaPuntosScreenState();
}

class _MapaPuntosScreenState extends State<MapaPuntosScreen> {

  Map<String, dynamic>? puntoSeleccionado;
  final MapController _mapController = MapController();
  LatLng? _miUbicacion;
  bool _cargandoUbicacion = true;
  List<Map<String, dynamic>> _puntos = [];
  bool _cargandoPuntos = true;
  bool _mostrarLista = false;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
    _cargarPuntos();
  }

  Future<void> _cargarPuntos() async {
    try {
      final data = await ApiService.get('/puntos-reciclaje');
      final lista = (data['puntos'] as List?) ?? [];
      setState(() {
        _puntos = lista
          .map((p) => Map<String, dynamic>.from(p))
          .where((p) => p['latitud'] != null && p['longitud'] != null)
          .toList();
        _cargandoPuntos = false;
      });
    } catch (_) {
      setState(() => _cargandoPuntos = false);
    }
  }

  String _formatMateriales(dynamic materiales) {
    if (materiales == null) return 'Sin materiales';
    if (materiales is String) return materiales;
    if (materiales is List) {
      return materiales.map((m) => m is Map ? m['nombre'] ?? '' : m.toString()).join(', ');
    }
    return materiales.toString();
  }

  List<Map<String, dynamic>> get _aliadosUnicos {
    final vistos = <String>{};
    return _puntos.where((p) {
      final nombre = (p['aliado'] is Map ? p['aliado']['nombre'] : p['aliado'])?.toString() ?? '';
      if (nombre.isEmpty || vistos.contains(nombre)) return false;
      vistos.add(nombre);
      return true;
    }).map((p) => {
      'nombre': (p['aliado'] is Map ? p['aliado']['nombre'] : p['aliado'])?.toString() ?? '',
      'latitud': p['latitud'],
      'longitud': p['longitud'],
      'punto': p,
    }).toList()
      ..sort((a, b) => (a['nombre'] as String).compareTo(b['nombre'] as String));
  }

  Future<void> _obtenerUbicacion() async {
    try {
      bool servicioActivo = await Geolocator.isLocationServiceEnabled();
      if (!servicioActivo) {
        setState(() => _cargandoUbicacion = false);
        return;
      }
      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.denied) {
          setState(() => _cargandoUbicacion = false);
          return;
        }
      }
      if (permiso == LocationPermission.deniedForever) {
        setState(() => _cargandoUbicacion = false);
        return;
      }
      Position posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _miUbicacion = LatLng(posicion.latitude, posicion.longitude);
        _cargandoUbicacion = false;
      });
      _mapController.move(_miUbicacion!, 14.0);
    } catch (e) {
      setState(() => _cargandoUbicacion = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [

          // ── MAPA ─────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(2.4448, -76.6147),
              initialZoom: 13,
              onTap: (_, __) => setState(() => puntoSeleccionado = null),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.recycling.points',
              ),
              MarkerLayer(
                markers: [
                  if (_miUbicacion != null)
                    Marker(
                      point: _miUbicacion!,
                      width: 60,
                      height: 60,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.4),
                              blurRadius: 10,
                              spreadRadius: 4,
                            ) ,
                          ],
                        ),
                      ),
                    ),
                  ..._puntos.map((punto) {
                  final bool activo =
                      puntoSeleccionado?['nombre'] == punto['nombre'];
                  return Marker(
                    point: LatLng(
                      double.tryParse(punto['latitud']?.toString() ?? '') ?? 0,
                      double.tryParse(punto['longitud']?.toString() ?? '') ?? 0,
                    ),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => puntoSeleccionado = punto);
                        _mapController.move(LatLng(
                          double.tryParse(punto['latitud']?.toString() ?? '') ?? 0,
                          double.tryParse(punto['longitud']?.toString() ?? '') ?? 0,
                        ), 15.0);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: activo
                              ? AppColors.primary
                              : AppColors.secondary,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.store_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  );
                }).toList(),
                  ],
              ),
            ],
          ),

          // ── HEADER flotante ───────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_rounded,
                            size: 18, color: AppColors.textDark),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _mostrarLista = !_mostrarLista),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: AppColors.primary, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _cargandoPuntos
                                      ? 'Cargando puntos...'
                                      : '${_aliadosUnicos.length} supermercados',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              Icon(
                                _mostrarLista ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: AppColors.textLight, size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── LISTA de supermercados ────────────────────────
          if (_mostrarLista && _aliadosUnicos.isNotEmpty)
            Positioned(
              top: 110, left: 16, right: 16,
              bottom: MediaQuery.of(context).size.height * 0.25,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.store_rounded, size: 16, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Supermercados (${_aliadosUnicos.length})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: _aliadosUnicos.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                          itemBuilder: (context, index) {
                            final aliado = _aliadosUnicos[index];
                            final esSeleccionado = puntoSeleccionado != null &&
                                (puntoSeleccionado!['aliado'] is Map
                                    ? puntoSeleccionado!['aliado']['nombre']
                                    : puntoSeleccionado!['aliado'])?.toString() == aliado['nombre'];
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.store_rounded,
                                color: esSeleccionado ? AppColors.primary : AppColors.textLight,
                                size: 20,
                              ),
                              title: Text(
                                aliado['nombre'],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: esSeleccionado ? FontWeight.w600 : FontWeight.normal,
                                  color: AppColors.textDark,
                                ),
                              ),
                              trailing: esSeleccionado
                                  ? const Icon(Icons.check_circle, size: 16, color: AppColors.primary)
                                  : null,
                              onTap: () {
                                final punto = aliado['punto'] as Map<String, dynamic>;
                                setState(() {
                                  puntoSeleccionado = punto;
                                  _mostrarLista = false;
                                });
                                _mapController.move(
                                  LatLng(
                                    double.parse(punto['latitud'].toString()),
                                    double.parse(punto['longitud'].toString()),
                                  ),
                                  15.0,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── PANEL inferior ────────────────────────────────
          if (puntoSeleccionado != null)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Handle
                    Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Nombre y dirección
                    Row(
                      children: [
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.green100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.store_rounded,
                              color: AppColors.primary, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                puntoSeleccionado!['nombre'],
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 13, color: AppColors.textLight),
                                  const SizedBox(width: 3),
                                  Expanded(
                                      child: Text(
                                          puntoSeleccionado!['direccion'] ?? 'Sin dirección',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textLight),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Materiales
                    Row(
                      children: [
                        const Icon(Icons.recycling,
                            size: 14, color: AppColors.textLight),
                        const SizedBox(width: 6),
                        Text(
                          _formatMateriales(puntoSeleccionado!['materiales']),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMid),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Botón agendar (solo si no es modo soloMapa)
                    if (!widget.soloMapa)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_month, size: 20),
                          label: const Text('Agendar cita'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReservasScreen(
                                  aliado: puntoSeleccionado!,
                                  datosIA: widget.datosIA,
                                  materialesIA: widget.materialesIA,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                   
                  ],
                ),
              ),
            ),

        ],
      ),
    );
  }
}