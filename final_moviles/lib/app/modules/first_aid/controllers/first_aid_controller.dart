import 'dart:io';

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../services/google_tts_service.dart';  
import '../../../services/sintoma_service.dart';
import '../../../../services/ml/yolo_wrapper.dart';
import '../../../services/llm_service.dart';

enum CameraEstado { inicial, cargando, lista, sinPermiso, error }

enum Modo { camara, microfono }

class FirstAidController extends GetxController {
  FirstAidController({required this.sintomas});

  final SintomaService sintomas;
  final _yolo = YoloWrapper();

  bool get modeloListo => _yolo.listo;

  CameraController? cameraController;
  final estado = CameraEstado.inicial.obs;
  final ultimaDeteccion = Rx<YoloDetection?>(null);
  final mensajeError = ''.obs;
  final torchActivo = false.obs;

  final modo = Modo.camara.obs;

  final escuchando = false.obs;
  final textoEscuchado = ''.obs;
  final analizando = false.obs;
  final diagnostico = Rx<Diagnostico?>(null);

  final _stt = SpeechToText();
  bool _sttListo = false;
  bool _escaneando = false;
  bool _loopActivo = false;
  String? _ultimaClaseHablada;

  final _tts = GoogleTtsService.instance;

  final hablando = false.obs;
  String _ultimoTextoHablado = '';
  // ignore: cancel_subscriptions
  late final _playingSub = _tts.playingStream.listen((p) => hablando.value = p);

  LlmService get _llm => Get.find<LlmService>();

  @override
  void onInit() {
    super.onInit();
    inicializar();
    _yolo.inicializar();
    _llm.init();
  }

  @override
  void onClose() {
    _escaneando = false;
    _playingSub.cancel();
    _stt.stop();
    _tts.stop();
    cameraController?.dispose();
    _yolo.onClose();
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

  void _iniciarScanAutomatico() {
    _escaneando = true;
    if (_loopActivo) return; 
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
      final deteccion = await _yolo.detectarLesion(bytes);
      File(foto.path).delete().ignore();

      if (deteccion != null) {
        ultimaDeteccion.value = deteccion;
        if (deteccion.clase != _ultimaClaseHablada) {
          _ultimaClaseHablada = deteccion.clase;
          final claseLimpia = deteccion.clase.replaceAll('_', ' ');

          _llm.limpiarHistorial(); // cada detección nueva es conversación nueva
          diagnostico.value = Diagnostico(
            causa: claseLimpia,
            descripcion: 'Lesión detectada · Confianza: ${(deteccion.confianza * 100).toStringAsFixed(1)}%',
            tratamiento: 'Consultando manuales…',
            urgencia: 'alta',
          );
          hablar(
            '$claseLimpia, confianza ${(deteccion.confianza * 100).toStringAsFixed(0)} por ciento',
          );
          _generarSugerenciaLLM(claseLimpia, conHistorial: false);
        }
      } else {
        ultimaDeteccion.value = null;
        diagnostico.value = null;
      }
    } catch (_) {
    } finally {
      analizando.value = false;
    }
  }

  // [conHistorial]=false para detecciones de cámara (pregunta fresca),
  // [conHistorial]=true para el micrófono (mantiene hilo de conversación).
  Future<void> _generarSugerenciaLLM(
    String problema, {
    bool conHistorial = false,
  }) async {
    final respuesta = await _llm.consultar(problema, conHistorial: conHistorial);
    if (respuesta == null) return;

    final d = diagnostico.value;
    if (d != null) {
      diagnostico.value = Diagnostico(
        causa: d.causa,
        descripcion: d.descripcion,
        tratamiento: respuesta,
        urgencia: d.urgencia,
      );
    }
    hablar(_sinMarkdown(respuesta));
  }

  // Elimina marcadores markdown para que el TTS lea texto limpio.
  String _sinMarkdown(String texto) => texto
      .replaceAll(RegExp(r'\*+'), '')
      .replaceAll(RegExp(r'_+'), '')
      .replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '')
      .replaceAll(RegExp(r'^\s*[-•]\s+', multiLine: true), '')
      .replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '')
      .replaceAll('`', '')
      .replaceAll(RegExp(r'\[(.+?)\]\(.+?\)'), r'$1')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();

  Future<void> hablar(String texto) async {
    _ultimoTextoHablado = texto;
    await _tts.speak(texto); // hablando driven by playingStream
  }

  Future<void> pararAudio() async => _tts.stop();

  Future<void> toggleAudio() async {
    if (hablando.value) {
      await pararAudio();
    } else if (_ultimoTextoHablado.isNotEmpty) {
      await hablar(_ultimoTextoHablado);
    }
  }


  void cambiarModo(Modo nuevo) {
    if (modo.value == nuevo) return;
    if (escuchando.value) _detenerEscucha();
    pararAudio();
    diagnostico.value = null;
    textoEscuchado.value = '';
    ultimaDeteccion.value = null;
    _ultimaClaseHablada = null;
    _llm.limpiarHistorial();
    modo.value = nuevo;
    if (nuevo == Modo.camara) {
      _iniciarScanAutomatico();
    } else {
      _detenerScan();
    }
  }

  Future<void> toggleEscucha() async {
    if (escuchando.value) {
      // El usuario frena la grabación, así procesamos
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
      diagnostico.value = Diagnostico(
        causa: 'Consulta registrada',
        descripcion: 'Analizando síntomas: "$texto"',
        tratamiento: 'Generando procedimiento sugerido...',
        urgencia: 'media',
      );
      
      _generarSugerenciaLLM(texto, conHistorial: true);
    } catch (_) {
    } finally {
      analizando.value = false;
    }
  }
}