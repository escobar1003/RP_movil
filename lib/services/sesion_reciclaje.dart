import '../data/materiales_data.dart';

class MaterialEscaneado {
  final MaterialData data;
  final String imagenPath;
  final String? fotoUrl;

  MaterialEscaneado({required this.data, required this.imagenPath, this.fotoUrl});

  Map<String, dynamic> toMap() => {
    'material': data.nombre,
    'tipo': data.tipo,
    'estado': data.estado,
    'confianza': 95,
    'caneco': data.caneco,
    'deposito': data.deposito,
    'descripcion': data.descripcion,
    'cantidadEstimada': data.cantidadEstimada,
    'pesoAproximado': data.pesoAproximado,
    'nivelReciclabilidad': data.nivelReciclabilidad,
    'recomendacionIA': data.recomendacionIA,//
    'colorCaneca': '#${data.colorCaneca.toARGB32().toRadixString(16).padLeft(8, '0')}',
    'imagenPath': imagenPath,
    'fotoUrl': fotoUrl,
  };
}

class SesionReciclaje {
  static final List<MaterialEscaneado> _materiales = [];

  static List<MaterialEscaneado> get materiales => List.unmodifiable(_materiales);

  static void agregar(MaterialEscaneado m) => _materiales.add(m);

  static void limpiar() => _materiales.clear();

  static int get cantidad => _materiales.length;

  static List<Map<String, dynamic>> get datosIA =>
      _materiales.map((m) => m.toMap()).toList();
}
