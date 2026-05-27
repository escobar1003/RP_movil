// lib/mapa_puntos/mapa_puntos_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../styles/colors.dart';
import '../data/puntos_reciclaje_data.dart';
import '../reservas/reservas.dart';
import 'mapa_puntos_style.dart';

class MapaPuntosScreen extends StatefulWidget {
  final bool soloMapa;
  final Map<String, dynamic>? datosIA;

  const MapaPuntosScreen({super.key, this.soloMapa = false, this.datosIA});

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
                    width: MapaPuntosStyles.markerWidth,
                    height: MapaPuntosStyles.markerHeight,
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
                          borderRadius: BorderRadius.circular(MapaPuntosStyles.markerRadius),
                          border: Border.all(color: Colors.white, width: MapaPuntosStyles.markerBorderWidth),
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

          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: MapaPuntosStyles.headerPadding,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: MapaPuntosStyles.backButtonSize,
                        height: MapaPuntosStyles.backButtonSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(MapaPuntosStyles.backButtonRadius),
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
                        padding: MapaPuntosStyles.searchPadding,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(MapaPuntosStyles.searchRadius),
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

          if (puntoSeleccionado != null)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                margin: MapaPuntosStyles.panelMargin,
                padding: MapaPuntosStyles.panelPadding,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(MapaPuntosStyles.panelRadius),
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

                    Container(
                      width: MapaPuntosStyles.handleWidth,
                      height: MapaPuntosStyles.handleHeight,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(MapaPuntosStyles.handleRadius),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Container(
                          width: MapaPuntosStyles.panelIconSize,
                          height: MapaPuntosStyles.panelIconSize,
                          decoration: BoxDecoration(
                            color: AppColors.green100,
                            borderRadius: BorderRadius.circular(MapaPuntosStyles.panelIconRadius),
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

                    if (!widget.soloMapa)
                      SizedBox(
                        width: double.infinity,
                        height: MapaPuntosStyles.buttonHeight,
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
