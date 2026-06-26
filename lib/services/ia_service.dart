import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/materiales_data.dart';

class IaService {
  static Future<MaterialData> escanear(String fotoPath) async {
    final url = Uri.parse(
      'https://backend-rp-arreglado-n8p8.onrender.com/api/detectar-material',
    );

    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('image', fotoPath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // 1. Extraemos el material principal
      String material = data['material'] ?? 'desconocido';

      // 2. Extraemos la cantidad (si no viene en el JSON, por defecto 1)
      int cantidad = data.containsKey('total_objetos')
          ? data['total_objetos']
          : 1;

      // 3. Obtenemos el objeto base desde tu mapa de materiales
      MaterialData base = MaterialData.fromClase(material);

      // 4. Usamos copyWith para actualizar los valores de forma segura sin romper la inmutabilidad
      // Nota: Asegúrate que tu copyWith en materiales_data.dart acepte estos parámetros
      return base.copyWith(
        cantidadEstimada: "$cantidad unidad${cantidad > 1 ? 'es' : ''}",
        pesoAproximado: "${(cantidad * 0.3).toStringAsFixed(1)} kg",
      );
    }
    return MaterialData.desconocido;
  }
}
