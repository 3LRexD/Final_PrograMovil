import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ATENCIÓN: Cambia esta IP por la IP local de tu computadora (IPv4)
  // en la red Wi-Fi (ej. 192.168.1.50) si vas a probar en un dispositivo físico.
  // Si usas el emulador de Android, usa '10.0.2.2'.
  static const String baseUrl = 'http://192.168.1.204:3000/api/v1/emergency';

  /// Llama al backend de Python para buscar en los manuales en PDF (RAG)
  /// y devuelve los fragmentos de texto relevantes como un solo String.
  static Future<String?> obtenerContexto(String pregunta) async {
    try {
      print('Buscando contexto RAG en el backend...');
      final response = await http.post(
        Uri.parse('$baseUrl/retrieve_context'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': pregunta}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final contextList = data['context'] as List<dynamic>;
        
        if (contextList.isEmpty) return null;

        // Juntar todo el contenido recuperado
        return contextList
            .map((item) => "Fuente: ${item['source_file']}\nContenido: ${item['content']}")
            .join('\n\n');
      } else {
        print('Error en RAG Backend: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Excepción al conectar con RAG Backend: $e');
      return null;
    }
  }
}
