class RecompensaModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final int puntosRequeridos;
  final int? stock;
  final String? fechaInicio;
  final String? fechaFin;
  final String? tipoRecompensa;
  final String? aliado;

  const RecompensaModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.puntosRequeridos,
    this.stock,
    this.fechaInicio,
    this.fechaFin,
    this.tipoRecompensa,
    this.aliado,
  });

  factory RecompensaModel.fromJson(Map<String, dynamic> json) {
    return RecompensaModel(
      id: json['idRecompensa'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      puntosRequeridos: json['puntosRequeridos'] ?? 0,
      stock: json['stock'],
      fechaInicio: json['fechaInicio'],
      fechaFin: json['fechaFin'],
      tipoRecompensa: json['tipoRecompensa'],
      aliado: json['aliado'],
    );
  }
}