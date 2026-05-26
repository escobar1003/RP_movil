class RecompensaModel {
  final int id;
  final String tienda;
  final String descripcion;
  final int descuentoPorcentaje;
  final int puntosRequeridos;
  final int disponibles;
  final String validoHasta;
  final List<String> condiciones;
  final String categoria;

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

  factory RecompensaModel.fromJson(Map<String, dynamic> json) {
    return RecompensaModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      tienda: json['tienda'] ?? json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      descuentoPorcentaje: json['descuentoPorcentaje'] ?? json['descuento'] ?? 0,
      puntosRequeridos: json['puntosRequeridos'] ?? json['puntos'] ?? 0,
      disponibles: json['disponibles'] ?? json['stock'] ?? 0,
      validoHasta: json['validoHasta'] ?? json['validez'] ?? '',
      condiciones: json['condiciones'] is List ? List<String>.from(json['condiciones']) : [],
      categoria: json['categoria'] ?? 'descuento',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tienda': tienda,
    'descripcion': descripcion,
    'descuentoPorcentaje': descuentoPorcentaje,
    'puntosRequeridos': puntosRequeridos,
    'disponibles': disponibles,
    'validoHasta': validoHasta,
    'condiciones': condiciones,
    'categoria': categoria,
  };
}
