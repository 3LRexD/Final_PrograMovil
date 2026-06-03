import 'package:flutter/foundation.dart';

class GemmaService {
  // Aquí inicializarás tu modelo Gemma
  // Future<void> inicializar() async { ... }

  Future<String> generarRespuesta({
    required String pregunta,
    required List<String> fragmentosRelevantes,
  }) async {
    // 1. Armar el Contexto (Unir los 3 fragmentos en un solo texto)
    String contexto = fragmentosRelevantes.join('\n\n---\n\n');

    // 2. Construir el Prompt Final
    String promptFinal = '''
Eres un asistente médico de primeros auxilios experto y calmado.
Tu objetivo es responder la pregunta del usuario utilizando ÚNICAMENTE la información proporcionada en la sección "Contexto". 
Si la respuesta no se encuentra en el Contexto, debes decir: "No tengo información en el manual sobre eso, por favor acude a un centro médico."
No inventes información, no des consejos médicos fuera de este manual.

### Contexto:
$contexto

### Pregunta del Usuario:
$pregunta

### Respuesta:
''';

    debugPrint('Prompt generado para Gemma:\n$promptFinal');

    // 3. Enviar a Gemma (Aquí reemplazarás con el código de tu paquete)
    try {
      // Simulación de la respuesta de Gemma (mientras configuras tu paquete real)
      await Future.delayed(const Duration(seconds: 2)); 
      return "Respuesta simulada de Gemma basada en el contexto proporcionado.";
      
      // Ejemplo real con un paquete hipotético:
      // final respuesta = await miModeloGemma.generate(promptFinal);
      // return respuesta.text;
    } catch (e) {
      debugPrint('Error en Gemma: $e');
      return "Lo siento, hubo un problema al procesar la respuesta.";
    }
  }
}