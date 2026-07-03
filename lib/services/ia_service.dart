import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/materiales_data.dart';

class IaService {
  static Future<Map<String, dynamic>> escanear(String fotoPath) async {
    final url = Uri.parse(
      'https://backend-rp-arreglado-n8p8.onrender.com/api/detectar-material',
    );

    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('image', fotoPath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      String material = data['material'] ?? 'desconocido';
      int cantidad = data.containsKey('total_objetos') ? data['total_objetos'] : 1;
      String? fotoUrl = data['fotoUrl'] as String?;

      MaterialData base = MaterialData.fromClase(material);
      final materialData = base.copyWith(
        cantidadEstimada: "$cantidad unidad${cantidad > 1 ? 'es' : ''}",
        pesoAproximado: "${(cantidad * 0.3).toStringAsFixed(1)} kg",
      );

      return {
        'material': materialData,
        'fotoUrl': fotoUrl,
      };
    }

    return {
      'material': MaterialData.desconocido,
      'fotoUrl': null,
    };
  }
}