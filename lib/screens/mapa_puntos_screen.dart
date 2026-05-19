import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaPuntosScreen extends StatelessWidget {
  const MapaPuntosScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6EF),

      body: Column(
        children: [

          // HEADER VERDE
          Container(
            width: double.infinity,

            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 25,
            ),

            decoration: const BoxDecoration(
              color: Color(0xFF2D5A1B),

              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),

            child: const Text(
              'Puntos de reciclaje',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // MAPA
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(25),

                child: FlutterMap(

                  options: MapOptions(

                    initialCenter: LatLng(
                      2.4448,
                      -76.6147,
                    ),

                    initialZoom: 14,
                  ),

                  children: [

                    // MAPA BASE
                    TileLayer(

                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                      userAgentPackageName:
                          'com.example.app',
                    ),

                    // MARCADORES
                    MarkerLayer(

                      markers: [

                        // EXITO
                        Marker(
                          point: LatLng(
                            2.4448,
                            -76.6147,
                          ),

                          width: 80,
                          height: 80,

                          child: Column(
                            children: [

                              const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.white,

                                  borderRadius:
                                      BorderRadius.circular(
                                    12,
                                  ),
                                ),

                                child: const Text(
                                  'Éxito',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // OLIMPICA
                        Marker(
                          point: LatLng(
                            2.4465,
                            -76.6120,
                          ),

                          width: 80,
                          height: 80,

                          child: Column(
                            children: [

                              const Icon(
                                Icons.location_on,
                                color: Colors.green,
                                size: 40,
                              ),

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.white,

                                  borderRadius:
                                      BorderRadius.circular(
                                    12,
                                  ),
                                ),

                                child: const Text(
                                  'Olímpica',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}