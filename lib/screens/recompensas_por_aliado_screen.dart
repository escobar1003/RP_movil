import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../models/aliado_model.dart';
import '../models/recompensa_model.dart';
import 'recompensa_detalle_screen.dart';

class RecompensasPorAliadoScreen extends StatelessWidget {
  final AliadoModel aliado;
  final List<RecompensaModel> recompensas;

  const RecompensasPorAliadoScreen({
    super.key,
    required this.aliado,
    required this.recompensas,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6EF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF2D5A1B),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: const Color(0xFF2D5A1B)),
                  Positioned(
                    right: 20, top: 40,
                    child: Icon(BootstrapIcons.gift,
                        size: 100,
                        color: Colors.white.withValues(alpha: 0.07)),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            BootstrapIcons.shop,
                            color: Color(0xFF2D5A1B), size: 40,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          aliado.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(BootstrapIcons.geo_alt, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          aliado.direccion,
                          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(BootstrapIcons.clock, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        aliado.horario,
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (recompensas.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(BootstrapIcons.gift, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('Este supermercado no tiene recompensas disponibles',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildRecompensaCard(context, recompensas[index]),
                  childCount: recompensas.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecompensaCard(BuildContext context, RecompensaModel r) {
    final bool esProducto = r.tipoRecompensa?.toLowerCase() == 'producto';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecompensaDetalleScreen(recompensa: r),
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  esProducto ? BootstrapIcons.gift : BootstrapIcons.percent,
                  color: const Color(0xFF2D5A1B), size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A0F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.descripcion ?? '',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF3DE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            esProducto ? 'Producto' : (r.tipoRecompensa ?? 'Descuento'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF3B6D11),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0E6B8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${r.puntosRequeridos} pts',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF854F0B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(BootstrapIcons.chevron_right, color: Color(0xFF9E9E9E)),
            ],
          ),
        ),
      ),
    );
  }
}
