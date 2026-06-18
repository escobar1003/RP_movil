import 'package:flutter/material.dart';
import '../models/recompensa_model.dart';
import '../services/usuario_service.dart';
import 'recompensa_detalle_screen.dart';

class RecompensasScreen extends StatefulWidget {
  const RecompensasScreen({super.key});

  @override
  State<RecompensasScreen> createState() => _RecompensasScreenState();
}

class _RecompensasScreenState extends State<RecompensasScreen> {
  List<RecompensaModel> _recompensas = [];
  bool _cargando = true;
  String? _error;
  int _puntosUsuario = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final res = await UsuarioService.getRecompensas();
      final lista = (res['recompensas'] as List?) ?? [];
      setState(() {
        _recompensas = lista.map((j) => RecompensaModel.fromJson(j)).toList();
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar recompensas: $e';
        _cargando = false;
      });
    }
    try {
      final pts = await UsuarioService.getResumenPuntos();
      _puntosUsuario = pts['saldo'] ?? 0;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6EF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_cargando)
              const Expanded(
                child: Center(child: CircularProgressIndicator(color: Color(0xFF2D5A1B))),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_off, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 16),
                        TextButton(onPressed: _cargarDatos, child: const Text('Reintentar')),
                      ],
                    ),
                  ),
                ),
              )
            else if (_recompensas.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No hay recompensas disponibles',
                      style: TextStyle(color: Colors.grey, fontSize: 15)),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _cargarDatos,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    itemCount: _recompensas.length,
                    itemBuilder: (context, index) =>
                        _buildCard(context, _recompensas[index]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

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
            'Aliados que reciclan contigo',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 13),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
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
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12),
                    ),
                    Text(
                      '${_puntosUsuario} pts',
                      style: const TextStyle(
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

  Widget _buildCard(BuildContext context, RecompensaModel recompensa) {
    final bool esProducto = recompensa.tipoRecompensa?.toLowerCase() == 'producto';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecompensaDetalleScreen(recompensa: recompensa),
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
                  esProducto ? Icons.card_giftcard : Icons.store_rounded,
                  color: const Color(0xFF2D5A1B), size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recompensa.aliado ?? recompensa.nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A0F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recompensa.descripcion ?? recompensa.nombre,
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
                            esProducto ? 'Producto' : (recompensa.tipoRecompensa ?? 'Descuento'),
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
                            '${recompensa.puntosRequeridos} pts',
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
              const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
            ],
          ),
        ),
      ),
    );
  }
}