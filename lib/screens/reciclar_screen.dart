import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../data/materiales_data.dart';
import '../services/ia_service.dart';
import '../services/sesion_reciclaje.dart';
import '../widgets/scanner_frame.dart';
import 'mapa_puntos_screen.dart';
import 'chat_ia_screen.dart';

class ReciclarScreen extends StatefulWidget {
  final bool modoAgregar;

  const ReciclarScreen({super.key, this.modoAgregar = false});

  @override
  State<ReciclarScreen> createState() => _ReciclarScreenState();
}

class _ReciclarScreenState extends State<ReciclarScreen> {
  bool _mostrarResultado = false;
  bool _estaCargando = false;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _camaraInicializada = false;
  bool _errorCamara = false;
  String _mensajeErrorCamara = '';
  String? _rutaImagenLocal;

  MaterialData? _material;

  // Datos de entrega (quemados)
  final String _puntoEntrega = 'Éxito Panamericana';
  final String _direccionEntrega = 'Cra 9 #18N-230, Popayán';
  final String _horarioEntrega = 'Lun–Sáb 8:00–18:00';
  final String _puntosEstimados = '150 pts';
  final String _instruccionesEntrega =
      'Entregar en el punto de reciclaje ubicado en el parqueadero.';

  @override
  void initState() {
    super.initState();
    if (!widget.modoAgregar) SesionReciclaje.limpiar();
    _inicializarCamara();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _inicializarCamara() async {
    try {
      _errorCamara = false;
      _mensajeErrorCamara = '';
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) setState(() => _camaraInicializada = true);
      } else {
        if (mounted) {
          setState(() {
            _errorCamara = true;
            _mensajeErrorCamara =
                'No se encontró ninguna cámara en el dispositivo.';
          });
        }
      }
    } catch (e) {
      debugPrint('Error cámara: $e');
      if (mounted) {
        setState(() {
          _errorCamara = true;
          _mensajeErrorCamara =
              'Error al iniciar la cámara.\nAsegúrate de haber otorgado permisos de cámara en Ajustes > Aplicaciones > recycling_points > Permisos.\n\nError: $e';
        });
      }
    }
  }

  Future<void> _escanear() async {
    setState(() {
      _estaCargando = true;
      _mostrarResultado = false;
    });

    await _inicializarCamara();

    try {
      final foto = await _cameraController!.takePicture();
      _rutaImagenLocal = foto.path;

      final material = await IaService.escanear(foto.path);
      if (mounted) {
        SesionReciclaje.agregar(MaterialEscaneado(
          data: material,
          imagenPath: foto.path,
        ));
        if (widget.modoAgregar) {
          Navigator.pop(context, true);
          return;
        }
        setState(() {
          _material = material;
          _rutaImagenLocal = foto.path;
          _mostrarResultado = true;
          _estaCargando = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión con el servidor: $e')),
        );
        setState(() => _estaCargando = false);
      }
    }
  }

  Map<String, dynamic> get _datosIA => {
    'material': _material?.nombre ?? '',
    'tipo': _material?.tipo ?? '',
    'estado': _material?.estado ?? '',
    'confianza': 95,
    'caneco': _material?.caneco ?? '',
    'deposito': _material?.deposito ?? '',
    'descripcion': _material?.descripcion ?? '',
    'cantidadEstimada': _material?.cantidadEstimada ?? '',
    'pesoAproximado': _material?.pesoAproximado ?? '',
    'nivelReciclabilidad': _material?.nivelReciclabilidad ?? '',
    'recomendacionIA': _material?.recomendacionIA ?? '',
    'colorCaneca':
        '#${_material?.colorCaneca.toARGB32().toRadixString(16).padLeft(8, '0')}',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        elevation: 6,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatIaScreen()),
        ),
        icon: const Icon(Icons.chat_bubble_outline_rounded,
            color: Colors.white, size: 22),
        label: const Text('Chat IA',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      appBar: AppBar(
        title: const Text('Clasificar con IA'),
        actions: [
          if (SesionReciclaje.cantidad > 0)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${SesionReciclaje.cantidad}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text('Toma una foto del residuo',
                  style: TextStyle(color: AppColors.textMid, fontSize: 13)),
            ),
            _buildCamaraVisor(),
            const SizedBox(height: 16),
            if (_mostrarResultado && _material != null) ...[
              _buildMaterialCard(),
              const SizedBox(height: 10),
              _buildDetallesCard(),
              const SizedBox(height: 10),
              _buildRecomendacionCard(),
              const SizedBox(height: 10),
              _buildCanecoCard(),
              const SizedBox(height: 10),
              _buildEntregaCard(),
              const SizedBox(height: 20),
            ],
            _buildBotonEscanear(),
            if (_mostrarResultado) _buildBotonReciclar(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCamaraVisor() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 420,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_errorCamara)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(_mensajeErrorCamara,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _camaraInicializada = false);
                      _inicializarCamara();
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          else if (_estaCargando)
            const CircularProgressIndicator(color: AppColors.primary)
          else if (_mostrarResultado && _rutaImagenLocal != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(File(_rutaImagenLocal!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity),
            )
          else if (_camaraInicializada && _cameraController != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CameraPreview(_cameraController!),
            )
          else
            const Icon(Icons.camera_alt_outlined, size: 56, color: Colors.black26),
          if (!_errorCamara) const ScannerFrame(),
        ],
      ),
    );
  }

  Widget _buildMaterialCard() {
    final m = _material!;
    final icon = switch (m.nombre) {
      'Plástico' => Icons.local_drink,
      'Metal' => Icons.build,
      'Vidrio' => Icons.local_drink,
      'Cartón' => Icons.inventory_2_outlined,
      _ => Icons.help_outline,
    };
    return _buildCard(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: m.colorCaneca.computeLuminance() > 0.5
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFF2E2E2E).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon,
                color: m.colorCaneca == const Color(0xFF2E2E2E)
                    ? const Color(0xFF2E2E2E)
                    : AppColors.primary,
                size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Material identificado',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textLight)),
                const SizedBox(height: 2),
                Text(m.nombre,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textDark)),
                Text(m.tipo,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
          Column(
            children: [
              const Text('95%',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary)),
              const Text('Confianza',
                  style: TextStyle(fontSize: 10, color: AppColors.textLight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetallesCard() {
    final m = _material!;
    return _buildCard(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _datoColumna(
              Icons.inventory_2_outlined, 'Cantidad', m.cantidadEstimada),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _datoColumna(
              Icons.monitor_weight_outlined, 'Peso aprox.', m.pesoAproximado),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _datoColumna(Icons.recycling, 'Reciclabilidad', m.nivelReciclabilidad,
              valueColor: MaterialData.nivelColor(m.nivelReciclabilidad)),
        ],
      ),
    );
  }

  Widget _buildRecomendacionCard() {
    return _buildCard(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Recomendación IA',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                const SizedBox(height: 3),
                Text(_material!.recomendacionIA,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textLight,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanecoCard() {
    final m = _material!;
    return _buildCard(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: m.colorCaneca,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: m.colorCaneca.computeLuminance() > 0.5
                    ? Colors.grey.shade300
                    : Colors.transparent,
              ),
            ),
            child: Icon(
              m.colorCaneca == const Color(0xFF2E2E2E)
                  ? Icons.delete_forever_outlined
                  : Icons.delete_outline,
              color: m.colorCaneca.computeLuminance() > 0.5
                  ? Colors.grey.shade700
                  : Colors.white70,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: m.colorCaneca,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: m.colorCaneca.computeLuminance() > 0.5
                              ? Colors.grey.shade300
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(m.caneco,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textDark)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(m.deposito,
                    style: const TextStyle(
                        color: AppColors.textLight, fontSize: 13)),
                const SizedBox(height: 2),
                Text(m.descripcion,
                    style: TextStyle(color: Colors.grey[400], fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: MaterialData.nivelBg(m.nivelReciclabilidad),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              m.nivelReciclabilidad,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: MaterialData.nivelColor(m.nivelReciclabilidad),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntregaCard() {
    return _buildCard(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F0FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_shipping_outlined,
                    color: Color(0xFF185FA5), size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Información de entrega',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 12),
          _entregaFila(Icons.store_rounded, 'Punto sugerido', _puntoEntrega),
          const SizedBox(height: 8),
          _entregaFila(
              Icons.location_on_outlined, 'Dirección', _direccionEntrega),
          const SizedBox(height: 8),
          _entregaFila(Icons.access_time_rounded, 'Horario', _horarioEntrega),
          const SizedBox(height: 8),
          _entregaFila(Icons.stars_rounded, 'Puntos estimados',
              _puntosEstimados,
              valorColor: const Color(0xFF854F0B)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    size: 16, color: AppColors.textLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_instruccionesEntrega,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                          height: 1.4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonEscanear() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _estaCargando ? null : _escanear,
          icon: const Icon(Icons.qr_code_scanner, size: 20),
          label: Text(_estaCargando
              ? 'Analizando...'
              : (_mostrarResultado ? 'Escanear otro' : 'Escanear')),
        ),
      ),
    );
  }

  Widget _buildBotonReciclar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.map, size: 20),
          label: const Text('Reciclar ahora'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MapaPuntosScreen(
                  soloMapa: false,
                  datosIA: SesionReciclaje.datosIA.isNotEmpty
                      ? SesionReciclaje.datosIA.first
                      : _datosIA,
                  materialesIA: SesionReciclaje.datosIA,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _datoColumna(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColors.textDark)),
          Text(label,
              style:
                  const TextStyle(fontSize: 10, color: AppColors.textLight)),
        ],
      ),
    );
  }

  Widget _entregaFila(IconData icon, String label, String valor,
      {Color? valorColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const SizedBox(width: 8),
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textLight)),
        const Spacer(),
        Text(valor,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valorColor ?? AppColors.textDark)),
      ],
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? margin}) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
