import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaPuntosScreen extends StatefulWidget {
  const MapaPuntosScreen({super.key});

  @override
  State<MapaPuntosScreen> createState() => _MapaPuntosScreenState();
}

class _MapaPuntosScreenState extends State<MapaPuntosScreen> {

  final List<Map<String, dynamic>> puntosReciclaje = [
    {
      'nombre': 'Éxito Panamericana',
      'direccion': 'Cra 9 #18N-230',
      'materiales': 'Plástico, cartón y vidrio',
      'ubicacion': LatLng(2.4570, -76.6009),
    },
    {
      'nombre': 'Carulla Campanario',
      'direccion': 'Centro Comercial Campanario',
      'materiales': 'Papel y plástico',
      'ubicacion': LatLng(2.4790, -76.5620),
    },
    {
      'nombre': 'Olímpica Popayán',
      'direccion': 'Calle 5',
      'materiales': 'Vidrio y cartón',
      'ubicacion': LatLng(2.4448, -76.6147),
    },
  ];

  Map<String, dynamic>? puntoSeleccionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puntos de reciclaje'),
      ),

      body: Stack(
        children: [

          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(2.4448, -76.6147),
              initialZoom: 13,
            ),

            children: [

              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),

              MarkerLayer(
                markers: puntosReciclaje.map((punto) {
                  return Marker(
                    point: punto['ubicacion'],
                    width: 80,
                    height: 80,

                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          puntoSeleccionado = punto;
                        });
                      },

                      child: const Icon(
                        Icons.location_on,
                        size: 40,
                        color: Colors.green,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          if (puntoSeleccionado != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,

              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      puntoSeleccionado!['nombre'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Dirección: ${puntoSeleccionado!['direccion']}',
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Materiales: ${puntoSeleccionado!['materiales']}',
                    ),

                    

                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          puntoSeleccionado = null;
                        });
                      },

                      child: const Text('Cerrar'),
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