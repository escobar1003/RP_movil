import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../models/aliado_model.dart';
import '../models/recompensa_model.dart';
import '../services/usuario_service.dart';
import 'recompensas_por_aliado_screen.dart';

class RecompensasScreen extends StatefulWidget {
  const RecompensasScreen({super.key});

  @override
  State<RecompensasScreen> createState() => _RecompensasScreenState();
}

class _RecompensasScreenState extends State<RecompensasScreen> {
  List<AliadoModel> _aliados = [];
  Map<String, List<RecompensaModel>> _recompensasPorAliado = {};
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final results = await Future.wait([
        UsuarioService.getAliados(),
        UsuarioService.getRecompensas(),
      ]);

      final resAliados = results[0];
      final resRecompensas = results[1];

      final listaAliados = (resAliados['aliados'] as List?) ?? [];
      final listaRecompensas = (resRecompensas['recompensas'] as List?) ?? [];

      final aliados = listaAliados.map((j) => AliadoModel.fromJson(j)).toList();
      final recompensas = listaRecompensas.map((j) => RecompensaModel.fromJson(j)).toList();

      final agrupadas = <String, List<RecompensaModel>>{};
      for (final r in recompensas) {
        final key = r.aliado ?? 'Otros';
        agrupadas.putIfAbsent(key, () => []).add(r);
      }

      setState(() {
        _aliados = aliados;
        _recompensasPorAliado = agrupadas;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar: $e';
        _cargando = false;
      });
    }
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
                        Icon(BootstrapIcons.cloud_slash, size: 48, color: Colors.grey[400]),
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
            else if (_aliados.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No hay supermercados disponibles',
                      style: TextStyle(color: Colors.grey, fontSize: 15)),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _cargarDatos,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    itemCount: _aliados.length,
                    itemBuilder: (context, index) =>
                        _buildAliadoCard(context, _aliados[index]),
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
            'Supermercados aliados y sus recompensas',
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
                  child: const Icon(BootstrapIcons.star_fill, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supermercados disponibles',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12),
                    ),
                    Text(
                      '${_aliados.length} aliados',
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

  Widget _buildAliadoCard(BuildContext context, AliadoModel aliado) {
    final recompensas = _recompensasPorAliado[aliado.nombre] ?? [];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecompensasPorAliadoScreen(
              aliado: aliado,
              recompensas: recompensas,
            ),
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
                child: const Icon(
                  BootstrapIcons.shop,
                  color: Color(0xFF2D5A1B), size: 30,
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
                        color: Color(0xFF1E3A0F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(BootstrapIcons.geo_alt,
                            size: 13, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            aliado.direccion,
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(BootstrapIcons.gift,
                            size: 13, color: const Color(0xFF7BC043)),
                        const SizedBox(width: 4),
                        Text(
                          '${recompensas.length} recompensas',
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
              const Icon(BootstrapIcons.chevron_right, color: Color(0xFF9E9E9E)),
            ],
          ),
        ),
      ),
    );
  }
}
