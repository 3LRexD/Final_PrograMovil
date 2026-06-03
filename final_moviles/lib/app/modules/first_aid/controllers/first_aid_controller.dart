import 'dart:async';

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../routes/app_routes.dart';
import '../../../services/google_tts_service.dart';  
import '../../../services/sintoma_service.dart';

enum CameraEstado { inicial, cargando, lista, sinPermiso, error }

enum Modo { camara, microfono }

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

  CameraController? cameraController;
  final estado = CameraEstado.inicial.obs;
  final mensajeError = ''.obs;
  final torchActivo = false.obs;

  final modo = Modo.camara.obs;

  final escuchando = false.obs;
  final textoEscuchado = ''.obs;
  final analizando = false.obs;
  final diagnostico = Rx<Diagnostico?>(null);

  final _stt = SpeechToText();
  bool _sttListo = false;
  Timer? _presionTimer;

  final _tts = GoogleTtsService.instance;

  int _cameraDiagnosisCount = 0;
  int _audioDiagnosisCount = 0;

  @override
  void onInit() {
    super.onInit();
    inicializar();
  }

  @override
  void onClose() {
    _presionTimer?.cancel();
    _stt.stop();
    _tts.stop();       
    cameraController?.dispose();
    super.onClose();
  }

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
      cameraController = CameraController(
        trasera,
        ResolutionPreset.high,
        enableAudio: false,
      );
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

  Future<void> hablar(String texto) => _tts.speak(texto);
  Future<void> pararAudio() => _tts.stop();

  void cambiarModo(Modo nuevo) {
    if (modo.value == nuevo) return;
    if (escuchando.value) _detenerEscucha();
    _tts.stop();
    diagnostico.value = null;
    textoEscuchado.value = '';
    modo.value = nuevo;
  }

  Future<void> toggleEscucha() async {
    if (escuchando.value) {
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
        await hablar('${res.causa}. ${res.tratamiento}');  // ← Google TTS
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