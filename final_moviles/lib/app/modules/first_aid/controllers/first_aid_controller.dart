import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../routes/app_routes.dart';
import '../../../services/sintoma_service.dart';

enum CameraEstado { inicial, cargando, lista, sinPermiso, error }

enum Modo { camara, microfono }

//diagnostico falso para modo camara (presion larga 3s)
const _diagCamara = Diagnostico(
  causa: 'Cortadura leve',
  descripcion: 'Herida superficial con sangrado leve.',
  tratamiento:
      'Limpia la herida con agua y jabón, aplica presión suave para detener cualquier sangrado, coloca una crema antiséptica o pomada antibiótica si tienes a mano, y cúbrela con una venda o curita. Si no para de sangrar o la cortada es muy profunda, ve al médico.',
  urgencia: 'baja',
);

class FirstAidController extends GetxController {
  FirstAidController({required this.sintomas});

  final SintomaService sintomas;

  //camara
  CameraController? cameraController;
  final estado = CameraEstado.inicial.obs;
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
  Timer? _presionTimer;

  int _cameraDiagnosisCount = 0;
  int _audioDiagnosisCount = 0;

  @override
  void onInit() {
    super.onInit();
    inicializar();
    _initTts();
  }

  @override
  void onClose() {
    _presionTimer?.cancel();
    _stt.stop();
    _tts.stop();
    cameraController?.dispose();
    super.onClose();
  }

  //camara --------------------------------------

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

  //presion larga en camara (3s) → diagnostico falso
  void iniciarPresion() {
    _presionTimer?.cancel();
    _presionTimer = Timer(const Duration(seconds: 3), () {
      if (_cameraDiagnosisCount < 1) {
        diagnostico.value = _diagCamara;
        hablar(_diagCamara.tratamiento);
        _cameraDiagnosisCount++;
      } else {
        Get.toNamed(AppRoutes.mlError);
      }
    });
  }

  void cancelarPresion() => _presionTimer?.cancel();

  //modo y tts ----------------------------------

  Future<void> _initTts() async {
    await _tts.setLanguage('es-MX');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
  }

  void cambiarModo(Modo nuevo) {
    if (modo.value == nuevo) return;
    if (escuchando.value) _detenerEscucha();
    diagnostico.value = null;
    textoEscuchado.value = '';
    modo.value = nuevo;
  }

  Future<void> hablar(String texto) async => _tts.speak(texto);

  Future<void> pararAudio() async => _tts.stop();

  //microfono -----------------------------------

  Future<void> toggleEscucha() async {
    if (escuchando.value) {
      //el usuario para: procesamos lo que se capturó
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
          //si el os para por silencio, sincronizamos el estado
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
        //no auto-procesar, el usuario toca para parar
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
      if (_audioDiagnosisCount < 1) {
        final res = await sintomas.analizar(texto);
        diagnostico.value = res;
        await hablar('${res.causa}. ${res.tratamiento}');
        _audioDiagnosisCount++;
      } else {
        Get.toNamed(AppRoutes.mlError);
      }
    } catch (_) {
    } finally {
      analizando.value = false;
    }
  }
}
