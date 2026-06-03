import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'db_helper.dart'; 
import 'minilm_tokenizer.dart';

class RagService {
  Interpreter? _interpreter;
  final MiniLMTokenizer _tokenizer = MiniLMTokenizer();

  Future<void> inicializar() async {
    try {
      await _tokenizer.inicializar();
      _interpreter = await Interpreter.fromAsset('assets/ml_models/minilm.tflite');
      debugPrint('✅ Motor RAG Offline (MiniLM + Vocab) cargado');
    } catch (e) {
      debugPrint('❌ Error cargando el motor RAG: $e');
    }
  }

  double _calcularSimilitud(List<double> a, List<double> b) {
    double productoPunto = 0.0;
    double normaA = 0.0;
    double normaB = 0.0;

    for (int i = 0; i < a.length; i++) {
      productoPunto += a[i] * b[i];
      normaA += a[i] * a[i];
      normaB += b[i] * b[i];
    }
    
    if (normaA == 0 || normaB == 0) return 0.0;
    return productoPunto / (sqrt(normaA) * sqrt(normaB));
  }

  Future<List<double>> generarVector(String texto) async {
    if (_interpreter == null) throw Exception('Modelo TFLite no inicializado');

    final tokens = _tokenizer.procesarTexto(texto);
    
    var inputIds = [tokens['input_ids']!];
    var attentionMask = [tokens['attention_mask']!];
    var tokenTypeIds = [List.filled(256, 0)];
    var inputs = [inputIds, attentionMask, tokenTypeIds];
    var output = List.filled(384, 0.0).reshape([1, 384]);

    _interpreter!.runForMultipleInputs(inputs, {0: output});

    return (output[0] as List).map((e) => e as double).toList();
  }
  Future<List<String>> buscarFragmentosRelevantes(String preguntaUsuario) async {
    final vectorPregunta = await generarVector(preguntaUsuario);

    final db = await DatabaseHelper.initDb();
  
    final List<Map<String, dynamic>> registros = await db.query('chunks'); 

    List<Map<String, dynamic>> resultados = [];

    for (var fila in registros) {
      List<dynamic> vectorDinamico = jsonDecode(fila['embedding_json']);
      List<double> vectorBD = vectorDinamico.map((e) => e as double).toList();

      double score = _calcularSimilitud(vectorPregunta, vectorBD);

      resultados.add({
        'texto': fila['content'], 
        'score': score,
      });
    }

    resultados.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    List<String> top3 = resultados.take(3).map((e) => e['texto'] as String).toList();
    
    return top3;
  }
}