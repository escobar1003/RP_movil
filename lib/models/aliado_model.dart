class AliadoModel {
  final int id;
  final String nombre;
  final String direccion;
  final String horario;
  final List<String> materiales;
  final String? telefono;
  final String? descripcion;
  final String? aliadoNombre;

  const AliadoModel({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.horario,
    required this.materiales,
    this.telefono,
    this.descripcion,
    this.aliadoNombre,
  });

  factory AliadoModel.fromJson(Map<String, dynamic> json) {
    final materialesRaw = json['materiales'] as List? ?? [];
    return AliadoModel(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      direccion: json['direccion'] ?? '',
      horario: json['horario'] ?? '',
      materiales: materialesRaw.map((m) {
        if (m is Map) return m['nombre']?.toString() ?? '';
        return m.toString();
      }).toList(),
      telefono: json['telefono']?.toString(),
      descripcion: json['descripcion']?.toString(),
      aliadoNombre: json['aliado'] is Map ? json['aliado']['nombre']?.toString() : null,
    );
  }
}