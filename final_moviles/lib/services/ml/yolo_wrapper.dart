//envoltorio para el modelo yolo v8
//este es un stub de prueba no carga el modelo real

import 'dart:typed_data';
import 'package:get/get.dart';

//formato de deteccion del modelo
class YoloDetection {
  final String clase;
  final double confianza;
  final Rect boundingBox;

  YoloDetection({
    required this.clase,
    required this.confianza,
    required this.boundingBox,
  });
}

class Rect {
  final double x;
  final double y;
  final double ancho;
  final double alto;

  Rect({
    required this.x,
    required this.y,
    required this.ancho,
    required this.alto,
  });
}

//servicio wrapper del modelo
class YoloWrapper extends GetxService {
  //metadata del modelo
  static const String modelVersion = '1.0.0';
  static const String modelName = 'YOLOv8-FirstAid-Detector';
  static const int inputSize = 640;
  static const double confidenceThreshold = 0.45;

  static const List<String> clases = [
    'cortadura',
    'quemadura',
    'hematoma',
    'inflamacion',
    'sangrado',
    'fractura_sospechada',
    'lesion_abierta',
  ];

  bool _modelCargado = false;

  //inicializar el modelo desde assets
  Future<bool> inicializar() async {
    try {
      //todo aca cargamos el modelo real de assets
      //por ahora es un stub de muestra
      _modelCargado = true;
      return true;
    } catch (e) {
      _modelCargado = false;
      return false;
    }
  }

  //inferencia en un frame de imagen
  Future<List<YoloDetection>> inferir(Uint8List imagenBytes) async {
    if (!_modelCargado) return [];

    try {
      //todo aca va el procesamiento real del modelo
      //por ahora devuelve lista vacia
      return [];
    } catch (e) {
      return [];
    }
  }

  //detectar lesiones en imagen
  Future<YoloDetection?> detectarLesion(Uint8List imagenBytes) async {
    final detecciones = await inferir(imagenBytes);
    if (detecciones.isEmpty) return null;

    //devuelve la deteccion con mas confianza
    return detecciones.reduce((a, b) => a.confianza > b.confianza ? a : b);
  }

  //ver si el modelo esta listo
  bool get listo => _modelCargado;

  @override
  void onClose() {
    //limpiar recursos del modelo
    super.onClose();
  }
}
