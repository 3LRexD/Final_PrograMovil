import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../services/sintoma_service.dart';
import '../../../../services/ml/yolo_wrapper.dart';

enum CameraEstado { inicial, cargando, lista, sinPermiso, error }

enum Modo { camara, microfono }


class FirstAidController extends GetxController {
  FirstAidController({required this.sintomas});

  final SintomaService sintomas;
  final _yolo = YoloWrapper();

  bool get modeloListo => _yolo.listo;

  //camara
  CameraController? cameraController;
  final estado = CameraEstado.inicial.obs;
  final ultimaDeteccion = Rx<YoloDetection?>(null);
  final mensajeError = ''.obs;
  final torchActivo = false.obs;

  //modo
  final modo = Modo.camara.obs;

  //microfono
  final escuchando = false.obs;
  final textoEscuchado = ''.obs;
  final analizando = false.obs;
  final diagnostico = Rx<Diagnostico?>(null);

  final _stt = SpeechToText();
  final _tts = FlutterTts();
  bool _sttListo = false;
  bool _escaneando = false;
  bool _loopActivo = false;
  String? _ultimaClaseHablada;

  final hablando = false.obs;
  String _ultimoTextoHablado = '';

  @override
  void onInit() {
    super.onInit();
    inicializar();
    _initTts();
    _yolo.inicializar();
  }

  @override
  void onClose() {
    _escaneando = false;
    _stt.stop();
    _tts.stop();
    cameraController?.dispose();
    _yolo.onClose();
    super.onClose();
  }

  //camara

  Future<void> inicializar() async {
    estado.value = CameraEstado.cargando;
    final permiso = await Permission.camera.request();
    if (!permiso.isGranted) {
      estado.value = CameraEstado.sinPermiso;
      return;
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        mensajeError.value = 'No se encontraron cámaras disponibles.';
        estado.value = CameraEstado.error;
        return;
      }
      final trasera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      cameraController =
          CameraController(trasera, ResolutionPreset.high, enableAudio: false);
      await cameraController!.initialize();
      estado.value = CameraEstado.lista;
      _iniciarScanAutomatico();
    } catch (e) {
      mensajeError.value = 'No se pudo iniciar la cámara: $e';
      estado.value = CameraEstado.error;
    }
  }

  Future<void> toggleTorch() async {
    if (cameraController?.value.isInitialized != true) return;
    torchActivo.value = !torchActivo.value;
    await cameraController!.setFlashMode(
      torchActivo.value ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<void> abrirAjustes() => openAppSettings();

  //escaneo continuo procesa frame por frame segun la velocidad del dispositivo
  void _iniciarScanAutomatico() {
    _escaneando = true;
    if (_loopActivo) return;//ya hay un loop corriendo
    _loopActivo = true;
    _loopScan();
  }

  void _detenerScan() => _escaneando = false;

  Future<void> _loopScan() async {
    while (_escaneando) {
      await _escanear();
    }
    _loopActivo = false;
  }

  Future<void> _escanear() async {
    if (cameraController?.value.isInitialized != true) return;
    if (modo.value != Modo.camara) return;

    analizando.value = true;
    try {
      final foto = await cameraController!.takePicture();
      final bytes = await foto.readAsBytes();
      //el modelo corre en isolate para no trabar la ui
      final deteccion = await _yolo.detectarLesion(bytes);
      //borra el archivo temporal para que no llene el disco
      File(foto.path).delete().ignore();

      if (deteccion != null) {
        ultimaDeteccion.value = deteccion;
        diagnostico.value = _diagDesdeDeteccion(deteccion);
        //solo habla si cambia la lesion
        if (deteccion.clase != _ultimaClaseHablada) {
          _ultimaClaseHablada = deteccion.clase;
          final claseLimpia = deteccion.clase.replaceAll('_', ' ');
          hablar(
            '$claseLimpia, confianza ${(deteccion.confianza * 100).toStringAsFixed(0)} por ciento',
          );
        }
      } else {
        ultimaDeteccion.value = null;
        diagnostico.value = null;
        //no borra el ultimo hablado para no repetirse
      }
    } catch (_) {
    } finally {
      analizando.value = false;
    }
  }

  Diagnostico _diagDesdeDeteccion(YoloDetection d) {
    final conf = (d.confianza * 100).toStringAsFixed(1);
    final bb = d.boundingBox;
    final claseLimpia = d.clase.replaceAll('_', ' ');
    return Diagnostico(
      causa: claseLimpia,
      descripcion: 'Lesión detectada · Confianza: $conf%',
      tratamiento:
          'Clase: $claseLimpia\n'
          'Confianza: $conf%\n'
          'Bbox — x: ${bb.x.toStringAsFixed(3)}, y: ${bb.y.toStringAsFixed(3)}, '
          'w: ${bb.ancho.toStringAsFixed(3)}, h: ${bb.alto.toStringAsFixed(3)}',
      urgencia: 'baja',
    );
  }

  //modo y tts

  Future<void> _initTts() async {
    await _tts.setLanguage('es-MX');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    _tts.setStartHandler(() => hablando.value = true);
    _tts.setCompletionHandler(() => hablando.value = false);
    _tts.setCancelHandler(() => hablando.value = false);
  }

  void cambiarModo(Modo nuevo) {
    if (modo.value == nuevo) return;
    if (escuchando.value) _detenerEscucha();
    diagnostico.value = null;
    textoEscuchado.value = '';
    ultimaDeteccion.value = null;
    _ultimaClaseHablada = null;
    modo.value = nuevo;
    if (nuevo == Modo.camara) {
      _iniciarScanAutomatico();
    } else {
      _detenerScan();
    }
  }

  Future<void> hablar(String texto) async {
    _ultimoTextoHablado = texto;
    await _tts.speak(texto);
  }

  Future<void> pararAudio() async => _tts.stop();

  Future<void> toggleAudio() async {
    if (hablando.value) {
      await _tts.stop();
    } else if (_ultimoTextoHablado.isNotEmpty) {
      await hablar(_ultimoTextoHablado);
    }
  }

  //microfono

  Future<void> toggleEscucha() async {
    if (escuchando.value) {
      //el usuario frena la grabacion asi procesamos
      final texto = textoEscuchado.value;
      await _detenerEscucha();
      if (texto.isNotEmpty) _procesarSintoma(texto);
    } else {
      await _iniciarEscucha();
    }
  }

  Future<void> _iniciarEscucha() async {
    if (!_sttListo) {
      _sttListo = await _stt.initialize(
        onStatus: (status) {
          //si se apaga por silencio actualiza el estado
          if ((status == 'done' || status == 'notListening') &&
              escuchando.value) {
            escuchando.value = false;
          }
        },
      );
    }
    if (!_sttListo) return;

    textoEscuchado.value = '';
    escuchando.value = true;

    await _stt.listen(
      onResult: (result) {
        textoEscuchado.value = result.recognizedWords;
        //no procesa aca el usuario tiene que tocar de nuevo
      },
      listenOptions: SpeechListenOptions(
        localeId: 'es-MX',
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 8),
      ),
    );
  }

  Future<void> _detenerEscucha() async {
    await _stt.stop();
    escuchando.value = false;
  }

  Future<void> _procesarSintoma(String texto) async {
    await _detenerEscucha();
    analizando.value = true;
    try {
      final res = await sintomas.analizar(texto);
      diagnostico.value = res;
      await hablar('${res.causa}. ${res.tratamiento}');
    } catch (_) {
    } finally {
      analizando.value = false;
    }
  }
}
