import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaPuntosScreen extends StatefulWidget {
  const MapaPuntosScreen({super.key});

  @override
  State<MapaPuntosScreen> createState() => _MapaPuntosScreenState();
}
class _MapaPuntosScreenState extends State<MapaPuntosScreen> {  

 // 📍 Coordenadas de Popayán
  final LatLng popayan = LatLng(2.4448, -76.6147);

  // 🏪 Lista de supermercados simulados
  final List<Map<String, dynamic>> supermercados = [

    {
      'nombre': 'Éxito Panamericana',
      'direccion': 'Cra 9 #25N-08',
      'materiales': ['Plástico', 'Cartón', 'Vidrio'],
      'ubicacion': LatLng(2.4570, -76.6000),
    },

    {
      'nombre': 'Carulla Campanario',
      'direccion': 'Centro Comercial Campanario',
      'materiales': ['Metal', 'Papel', 'Plástico'],
      'ubicacion': LatLng(2.4700, -76.5920),
    },

    {
      'nombre': 'Ara Centro',
      'direccion': 'Centro de Popayán',
      'materiales': ['Vidrio', 'Cartón'],
      'ubicacion': LatLng(2.4420, -76.6060),
    },

  ];

  // 🟢 Supermercado seleccionado
  Map<String, dynamic>? supermercadoSeleccionado;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF4F6EF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2D5A1B),
        foregroundColor: Colors.white,
        title: const Text('Puntos de reciclaje'),
      ),

      body: Stack(

        children: [

          // ───────── MAPA ─────────
          FlutterMap(

            options: MapOptions(
              initialCenter: popayan,
              initialZoom: 13,
            ),

            children: [

              // 🌎 MAPA OPENSTREETMAP
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.recycling_points',
              ),

              // 📍 MARCADORES
              MarkerLayer(

                markers: supermercados.map((supermercado) {

                  return Marker(

                    point: supermercado['ubicacion'],

                    width: 80,
                    height: 80,

                    child: GestureDetector(

                      onTap: () {

                        setState(() {

                          supermercadoSeleccionado = supermercado;

                        });

                      },

                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF2D5A1B),
                        size: 42,
                      ),
                    ),
                  );

                }).toList(),
              ),
            ],
          ),
           // ───────── CARD INFERIOR ─────────
          if (supermercadoSeleccionado != null)

            Align(

              alignment: Alignment.bottomCenter,

              child: Container(

                margin: const EdgeInsets.all(16),

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                    ),
                  ],
                ),

                child: Column(

                  mainAxisSize: MainAxisSize.min,

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(
                      supermercadoSeleccionado!['nombre'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A0F),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      supermercadoSeleccionado!['direccion'],
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Materiales aceptados',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Wrap(

                      spacing: 8,

                      children:
                          (supermercadoSeleccionado!['materiales']
                                  as List<String>)
                              .map(
                                (material) => Container(

                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),

                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF3DE),
                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: Text(
                                    material,
                                    style: const TextStyle(
                                      color: Color(0xFF2D5A1B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(

                      width: double.infinity,

                      height: 50,

                      child: ElevatedButton(

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D5A1B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),

                        onPressed: () {

                          ScaffoldMessenger.of(context).showSnackBar(

                            SnackBar(
                              content: Text(
                                'Reciclaje en ${supermercadoSeleccionado!['nombre']}',
                              ),
                            ),
                          );
                        },

                        child: const Text(
                          'Reciclar aquí',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
