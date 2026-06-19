import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../theme/app_theme.dart';
import 'mapa_puntos_screen.dart';
import 'chat_ia_screen.dart';

class ReciclarScreen extends StatefulWidget {
  const ReciclarScreen({super.key});

  @override
  State<ReciclarScreen> createState() => _ReciclarScreenState();
}

class _ReciclarScreenState extends State<ReciclarScreen> {
  bool _mostrarResultado = false;
  bool _estaCargando = false;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _camaraInicializada = false;
  String? _rutaImagenLocal;

  String _nombre = 'Detectando...';
  String _tipo = '';
  String _estado = 'Aprovechable';
  int _confianza = 0;
  String _caneco = 'Caneco Blanco';
  String _deposito = 'Aprovechable';
  String _descripcion = 'Vidrio, plástico, metal, papel y cartón.';
  String _cantidadEstimada = '';
  String _pesoAproximado = '';
  String _nivelReciclabilidad = '';
  String _recomendacionIA = '';
  Color _colorCaneca = Colors.white;

  @override
  void initState() {
    super.initState();
    _inicializarCamara();
  }

  bool _errorCamara = false;
  String _mensajeErrorCamara = '';

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
        if (mounted) setState(() {
          _errorCamara = true;
          _mensajeErrorCamara = 'No se encontró ninguna cámara en el dispositivo.';
        });
      }
    } catch (e) {
      debugPrint('Error cámara: $e');
      if (mounted) setState((){
        _errorCamara = true;
        _mensajeErrorCamara = 'Error al iniciar la cámara.\nAsegúrate de haber otorgado permisos de cámara en Ajustes > Aplicaciones > recycling_points > Permisos.\n\nError: $e';
       });
    }
  }

  // ── Datos quemados de entrega ──────────────────────────
  String _puntoEntrega = 'Éxito Panamericana';
  String _direccionEntrega = 'Cra 9 #18N-230, Popayán';
  String _horarioEntrega = 'Lun–Sáb 8:00–18:00';
  String _puntosEstimados = '150 pts';
  String _instruccionesEntrega = 'Entregar en el punto de reciclaje ubicado en el parqueadero.';

  Future<void> _escanear() async {
    setState(() {
      _estaCargando = true;
      _mostrarResultado = false;
    });

    await _inicializarCamara();

    try {
      final XFile foto = await _cameraController!.takePicture();
      setState(() => _rutaImagenLocal = foto.path);

      const ipServidor = '192.168.1.12';
      final url = Uri.parse('https://backend-rp-arreglado-n8p8.onrender.com/api/detectar-material');

      final request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('image', foto.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('=== IA Status: ${response.statusCode}');
      debugPrint('=== IA Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['detectado'] == true) {
          final resultado = data['resultado'];
          final String clase = resultado['objeto'];
          final double confianza = resultado['confianza'] * 100;

          setState(() {
            _confianza = confianza.round();
            _mostrarResultado = true;

            final String c = clase.toLowerCase();
            if (c == 'plastico') {
              _nombre = 'Plástico';
              _tipo = 'Residuo Aprovechable';
              _caneco = 'Caneco Blanco';
              _deposito = 'Aprovechable';
              _descripcion = 'Botellas, envases, bolsas, empaques.';
              _colorCaneca = const Color(0xFFF5F5F5);
              _cantidadEstimada = '1 unidad';
              _pesoAproximado = '0.3 kg';
              _nivelReciclabilidad = 'Alto';
              _recomendacionIA = 'Enjuaga y aplasta antes de depositar.';
            } else if (c == 'metal') {
              _nombre = 'Metal';
              _tipo = 'Residuo Aprovechable';
              _caneco = 'Caneco Blanco';
              _deposito = 'Aprovechable';
              _descripcion = 'Latas, tapas, envases metálicos.';
              _colorCaneca = const Color(0xFFF5F5F5);
              _cantidadEstimada = '1 unidad';
              _pesoAproximado = '0.3 kg';
              _nivelReciclabilidad = 'Alto';
              _recomendacionIA = 'Aplasta la lata para ahorrar espacio.';
            } else if (c == 'vidrio') {
              _nombre = 'Vidrio';
              _tipo = 'Residuo Aprovechable';
              _caneco = 'Caneco Blanco';
              _deposito = 'Aprovechable';
              _descripcion = 'Botellas, frascos, envases de vidrio.';
              _colorCaneca = const Color(0xFFF5F5F5);
              _cantidadEstimada = '1 unidad';
              _pesoAproximado = '0.8 kg';
              _nivelReciclabilidad = 'Alto';
              _recomendacionIA = 'Envuelve en papel antes de depositar.';
            } else if (c == 'carton') {
              _nombre = 'Cartón';
              _tipo = 'Residuo Aprovechable';
              _caneco = 'Caneco Blanco';
              _deposito = 'Aprovechable';
              _descripcion = 'Cajas, empaques de cartón, papel.';
              _colorCaneca = const Color(0xFFF5F5F5);
              _cantidadEstimada = '1 unidad';
              _pesoAproximado = '0.4 kg';
              _nivelReciclabilidad = 'Alto';
              _recomendacionIA = 'Dóblalo para que ocupe menos espacio.';
            } else {
              _nombre = c.isNotEmpty ? c : 'Desconocido';
              _tipo = 'Residuo No Aprovechable';
              _caneco = 'Caneco Negro';
              _deposito = 'No aprovechable';
              _descripcion = 'Papel higiénico, servilletas, cartones contaminados, papeles metalizados.';
              _colorCaneca = const Color(0xFF2E2E2E);
              _cantidadEstimada = '1 unidad';
              _pesoAproximado = '0.2 kg';
              _nivelReciclabilidad = 'Bajo';
              _recomendacionIA = 'Depositar en Caneco Negro. No apto para reciclaje.';
            }
            _estado = _deposito == 'Aprovechable' ? 'Aprovechable' : 'No clasificado';
          });
        } else {
          setState(() {
            _nombre = 'No identificado';
            _tipo = 'Objeto desconocido';
            _estado = 'No clasificado';
            _confianza = 0;
            _caneco = 'Caneco Negro';
            _deposito = 'No aprovechable';
            _descripcion = 'Papel higiénico, servilletas, cartones contaminados, papeles metalizados.';
            _colorCaneca = const Color(0xFF2E2E2E);
            _nivelReciclabilidad = 'Bajo';
            _recomendacionIA = 'Depositar en Caneco Negro. No apto para reciclaje.';
            _cantidadEstimada = '1 unidad';
            _pesoAproximado = '0.2 kg';
            _mostrarResultado = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión con el servidor: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  Map<String, dynamic> get _datosIA => {
        'material': _nombre,
        'tipo': _tipo,
        'estado': _estado,
        'confianza': _confianza,
        'caneco': _caneco,
        'deposito': _deposito,
        'descripcion': _descripcion,
        'cantidadEstimada': _cantidadEstimada,
        'pesoAproximado': _pesoAproximado,
        'nivelReciclabilidad': _nivelReciclabilidad,
        'recomendacionIA': _recomendacionIA,
        'colorCaneca': '#${_colorCaneca.value.toRadixString(16).padLeft(8, '0')}',
      };

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Color _nivelColor(String nivel) {
    switch (nivel) {
      case 'Alto': return const Color(0xFF3B6D11);
      case 'Medio': return Colors.orange;
      case 'Bajo': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _nivelBg(String nivel) {
    switch (nivel) {
      case 'Alto': return const Color(0xFFEAF3DE);
      case 'Medio': return const Color(0xFFFAEEDA);
      case 'Bajo': return const Color(0xFFFCEBEB);
      default: return Colors.grey[100]!;
    }
  }

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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      appBar: AppBar(
        title: const Text('Clasificar con IA'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Toma una foto del residuo',
                style: TextStyle(color: AppColors.textMid, fontSize: 13),
              ),
            ),

            // ── Visor cámara ──────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: 260,
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
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(_mensajeErrorCamara,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12)),
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
                      child: Image.file(
                        File(_rutaImagenLocal!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  else if (_camaraInicializada && _cameraController != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AspectRatio(
                        aspectRatio: _cameraController!.value.aspectRatio,
                        child: CameraPreview(_cameraController!),
                      ),
                    )
                  else
                    const Icon(Icons.camera_alt_outlined,
                        size: 56, color: Colors.black26),
                  if (!_errorCamara) const _ScannerFrame(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Resultado IA ───────────────────────────────
            if (_mostrarResultado) ...[

              _buildCard(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: _colorCaneca.computeLuminance() > 0.5
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFF2E2E2E).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _nombre == 'Plástico' ? Icons.local_drink :
                        _nombre == 'Metal' ? Icons.build :
                        _nombre == 'Vidrio' ? Icons.local_drink :
                        _nombre == 'Cartón' ? Icons.inventory_2_outlined :
                        Icons.help_outline,
                        color: _colorCaneca == const Color(0xFF2E2E2E)
                            ? const Color(0xFF2E2E2E)
                            : AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Material identificado',
                              style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                          const SizedBox(height: 2),
                          Text(_nombre,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark)),
                          Text(_tipo,
                              style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text('$_confianza%',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary)),
                        const Text('Confianza',
                            style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              _buildCard(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _datoColumna(Icons.inventory_2_outlined, 'Cantidad', _cantidadEstimada),
                    Container(width: 1, height: 40, color: Colors.grey[200]),
                    _datoColumna(Icons.monitor_weight_outlined, 'Peso aprox.', _pesoAproximado),
                    Container(width: 1, height: 40, color: Colors.grey[200]),
                    _datoColumna(Icons.recycling, 'Reciclabilidad', _nivelReciclabilidad,
                        valueColor: _nivelColor(_nivelReciclabilidad)),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              _buildCard(
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
                      child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Recomendación IA',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                          const SizedBox(height: 3),
                          Text(_recomendacionIA,
                              style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              _buildCard(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: _colorCaneca,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _colorCaneca.computeLuminance() > 0.5
                              ? Colors.grey.shade300
                              : Colors.transparent,
                        ),
                      ),
                      child: Icon(
                        _colorCaneca == const Color(0xFF2E2E2E)
                            ? Icons.delete_forever_outlined
                            : Icons.delete_outline,
                        color: _colorCaneca.computeLuminance() > 0.5
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
                                width: 12, height: 12,
                                decoration: BoxDecoration(
                                  color: _colorCaneca,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _colorCaneca.computeLuminance() > 0.5
                                        ? Colors.grey.shade300
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(_caneco,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(_deposito,
                              style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(_descripcion,
                              style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _nivelBg(_nivelReciclabilidad),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_nivelReciclabilidad,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _nivelColor(_nivelReciclabilidad))),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ── Información de entrega ─────────────────────
              _buildCard(
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
                                fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _entregaFila(Icons.store_rounded, 'Punto sugerido', _puntoEntrega),
                    const SizedBox(height: 8),
                    _entregaFila(Icons.location_on_outlined, 'Dirección', _direccionEntrega),
                    const SizedBox(height: 8),
                    _entregaFila(Icons.access_time_rounded, 'Horario', _horarioEntrega),
                    const SizedBox(height: 8),
                    _entregaFila(Icons.stars_rounded, 'Puntos estimados', _puntosEstimados,
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
                          const Icon(Icons.info_outline, size: 16, color: AppColors.textLight),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_instruccionesEntrega,
                                style: const TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.4)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],

            // ── Botón escanear ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton.icon(
                  onPressed: _estaCargando ? null : _escanear,
                  icon: const Icon(Icons.qr_code_scanner, size: 20),
                  label: Text(_estaCargando
                      ? 'Analizando...'
                      : (_mostrarResultado ? 'Escanear otro' : 'Escanear')),
                ),
              ),
            ),

            // ── Botón Reciclar ahora ──────────────────────
            if (_mostrarResultado)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity, height: 50,
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
                            datosIA: _datosIA,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _datoColumna(IconData icon, String label, String value, {Color? valueColor}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.textDark)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
        ],
      ),
    );
  }

  Widget _entregaFila(IconData icon, String label, String valor, {Color? valorColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
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

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            Positioned(top: 0, left: 0, child: _Esquina(top: true, left: true)),
            Positioned(top: 0, right: 0, child: _Esquina(top: true, left: false)),
            Positioned(bottom: 0, left: 0, child: _Esquina(top: false, left: true)),
            Positioned(bottom: 0, right: 0, child: _Esquina(top: false, left: false)),
          ],
        ),
      ),
    );
  }
}

class _Esquina extends StatelessWidget {
  final bool top, left;
  const _Esquina({required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 28),
      painter: _EsquinaPainter(top: top, left: left),
    );
  }
}

class _EsquinaPainter extends CustomPainter {
  final bool top, left;
  _EsquinaPainter({required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    final w = size.width;
    final h = size.height;
    const r = 6.0;
    if (top && left) {
      path.moveTo(0, h); path.lineTo(0, r); path.quadraticBezierTo(0, 0, r, 0); path.lineTo(w, 0);
    } else if (top && !left) {
      path.moveTo(0, 0); path.lineTo(w - r, 0); path.quadraticBezierTo(w, 0, w, r); path.lineTo(w, h);
    } else if (!top && left) {
      path.moveTo(0, 0); path.lineTo(0, h - r); path.quadraticBezierTo(0, h, r, h); path.lineTo(w, h);
    } else {
      path.moveTo(0, h); path.lineTo(w - r, h); path.quadraticBezierTo(w, h, w, h - r); path.lineTo(w, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
