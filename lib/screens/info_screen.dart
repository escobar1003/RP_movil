import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class InfoScreen extends StatelessWidget {
  final String titulo;
  final List<Map<String, String>> secciones;
  final bool mostrarBoton;

  const InfoScreen({
    super.key,
    required this.titulo,
    required this.secciones,
    this.mostrarBoton = false,
  });

  IconData _iconoParaTitulo(String t) {
    final title = t.toLowerCase();
    if (title.contains('aceptación') || title.contains('aceptacion')) return BootstrapIcons.file_text;
    if (title.contains('uso del servicio')) return BootstrapIcons.arrow_repeat;
    if (title.contains('cuenta')) return BootstrapIcons.person_badge;
    if (title.contains('puntos') || title.contains('recompensa')) return BootstrapIcons.star;
    if (title.contains('privacidad')) return BootstrapIcons.shield_lock;
    if (title.contains('almacenamiento')) return BootstrapIcons.cloud_upload;
    if (title.contains('derechos')) return BootstrapIcons.hand_index;
    if (title.contains('cambios') || title.contains('modificaciones')) return BootstrapIcons.arrow_counterclockwise;
    if (title.contains('información') || title.contains('recopilamos')) return BootstrapIcons.info_circle;
    if (title.contains('uso de la información')) return BootstrapIcons.gear;
    return BootstrapIcons.record_circle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(BootstrapIcons.recycle, color: Colors.white, size: 26),
            const SizedBox(width: 10),
            Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...secciones.asMap().entries.map((entry) {
              final s = entry.value;
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(_iconoParaTitulo(s['titulo']!), color: const Color(0xFF2E7D32), size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s['titulo']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF1B1B1B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(s['contenido']!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            if (mostrarBoton) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(BootstrapIcons.check2, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Acepto los términos y condiciones',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            Center(
              child: Text(
                '🌱 Gracias por contribuir a un mundo más sostenible ♻️',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
