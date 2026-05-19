// lib/screens/aliados_screen.dart

import 'package:flutter/material.dart';
import '../data/aliados_data.dart';
import '../models/aliado_model.dart';
import 'aliado_detalle_screen.dart';

class AliadosScreen extends StatelessWidget {
  const AliadosScreen({super.key});

  // Mapa de colores por material para los badges
  // Cada material tiene su propio color para identificarlo visualmente
  static const Map<String, Color> _materialColors = {
    'Plástico': Color(0xFF185FA5),  // azul
    'Cartón':   Color(0xFF854F0B),  // ámbar
    'Vidrio':   Color(0xFF0F6E56),  // teal
    'Papel':    Color(0xFF3B6D11),  // verde
    'Metal':    Color(0xFF5F5E5A),  // gris
  };

  static const Map<String, Color> _materialBgColors = {
    'Plástico': Color(0xFFE6F1FB),
    'Cartón':   Color(0xFFFAEEDA),
    'Vidrio':   Color(0xFFE1F5EE),
    'Papel':    Color(0xFFEAF3DE),
    'Metal':    Color(0xFFF1EFE8),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6EF),
      appBar: AppBar(
        title: const Text(
          'Puntos de reciclaje',
          style: TextStyle(
            color: Color(0xFF1E3A0F),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFFF4F6EF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A0F)),
        // Buscador en el AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: implementar búsqueda
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Subtitle ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              '${aliadosEjemplo.length} supermercados aliados cerca de ti',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),

          // ── Lista de aliados ──────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: aliadosEjemplo.length,
              itemBuilder: (context, index) {
                return _buildAliadoCard(context, aliadosEjemplo[index]);
              },
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildAliadoCard(BuildContext context, AliadoModel aliado) {
    return GestureDetector(
      onTap: () {
        // Navegar al detalle pasando el aliado completo
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AliadoDetalleScreen(aliado: aliado),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Fila superior: logo + nombre + flecha ──────
              Row(
                children: [

                  // Logo/avatar del supermercado
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3DE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.store_rounded,
                      color: Color(0xFF3B6D11),
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Nombre y dirección
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aliado.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A0F),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 13, color: Colors.grey[500]),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                aliado.direccion,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Flecha
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3DE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Color(0xFF3B6D11),
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 14),

              // ── Divider ────────────────────────────────────
              Divider(color: Colors.grey.withOpacity(0.12), height: 1),
              const SizedBox(height: 12),

              // ── Horario ────────────────────────────────────
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    aliado.horario,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Badges de materiales ────────────────────────
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: aliado.materiales.map((m) {
                  final color = _materialColors[m] ?? Colors.grey;
                  final bg = _materialBgColors[m] ?? Colors.grey[100]!;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      m,
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),

            ],
          ),
        ),
      ),
    );
  }
}