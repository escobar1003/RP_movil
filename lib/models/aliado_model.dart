class AliadoModel {
  final int id;
  final String nombre;
  final String direccion;
  final String horario;
  final List<String> materiales;
  final String telefono;
  final String descripcion;
  final double? latitud;
  final double? longitud;

  const AliadoModel({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.horario,
    required this.materiales,
    required this.telefono,
    required this.descripcion,
    this.latitud,
    this.longitud,
  });

  factory AliadoModel.fromJson(Map<String, dynamic> json) {
    return AliadoModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nombre: json['nombre'] ?? '',
      direccion: json['direccion'] ?? json['dirección'] ?? '',
      horario: json['horario'] ?? '',
      materiales: json['materiales'] is List ? List<String>.from(json['materiales']) : [],
      telefono: json['telefono'] ?? json['teléfono'] ?? '',
      descripcion: json['descripcion'] ?? json['descripción'] ?? '',
      latitud: json['latitud'] != null ? double.tryParse(json['latitud'].toString()) : null,
      longitud: json['longitud'] != null ? double.tryParse(json['longitud'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'direccion': direccion,
    'horario': horario,
    'materiales': materiales,
    'telefono': telefono,
    'descripcion': descripcion,
    'latitud': latitud,
    'longitud': longitud,
  };
}
