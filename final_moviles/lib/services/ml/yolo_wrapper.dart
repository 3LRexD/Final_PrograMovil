import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

const int _inputSize = 640;
const double _confThreshold = 0.45;

//clases sacadas de best.pt
//el indice tiene que ser igual al id de clase
const List<String> _clases = [
  'quemadura',
  'herida_abierta',
  'erupcion_cutanea',
  'moreton',
  'trauma_ocular',
  'lesion_medica',
  'sangre',
];

class YoloDetection {
  final String clase;
  final double confianza;
  final Rect boundingBox;

  const YoloDetection({
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

  const Rect({
    required this.x,
    required this.y,
    required this.ancho,
    required this.alto,
  });
}

//el isolate corre la inferencia para no congelar la pantalla

class _InitMsg {
  final SendPort mainPort;
  final Uint8List modelBytes;
  const _InitMsg(this.mainPort, this.modelBytes);
}

void _isolateEntry(_InitMsg init) {
  //carga el modelo en memoria para evitar problemas de comunicacion de hilos
  final interpreter = Interpreter.fromBuffer(
    init.modelBytes,
    options: InterpreterOptions()..threads = 4,
  );

  final port = ReceivePort();
  init.mainPort.send(port.sendPort);

  port.listen((msg) {
    if (msg is Uint8List) {
      List<YoloDetection> dets;
      try {
        dets = _ejecutar(interpreter, msg);
      } catch (_) {
        dets = const [];
      }
      init.mainPort.send(dets);
    }
  });
}

List<YoloDetection> _ejecutar(Interpreter interp, Uint8List jpeg) {
  final decoded = img.decodeImage(jpeg);
  if (decoded == null) return const [];

  final origW = decoded.width;
  final origH = decoded.height;

  //letterbox mantiene la proporcion de la imagen rellenando con gris
  final scale = math.min(_inputSize / origW, _inputSize / origH);
  final newW = (origW * scale).round();
  final newH = (origH * scale).round();
  final padX = ((_inputSize - newW) / 2).floor();
  final padY = ((_inputSize - newH) / 2).floor();

  final resized = img.copyResize(decoded, width: newW, height: newH);
  final canvas = img.Image(width: _inputSize, height: _inputSize);
  img.fill(canvas, color: img.ColorRgb8(114, 114, 114));
  img.compositeImage(canvas, resized, dstX: padX, dstY: padY);

  //normaliza los bytes de la imagen entre cero y uno
  final tensor = Float32List(_inputSize * _inputSize * 3);
  var idx = 0;
  for (var y = 0; y < _inputSize; y++) {
    for (var x = 0; x < _inputSize; x++) {
      final p = canvas.getPixel(x, y);
      tensor[idx++] = p.r / 255.0;
      tensor[idx++] = p.g / 255.0;
      tensor[idx++] = p.b / 255.0;
    }
  }

  //escribe directo al buffer para que mantenga la dimension correcta
  interp.getInputTensor(0).data = tensor.buffer.asUint8List();
  interp.invoke();

  final shape = interp.getOutputTensor(0).shape;
  final out = interp.getOutputTensor(0).data.buffer.asFloat32List();
  return _parse(out, shape, scale, padX, padY, origW, origH);
}

//procesa el output del modelo y ajusta las coordenadas sacando el padding
List<YoloDetection> _parse(
  Float32List outFloats,
  List<int> shape,
  double scale,
  int padX,
  int padY,
  int origW,
  int origH,
) {
  if (shape.length < 3 || outFloats.isEmpty) return const [];

  final numDet = shape[1];//300 detecciones como maximo
  final stride = shape[2];//6 valores de cada deteccion
  if (stride < 6) return const [];

  final detecciones = <YoloDetection>[];

  //mapeo de coordenadas
  double unmapX(double n) => ((n * _inputSize - padX) / scale) / origW;
  double unmapY(double n) => ((n * _inputSize - padY) / scale) / origH;

  for (var d = 0; d < numDet; d++) {
    final base = d * stride;
    final conf = outFloats[base + 4];
    if (conf < _confThreshold) continue;

    final x1 = unmapX(outFloats[base + 0]);
    final y1 = unmapY(outFloats[base + 1]);
    final x2 = unmapX(outFloats[base + 2]);
    final y2 = unmapY(outFloats[base + 3]);
    final clase = outFloats[base + 5].round();

    detecciones.add(YoloDetection(
      clase: clase >= 0 && clase < _clases.length
          ? _clases[clase]
          : 'clase_$clase',
      confianza: conf,
      boundingBox: Rect(
        x: x1,
        y: y1,
        ancho: x2 - x1,
        alto: y2 - y1,
      ),
    ));
  }

  detecciones.sort((a, b) => b.confianza.compareTo(a.confianza));
  return detecciones.take(10).toList();
}



class YoloWrapper extends GetxService {
  static const String modelVersion = '1.0.0';
  static const String modelName = 'YOLOv8-FirstAid-Detector';
  static const int inputSize = _inputSize;
  static const double confidenceThreshold = _confThreshold;
  static const List<String> clases = _clases;

  Isolate? _isolate;
  ReceivePort? _rPort;
  SendPort? _sendPort;
  Completer<void>? _readyC;
  Completer<List<YoloDetection>>? _pending;
  bool _modelCargado = false;

  Future<bool> inicializar() async {
    try {
      final data = await rootBundle.load('assets/models/best_float16_new.tflite');
      final bytes = data.buffer.asUint8List();

      _rPort = ReceivePort();
      _readyC = Completer<void>();
      _isolate = await Isolate.spawn(
        _isolateEntry,
        _InitMsg(_rPort!.sendPort, bytes),
      );

      _rPort!.listen((msg) {
        if (msg is SendPort) {
          _sendPort = msg;
          _readyC?.complete();
        } else if (msg is List) {
          final p = _pending;
          _pending = null;
          p?.complete(msg.cast<YoloDetection>());
        }
      });

      await _readyC!.future;
      _modelCargado = true;
      return true;
    } catch (e) {
      _modelCargado = false;
      return false;
    }
  }

  //manda la imagen al isolate y si esta ocupado no hace nada
  Future<List<YoloDetection>> inferir(Uint8List imagenBytes) async {
    if (!_modelCargado || _sendPort == null || _pending != null) {
      return const [];
    }
    final c = Completer<List<YoloDetection>>();
    _pending = c;
    _sendPort!.send(imagenBytes);
    return c.future;
  }

  Future<YoloDetection?> detectarLesion(Uint8List imagenBytes) async {
    final detecciones = await inferir(imagenBytes);
    if (detecciones.isEmpty) return null;
    return detecciones.reduce((a, b) => a.confianza > b.confianza ? a : b);
  }

  bool get listo => _modelCargado;

  @override
  void onClose() {
    _isolate?.kill(priority: Isolate.immediate);
    _rPort?.close();
    super.onClose();
  }
}
