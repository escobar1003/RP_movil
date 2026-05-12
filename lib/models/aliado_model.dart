// lib/models/aliado_model.dart

class AliadoModel {
  final String id;
  final String nombre;
  final String direccion;
  final String horario;
  final List<String> materiales;
  final String telefono;
  final String descripcion;

  const AliadoModel({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.horario,
    required this.materiales,
    required this.telefono,
    required this.descripcion,
  });
}