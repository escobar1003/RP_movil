import 'package:flutter/material.dart';
import '../models/aliado_model.dart';
import '../services/usuario_service.dart';
import 'aliado_detalle_screen.dart';

class AliadosScreen extends StatefulWidget {
  const AliadosScreen({super.key});

  @override
  State<AliadosScreen> createState() => _AliadosScreenState();
}

class _AliadosScreenState extends State<AliadosScreen> {
  List<AliadoModel> _aliados = [];
  bool _cargando = true;
  String? _error;

  static const Map<String, Color> _materialColors = {
    'Plástico': Color(0xFF185FA5),
    'Cartón':   Color(0xFF854F0B),
    'Vidrio':   Color(0xFF0F6E56),
    'Papel':    Color(0xFF3B6D11),
    'Metal':    Color(0xFF5F5E5A),
  };

  static const Map<String, Color> _materialBgColors = {
    'Plástico': Color(0xFFE6F1FB),
    'Cartón':   Color(0xFFFAEEDA),
    'Vidrio':   Color(0xFFE1F5EE),
    'Papel':    Color(0xFFEAF3DE),
    'Metal':    Color(0xFFF1EFE8),
  };

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final res = await UsuarioService.getAliados();
      final lista = (res['aliados'] as List?) ?? [];
      setState(() {
        _aliados = lista.map((j) => AliadoModel.fromJson(j)).toList();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2D5A1B)),
      );
    }
    if (_error != null) {
      return Center(
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
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Text(
            '${_aliados.length} supermercados aliados cerca de ti',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _cargarDatos,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _aliados.length,
              itemBuilder: (context, index) {
                return _buildAliadoCard(context, _aliados[index]);
              },
            ),
          ),
        ),
      ],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
              Divider(color: Colors.grey.withValues(alpha: 0.12), height: 1),
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