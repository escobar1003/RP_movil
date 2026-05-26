// lib/screens/reciclar_screen.dart

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
  String _descripcion = 'Vidrio, plástico, metal,\npapel y cartón.';

  @override
  void initState() {
    super.initState();
    _inicializarCamara();
  }

  Future<void> _inicializarCamara() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) setState(() => _camaraInicializada = true);
      }
    } catch (e) {
      debugPrint('Error cámara: $e');
    }
  }

  Future<void> _escanear() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized) return;

    setState(() {
      _estaCargando = true;
      _mostrarResultado = false;
    });

    try {
      final XFile foto = await _cameraController!.takePicture();
      setState(() => _rutaImagenLocal = foto.path);

      final String ipServidor = '192.168.100.8';
      final url = Uri.parse('http://$ipServidor:3333/api/detectar-material');

      final request = http.MultipartRequest('POST', url);
      request.files.add(
          await http.MultipartFile.fromPath('image', foto.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['detectado'] == true) {
          final resultado = data['resultado'];
          final String clase = resultado['objeto'];
          final double confianza = resultado['confianza'] * 100;

          setState(() {
            _confianza = confianza.round();
            _mostrarResultado = true;

            if (clase.toLowerCase().contains('botella') ||
                clase.toLowerCase().contains('plastic')) {
              _nombre = 'Botella de plástico';
              _tipo = 'Plástico (PET)';
              _estado = 'Aprovechable';
              _caneco = 'Caneco Blanco';
              _deposito = 'Aprovechable';
              _descripcion = 'Plásticos, vidrio, metal,\npapel y cartón.';
            } else if (clase.toLowerCase().contains('lata') ||
                clase.toLowerCase().contains('can')) {
              _nombre = 'Lata de Aluminio';
              _tipo = 'Metal';
              _estado = 'Aprovechable';
              _caneco = 'Caneco Blanco';
              _deposito = 'Aprovechable';
              _descripcion = 'Metales, plástico, vidrio,\npapel y cartón.';
            } else {
              _nombre = clase;
              _tipo = 'Residuo Identificado';
              _estado = 'Aprovechable';
              _caneco = 'Caneco Blanco';
              _deposito = 'Revisar Clasificación';
              _descripcion =
                  'Depositar en el contenedor limpio correspondiente.';
            }
          });
        } else {
          setState(() {
            _nombre = 'No identificado';
            _tipo = 'Objeto desconocido';
            _estado = 'No clasificado';
            _confianza = 0;
            _caneco = 'Caneco Negro';
            _deposito = 'No aprovechables';
            _descripcion =
                'Papel higiénico, servilletas,\ncartones contaminados.';
            _mostrarResultado = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error red: $e');
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
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
                  if (_estaCargando)
                    const CircularProgressIndicator(
                        color: AppColors.primary)
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

                  const _ScannerFrame(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Resultado ─────────────────────────────────
            if (_mostrarResultado) ...[

              _buildCard(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_drink,
                          color: Colors.teal),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.textDark,
                              )),
                          Text(_tipo,
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 13,
                              )),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.green100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(_estado,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                )),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text('$_confianza%',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            )),
                        const Text('Confianza',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textLight,
                            )),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _buildCard(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Depositar en:',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.textMid,
                        )),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.yellow100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.orange),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_caneco,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppColors.textDark,
                                  )),
                              Text(_deposito,
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 13,
                                  )),
                              Text(_descripcion,
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 12,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],

            // ── Botón escanear ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _estaCargando ? null : _escanear,
                  icon: const Icon(Icons.qr_code_scanner, size: 20),
                  label: Text(
                    _estaCargando
                        ? 'Analizando...'
                        : (_mostrarResultado
                            ? 'Escanear otro'
                            : 'Escanear'),
                  ),
                ),
              ),
            ),

            // ── Botón Reciclar ahora ──────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.map, size: 20),
                  label: const Text('Reciclar ahora'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MapaPuntosScreen(),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? margin}) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            Positioned(top: 0, left: 0,
                child: _Esquina(top: true, left: true)),
            Positioned(top: 0, right: 0,
                child: _Esquina(top: true, left: false)),
            Positioned(bottom: 0, left: 0,
                child: _Esquina(top: false, left: true)),
            Positioned(bottom: 0, right: 0,
                child: _Esquina(top: false, left: false)),
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
      path.moveTo(0, h);
      path.lineTo(0, r);
      path.quadraticBezierTo(0, 0, r, 0);
      path.lineTo(w, 0);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(w - r, 0);
      path.quadraticBezierTo(w, 0, w, r);
      path.lineTo(w, h);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, h - r);
      path.quadraticBezierTo(0, h, r, h);
      path.lineTo(w, h);
    } else {
      path.moveTo(0, h);
      path.lineTo(w - r, h);
      path.quadraticBezierTo(w, h, w, h - r);
      path.lineTo(w, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}