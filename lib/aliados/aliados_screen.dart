// lib/aliados/aliados_screen.dart

import 'package:flutter/material.dart';
import '../data/aliados_data.dart';
import '../models/aliado_model.dart';
import '../aliado_detalle/aliado_detalle_screen.dart';
import '../styles/colors.dart';
import 'aliados_style.dart';

class AliadosScreen extends StatelessWidget {
  const AliadosScreen({super.key});

  static const Map<String, Color> _materialColors = {
    'Plástico': MaterialColors.blue,
    'Cartón':   MaterialColors.amber,
    'Vidrio':   MaterialColors.teal,
    'Papel':    GreenColors.medium,
    'Metal':    MaterialColors.grey,
  };

  static const Map<String, Color> _materialBgColors = {
    'Plástico': MaterialBgColors.blue,
    'Cartón':   MaterialBgColors.amber,
    'Vidrio':   MaterialBgColors.teal,
    'Papel':    GreenColors.lightBg,
    'Metal':    MaterialBgColors.grey,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AliadosStyles.bg,
      appBar: AppBar(
        title: const Text(
          'Puntos de reciclaje',
          style: TextStyle(
            color: GreenColors.veryDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AliadosStyles.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: GreenColors.veryDark),
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

          Padding(
            padding: AliadosStyles.subtitlePadding,
            child: Text(
              '${aliadosEjemplo.length} supermercados aliados cerca de ti',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: AliadosStyles.listPadding,
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AliadoDetalleScreen(aliado: aliado),
          ),
        );
      },
      child: Container(
        margin: AliadosStyles.cardMargin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AliadosStyles.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: AliadosStyles.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [

                  Container(
                    width: AliadosStyles.logoSize,
                    height: AliadosStyles.logoSize,
                    decoration: BoxDecoration(
                      color: GreenColors.lightBg,
                      borderRadius: BorderRadius.circular(AliadosStyles.logoRadius),
                    ),
                    child: const Icon(
                      Icons.store_rounded,
                      color: GreenColors.medium,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aliado.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: GreenColors.veryDark,
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

                  Container(
                    width: AliadosStyles.arrowSize,
                    height: AliadosStyles.arrowSize,
                    decoration: BoxDecoration(
                      color: GreenColors.lightBg,
                      borderRadius: BorderRadius.circular(AliadosStyles.arrowRadius),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: GreenColors.medium,
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 14),

              Divider(color: Colors.grey.withOpacity(0.12), height: 1),
              const SizedBox(height: 12),

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

              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: aliado.materiales.map((m) {
                  final color = _materialColors[m] ?? Colors.grey;
                  final bg = _materialBgColors[m] ?? Colors.grey[100]!;
                  return Container(
                    padding: AliadosStyles.materialBadgePadding,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(AliadosStyles.materialBadgeRadius),
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
