// lib/screens/mapa_puntos_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../data/puntos_reciclaje_data.dart';
import 'reservas.dart';

class MapaPuntosScreen extends StatefulWidget {
  final bool soloMapa;

  const MapaPuntosScreen({super.key, this.soloMapa = false});

  @override
  State<MapaPuntosScreen> createState() => _MapaPuntosScreenState();
}

class _MapaPuntosScreenState extends State<MapaPuntosScreen> {

  Map<String, dynamic>? puntoSeleccionado;
  final MapController _mapController = MapController();

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
                markers: puntosReciclaje.map((punto) {
                  final bool activo =
                      puntoSeleccionado?['nombre'] == punto['nombre'];
                  return Marker(
                    point: punto['ubicacion'],
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => puntoSeleccionado = punto);
                        _mapController.move(punto['ubicacion'], 15.0);
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
                              color: Colors.black.withOpacity(0.2),
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
                              color: Colors.black.withOpacity(0.1),
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '${puntosReciclaje.length} puntos de reciclaje',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
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
                      color: Colors.black.withOpacity(0.12),
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
                                      puntoSeleccionado!['direccion'],
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
                          puntoSeleccionado!['materiales'],
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