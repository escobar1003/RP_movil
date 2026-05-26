import 'package:flutter/material.dart';
import '../data/recompensas_data.dart';
import '../data/aliados_data.dart';
import '../models/recompensa_model.dart';
import '../models/aliado_model.dart';
import '../theme/app_theme.dart';
import 'recompensa_detalle_screen.dart';

class RecompensasScreen extends StatelessWidget {
  const RecompensasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6EF),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildRecompensasList(),
                    _buildAliadosList(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2D5A1B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recompensas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Canjea tus puntos por recompensas',
            style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7BC043),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.stars_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tus puntos disponibles',
                      style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12),
                    ),
                    const Text(
                      '2,560 pts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: const Color(0xFF2D5A1B),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF8F9B8A),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.card_giftcard_outlined, size: 16),
                SizedBox(width: 6),
                Text('Canjear'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_rounded, size: 16),
                SizedBox(width: 6),
                Text('Aliados'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB: Recompensas canjeables ──────────────────────────
  Widget _buildRecompensasList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: recompensasEjemplo.length,
      itemBuilder: (context, index) =>
          _buildRecompensaCard(context, recompensasEjemplo[index]),
    );
  }

  Widget _buildRecompensaCard(BuildContext context, RecompensaModel r) {
    final bool esProducto = r.descuentoPorcentaje == 0;

    return Container(
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecompensaDetalleScreen(recompensa: r),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Discount badge
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: esProducto
                        ? const Color(0xFFFEF3E2)
                        : const Color(0xFFEAF3DE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: esProducto
                        ? const Icon(Icons.card_giftcard,
                            color: Color(0xFF854F0B), size: 30)
                        : Text(
                            '${r.descuentoPorcentaje}%',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2D5A1B),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.tienda,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A0F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.descripcion,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7F66),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F7EB),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${r.puntosRequeridos} pts',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3B6D11),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: Color(0xFFB0BBA8), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── TAB: Supermercados aliados ───────────────────────────
  Widget _buildAliadosList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: aliadosEjemplo.length,
      itemBuilder: (context, index) =>
          _buildAliadoCard(context, aliadosEjemplo[index]),
    );
  }

  Widget _buildAliadoCard(BuildContext context, AliadoModel a) {
    return Container(
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
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.green100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.store_rounded,
                      color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A0F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: Color(0xFF8F9B8A)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              a.direccion,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7F66),
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
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 14, color: Color(0xFF8F9B8A)),
                const SizedBox(width: 4),
                Text(
                  a.horario,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7F66),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: a.materiales.map((m) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _materialColor(m).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    m,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _materialColor(m),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _materialColor(String material) {
    switch (material.toLowerCase()) {
      case 'plástico':
        return const Color(0xFF185FA5);
      case 'cartón':
        return const Color(0xFF854F0B);
      case 'vidrio':
        return const Color(0xFF2E7D32);
      case 'papel':
        return const Color(0xFF9E6A1E);
      case 'metal':
        return const Color(0xFF616161);
      default:
        return const Color(0xFF3B6D11);
    }
  }
}
