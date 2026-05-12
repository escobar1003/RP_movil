// lib/screens/recompensas_screen.dart

import 'package:flutter/material.dart';
import '../data/recompensas_data.dart';
import '../models/recompensa_model.dart';
import 'recompensa_detalle_screen.dart';

class RecompensasScreen extends StatefulWidget {
  const RecompensasScreen({super.key});

  @override
  State<RecompensasScreen> createState() => _RecompensasScreenState();
}

class _RecompensasScreenState extends State<RecompensasScreen>
    with SingleTickerProviderStateMixin {

  // ── TabController para los 3 tabs de categoría ──────────
  // SingleTickerProviderStateMixin es necesario para animaciones de tabs
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Filtra recompensas por categoría
  List<RecompensaModel> _filtradas(String categoria) {
    if (categoria == 'todos') return recompensasEjemplo;
    return recompensasEjemplo
        .where((r) => r.categoria == categoria)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6EF),
      body: SafeArea(
        child: Column(
          children: [

            // ── HEADER con puntos ──────────────────────────
            _buildHeader(),

            // ── TABS ───────────────────────────────────────
            _buildTabs(),

            // ── LISTA de recompensas ───────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLista(_filtradas('descuento')),
                  _buildLista(_filtradas('producto')),
                  _buildLista(_filtradas('premio')),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
            'Canjea tus puntos por grandes beneficios',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 20),

          // Tarjeta de saldo de puntos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [

                // Ícono de puntos
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7BC043),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.stars_rounded,
                      color: Colors.white, size: 24),
                ),

                const SizedBox(width: 14),

                // Puntos disponibles
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tus puntos disponibles',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 12,
                      ),
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

  // ── TABS ────────────────────────────────────────────────
  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        // Estilo del tab seleccionado
        indicator: BoxDecoration(
          color: const Color(0xFF2D5A1B),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Descuentos'),
          Tab(text: 'Productos'),
          Tab(text: 'Premios'),
        ],
      ),
    );
  }

  // ── LISTA de tarjetas ───────────────────────────────────
  Widget _buildLista(List<RecompensaModel> lista) {
    if (lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No hay recompensas\nen esta categoría',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: lista.length,
      itemBuilder: (context, index) => _buildCard(context, lista[index]),
    );
  }

  // ── TARJETA de recompensa ───────────────────────────────
  Widget _buildCard(BuildContext context, RecompensaModel r) {
    final bool esProducto = r.descuentoPorcentaje == 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecompensaDetalleScreen(recompensa: r),
        ),
      ),
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
            const Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [

              // ── Descuento grande a la izquierda ───────────
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: esProducto
                      ? const Icon(Icons.card_giftcard_outlined,
                          color: Color(0xFF3B6D11), size: 32)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${r.descuentoPorcentaje}%',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D5A1B),
                              ),
                            ),
                            Text(
                              'dscto',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(width: 14),

              // ── Info central ───────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Nombre de la tienda
                    Text(
                      r.tienda,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A0F),
                      ),
                    ),

                    const SizedBox(height: 3),

                    // Descripción
                    Text(
                      r.descripcion,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Puntos requeridos
                    Row(
                      children: [
                        const Icon(Icons.stars_rounded,
                            size: 14, color: Color(0xFF7BC043)),
                        const SizedBox(width: 4),
                        Text(
                          '${r.puntosRequeridos} puntos',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3B6D11),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ── Botón canjear ──────────────────────────────
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D5A1B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Canjear',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${r.disponibles} disp.',
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class _DetalleBottomSheet extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DetalleBottomSheet({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.green100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(data['logo'] as IconData, color: AppColors.primary, size: 40),
            ),
          ),
          const SizedBox(height: 20),
          Text(data['titulo']!,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(data['subtitulo']!,
              style: const TextStyle(color: AppColors.textMid, fontSize: 14)),
          const SizedBox(height: 12),
          Text(data['descripcion']!,
              style: const TextStyle(color: AppColors.textMid, fontSize: 14, height: 1.5)),
          const SizedBox(height: 8),
          Text('Disponible: ${data['disponibles']} unidades',
              style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Canjear · ${data['puntos']} puntos'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}