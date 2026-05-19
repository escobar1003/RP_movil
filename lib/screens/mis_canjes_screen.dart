import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// MODELO LOCAL
// ─────────────────────────────────────────────

enum EstadoCanje { valido, usado, vencido }

class _Canje {
  final String id;
  final String codigo;
  final String titulo;
  final String tienda;
  final Color colorTienda;
  final String tipoBadge; // 'pct' | 'cash' | 'producto'
  final String valorBadge; // '10%' | '$5.000' | ícono
  final EstadoCanje estado;
  final int puntosUsados;
  final String fecha;

  const _Canje({
    required this.id,
    required this.codigo,
    required this.titulo,
    required this.tienda,
    required this.colorTienda,
    required this.tipoBadge,
    required this.valorBadge,
    required this.estado,
    required this.puntosUsados,
    required this.fecha,
  });
}

// ─────────────────────────────────────────────
// DATOS DE PRUEBA
// ─────────────────────────────────────────────

const List<_Canje> _canjesData = [
  _Canje(
    id: '1',
    codigo: 'SUVR-8763',
    titulo: '10% de descuento en toda la tienda',
    tienda: 'SuperVerde',
    colorTienda: Color(0xFF2D5A1B),
    tipoBadge: 'pct',
    valorBadge: '10%',
    estado: EstadoCanje.usado,
    puntosUsados: 1000,
    fecha: 'Mayo 8, 2024',
  ),
  _Canje(
    id: '2',
    codigo: 'DESC-4567',
    titulo: 'Descuento en compras mayores a \$25.000',
    tienda: 'Éxito Centro',
    colorTienda: Color(0xFF185FA5),
    tipoBadge: 'cash',
    valorBadge: '\$5.000',
    estado: EstadoCanje.valido,
    puntosUsados: 1500,
    fecha: 'Mayo 3, 2024',
  ),
  _Canje(
    id: '3',
    codigo: 'BONO-2345-ABC',
    titulo: 'Bono \$10.000 para realizar en SuperMercar',
    tienda: 'SuperMercar',
    colorTienda: Color(0xFF854F0B),
    tipoBadge: 'cash',
    valorBadge: '\$10K',
    estado: EstadoCanje.valido,
    puntosUsados: 2000,
    fecha: 'Vence: Feb 15, 2025',
  ),
  _Canje(
    id: '4',
    codigo: 'GRATIS-789-XY35',
    titulo: 'Producto gratis — Botella 500ml',
    tienda: 'Jumbo Norte',
    colorTienda: Color(0xFF0F6E56),
    tipoBadge: 'producto',
    valorBadge: 'gratis',
    estado: EstadoCanje.vencido,
    puntosUsados: 900,
    fecha: 'Venció: Feb 15, 2024',
  ),
];

// ─────────────────────────────────────────────
// PANTALLA PRINCIPAL
// ─────────────────────────────────────────────

class MisCanjesScreen extends StatefulWidget {
  const MisCanjesScreen({super.key});

  @override
  State<MisCanjesScreen> createState() => _MisCanjesScreenState();
}

class _MisCanjesScreenState extends State<MisCanjesScreen> {
  // null = todos
  EstadoCanje? _filtroActivo;

  List<_Canje> get _canjesFiltrados {
    if (_filtroActivo == null) return _canjesData;
    return _canjesData.where((c) => c.estado == _filtroActivo).toList();
  }

  int get _puntosUsadosFiltrados =>
      _canjesFiltrados.fold(0, (sum, c) => sum + c.puntosUsados);

  @override
  Widget build(BuildContext context) {
    final canjes = _canjesFiltrados;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6EF),
      body: Column(
        children: [
          // ── Header blanco con filtros ──
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila título
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F6EF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: Color(0xFF2D5A1B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Mis canjes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chips de filtro
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: Row(
                      children: [
                        _FiltroChip(
                          label: 'Todos',
                          activo: _filtroActivo == null,
                          onTap: () =>
                              setState(() => _filtroActivo = null),
                        ),
                        const SizedBox(width: 8),
                        _FiltroChip(
                          label: 'Activos',
                          activo: _filtroActivo == EstadoCanje.valido,
                          onTap: () => setState(
                              () => _filtroActivo = EstadoCanje.valido),
                        ),
                        const SizedBox(width: 8),
                        _FiltroChip(
                          label: 'Usados',
                          activo: _filtroActivo == EstadoCanje.usado,
                          onTap: () => setState(
                              () => _filtroActivo = EstadoCanje.usado),
                        ),
                        const SizedBox(width: 8),
                        _FiltroChip(
                          label: 'Vencidos',
                          activo: _filtroActivo == EstadoCanje.vencido,
                          onTap: () => setState(
                              () => _filtroActivo = EstadoCanje.vencido),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Contenido scrollable ──
          Expanded(
            child: canjes.isEmpty
                ? _EstadoVacio(filtro: _filtroActivo)
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Tarjetas resumen
                      Row(
                        children: [
                          Expanded(
                            child: _TarjetaResumen(
                              label: 'Puntos usados',
                              valor: _formatPuntos(
                                  _puntosUsadosFiltrados),
                              sub: 'en canjes',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TarjetaResumen(
                              label: 'Total canjes',
                              valor: '${canjes.length}',
                              sub: 'histórico',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Lista de canjes
                      ...canjes.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _TarjetaCanje(canje: c),
                          )),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _formatPuntos(int pts) {
    if (pts >= 1000) {
      return '${(pts / 1000).toStringAsFixed(pts % 1000 == 0 ? 0 : 1)}K';
    }
    return '$pts';
  }
}

// ─────────────────────────────────────────────
// CHIP DE FILTRO
// ─────────────────────────────────────────────

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool activo;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? const Color(0xFF2D5A1B) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color:
                activo ? Colors.white : const Color(0xFF5F5E5A),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TARJETA RESUMEN (puntos / total)
// ─────────────────────────────────────────────

class _TarjetaResumen extends StatelessWidget {
  final String label;
  final String valor;
  final String sub;

  const _TarjetaResumen({
    required this.label,
    required this.valor,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EDE2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF888888),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D5A1B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TARJETA DE CANJE
// ─────────────────────────────────────────────

class _TarjetaCanje extends StatelessWidget {
  final _Canje canje;

  const _TarjetaCanje({required this.canje});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Fila principal
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Badge del tipo de descuento
                _BadgeDescuento(canje: canje),
                const SizedBox(width: 12),
                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        canje.titulo,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Tienda con mini logo
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: canje.colorTienda,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                canje.tienda[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            canje.tienda,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      // Pill de estado
                      _PillEstado(estado: canje.estado),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: canje.estado == EstadoCanje.vencido
                      ? const Color(0xFFDDDDDD)
                      : const Color(0xFFCCCCCC),
                  size: 20,
                ),
              ],
            ),
          ),
          // Footer con código y fecha
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 9),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFF0F0F0)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  canje.codigo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFAAAAAA),
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  canje.fecha,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFBBBBBB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BADGE DE TIPO DE DESCUENTO
// ─────────────────────────────────────────────

class _BadgeDescuento extends StatelessWidget {
  final _Canje canje;

  const _BadgeDescuento({required this.canje});

  @override
  Widget build(BuildContext context) {
    Color fondo;
    Color texto;
    Widget contenido;

    switch (canje.tipoBadge) {
      case 'pct':
        fondo = const Color(0xFFFAEEDA);
        texto = const Color(0xFF854F0B);
        contenido = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              canje.valorBadge,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: texto,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'descuento',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: texto,
              ),
            ),
          ],
        );
        break;

      case 'cash':
        fondo = const Color(0xFFE1F5EE);
        texto = const Color(0xFF0F6E56);
        contenido = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              canje.valorBadge,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: texto,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'bono',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: texto,
              ),
            ),
          ],
        );
        break;

      case 'producto':
      default:
        fondo = const Color(0xFFFCEBEB);
        texto = const Color(0xFFA32D2D);
        contenido = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard_rounded, color: texto, size: 22),
            const SizedBox(height: 2),
            Text(
              'gratis',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: texto,
              ),
            ),
          ],
        );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: contenido,
    );
  }
}

// ─────────────────────────────────────────────
// PILL DE ESTADO
// ─────────────────────────────────────────────

class _PillEstado extends StatelessWidget {
  final EstadoCanje estado;

  const _PillEstado({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color fondo;
    Color texto;
    String label;

    switch (estado) {
      case EstadoCanje.valido:
        fondo = const Color(0xFFE1F5EE);
        texto = const Color(0xFF0F6E56);
        label = 'Válido';
        break;
      case EstadoCanje.usado:
        fondo = const Color(0xFFF1EFE8);
        texto = const Color(0xFF5F5E5A);
        label = 'Usado';
        break;
      case EstadoCanje.vencido:
        fondo = const Color(0xFFFCEBEB);
        texto = const Color(0xFFA32D2D);
        label = 'Vencido';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: texto,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ESTADO VACÍO (sin resultados para el filtro)
// ─────────────────────────────────────────────

class _EstadoVacio extends StatelessWidget {
  final EstadoCanje? filtro;

  const _EstadoVacio({this.filtro});

  @override
  Widget build(BuildContext context) {
    String mensaje;
    IconData icono;

    switch (filtro) {
      case EstadoCanje.valido:
        mensaje = 'No tienes canjes activos';
        icono = Icons.confirmation_number_outlined;
        break;
      case EstadoCanje.usado:
        mensaje = 'Aún no has usado ningún canje';
        icono = Icons.history_rounded;
        break;
      case EstadoCanje.vencido:
        mensaje = 'No tienes canjes vencidos';
        icono = Icons.timer_off_outlined;
        break;
      default:
        mensaje = 'Aún no tienes canjes';
        icono = Icons.confirmation_number_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icono, color: const Color(0xFF2D5A1B), size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }
}