// lib/models/recompensa_model.dart

class RecompensaModel {
  final String id;
  final String tienda;
  final String descripcion;
  final int descuentoPorcentaje; // ej: 10 → "10%"
  final int puntosRequeridos;
  final int disponibles;
  final String validoHasta;
  final List<String> condiciones;
  final String categoria; // 'descuento', 'producto', 'premio'

  const RecompensaModel({
    required this.id,
    required this.tienda,
    required this.descripcion,
    required this.descuentoPorcentaje,
    required this.puntosRequeridos,
    required this.disponibles,
    required this.validoHasta,
    required this.condiciones,
    required this.categoria,
  });
}