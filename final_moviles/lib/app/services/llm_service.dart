import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LlmService extends GetxService {
  static const _baseUrl = 'http://192.168.1.204:3000/api/v1/emergency';
  static const _timeout = Duration(seconds: 45);

  final RxString errorMessage = ''.obs;

  final List<String> _historial = [];
  List<Map<String, dynamic>>? _offlineData;

  bool get isInitialized => true;

  Future<LlmService> init() async => this;

  void limpiarHistorial() => _historial.clear();

  Future<String?> consultar(String pregunta, {bool conHistorial = false}) async {
    try {
      final body = <String, dynamic>{'question': pregunta};
      if (conHistorial && _historial.isNotEmpty) {
        body['chat_history'] = _historial.join('\n');
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/consult'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) return _fallbackOffline(pregunta);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final answer = (data['answer'] as String? ?? '').trim();
      if (answer.isEmpty) return _fallbackOffline(pregunta);

      if (conHistorial) {
        _historial
          ..add('Human: $pregunta')
          ..add('AI: $answer');
        if (_historial.length > 20) _historial.removeRange(0, 2);
      }

      return answer;
    } on TimeoutException {
      return _fallbackOffline(pregunta);
    } catch (_) {
      return _fallbackOffline(pregunta);
    }
  }

  // ---------------------------------------------------------------------------
  // Fallback offline
  // ---------------------------------------------------------------------------

  Future<String> _fallbackOffline(String pregunta) async {
    // Normalizar: "herida abierta" → "herida_abierta"
    final clave = pregunta.toLowerCase().trim().replaceAll(' ', '_');

    final datos = await _cargarOffline();
    final entry = datos.cast<Map<String, dynamic>?>().firstWhere(
      (e) => e!['condicion'] == clave,
      orElse: () => null,
    );

    if (entry == null) {
      return '⚠️ Sin conexión al servidor.\n\n'
          'No hay información local disponible para "$pregunta".';
    }

    return _formatearOffline(entry);
  }

  Future<List<dynamic>> _cargarOffline() async {
    if (_offlineData != null) return _offlineData!;
    final raw = await rootBundle
        .loadString('assets/data/primeros_auxilios_offline.json');
    _offlineData = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return _offlineData!;
  }

  String _formatearOffline(Map<String, dynamic> e) {
    final pasos = (e['pasos'] as List).cast<String>();
    final advertencias = (e['advertencias'] as List).cast<String>();
    final emergencia = e['buscar_emergencia'] as String;
    final prioridad = e['prioridad'] as String;

    final sb = StringBuffer()
      ..writeln('**Prioridad: $prioridad**')
      ..writeln()
      ..writeln('**Pasos:**');
    for (var i = 0; i < pasos.length; i++) {
      sb.writeln('${i + 1}. ${pasos[i]}');
    }
    sb
      ..writeln()
      ..writeln('**No hacer:**');
    for (final a in advertencias) {
      sb.writeln('- $a');
    }
    sb
      ..writeln()
      ..writeln('**Busca atención médica si:**')
      ..writeln(emergencia)
      ..writeln()
      ..writeln('*— Información local (sin conexión) —*');

    return sb.toString().trim();
  }
}
