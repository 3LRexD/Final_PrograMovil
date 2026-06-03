import 'dart:convert';
import 'package:flutter/services.dart';

class MiniLMTokenizer {
  // El tamaño máximo que acepta el modelo MiniLM según Hugging Face
  static const int maxSeqLength = 256; 
  
  Map<String, int> _vocab = {};
  bool _isLoaded = false;

  // 1. Cargar el diccionario (vocab.txt) a la memoria
  Future<void> inicializar() async {
    if (_isLoaded) return;
    try {
      final vocabString = await rootBundle.loadString('assets/ml_models/vocab.txt');
      final lines = const LineSplitter().convert(vocabString);
      
      for (int i = 0; i < lines.length; i++) {
        final token = lines[i].trim();
        if (token.isNotEmpty) {
          _vocab[token] = i;
        }
      }
      _isLoaded = true;
    } catch (e) {
      throw Exception('Error cargando vocab.txt: $e');
    }
  }

  // 2. Convertir texto a números (Tokenización)
  Map<String, List<int>> procesarTexto(String texto) {
    if (!_isLoaded) throw Exception('El tokenizador no está inicializado');

    // Limpiar texto (minúsculas, quitar puntuación extra, etc.)
    String textoLimpio = texto.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    List<String> palabras = textoLimpio.split(RegExp(r'\s+'));

    List<int> inputIds = [];

    // Token [CLS] al inicio (ID 101 para modelos tipo BERT)
    inputIds.add(_vocab['[CLS]'] ?? 101);

    // Buscar cada palabra en el diccionario
    for (String palabra in palabras) {
      if (palabra.isEmpty) continue;
      
      // Si la palabra existe, agregamos su ID
      if (_vocab.containsKey(palabra)) {
        inputIds.add(_vocab[palabra]!);
      } else {
        // Si no existe (Unknown), agregamos [UNK] (ID 100)
        inputIds.add(_vocab['[UNK]'] ?? 100);
      }
    }

    // Token [SEP] al final (ID 102)
    inputIds.add(_vocab['[SEP]'] ?? 102);

    // Truncar si la frase es más larga del límite
    if (inputIds.length > maxSeqLength) {
      inputIds = inputIds.sublist(0, maxSeqLength);
      inputIds[maxSeqLength - 1] = _vocab['[SEP]'] ?? 102; // Asegurar el [SEP] final
    }

    // Crear la Attention Mask (1 para tokens reales)
    List<int> attentionMask = List.filled(inputIds.length, 1);

    // Padding (Rellenar con ceros hasta llegar a 256)
    while (inputIds.length < maxSeqLength) {
      inputIds.add(0);        // 0 es el token de Padding [PAD]
      attentionMask.add(0);   // 0 en la máscara para que el modelo lo ignore
    }

    return {
      'input_ids': inputIds,
      'attention_mask': attentionMask,
    };
  }
} 