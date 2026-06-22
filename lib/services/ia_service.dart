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
      if (data.containsKey('material')) {
        return MaterialData.fromClase(data['material'] as String);
      }
    }
    return MaterialData.desconocido;
  }
}
