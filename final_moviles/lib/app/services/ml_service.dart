import 'dart:async';

import 'package:camera/camera.dart';
import 'package:get/get.dart';

//interfaz del servicio de ml
//implementacion real la conecta el equipo de ml
abstract class MlService {
  Future<MlResult> analizarFrame(XFile frame);
}

class MlResult {
  const MlResult({
    required this.titulo,
    required this.descripcion,
    this.confianza,
  });

  final String titulo;
  final String descripcion;
  final double? confianza;
}

//mock para probar la ui
class MockMlService extends GetxService implements MlService {
  static const _ejemplos = <MlResult>[
    MlResult(
      titulo: 'Posible quemadura leve',
      descripcion:
          'Enfría la zona con agua fría (no helada) durante 10-20 minutos. No apliques hielo ni cremas sin indicación médica.',
      confianza: 0.82,
    ),
    MlResult(
      titulo: 'Corte superficial detectado',
      descripcion:
          'Lava la herida con agua y jabón, aplica presión con gasa estéril para detener el sangrado y cubre con un vendaje limpio.',
      confianza: 0.74,
    ),
    MlResult(
      titulo: 'Ningún elemento crítico identificado',
      descripcion:
          'No se detecta una emergencia clara. Continúa observando o consulta el menú de instrucciones.',
      confianza: 0.45,
    ),
  ];

  int _i = 0;

  @override
  Future<MlResult> analizarFrame(XFile frame) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final res = _ejemplos[_i % _ejemplos.length];
    _i++;
    return res;
  }
}
