import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

enum CameraEstado { inicial, cargando, lista, sinPermiso, error }

class FirstAidController extends GetxController {
  CameraController? cameraController;

  final estado = CameraEstado.inicial.obs;
  final mensajeError = ''.obs;
  final torchActivo = false.obs;

  @override
  void onInit() {
    super.onInit();
    inicializar();
  }

  @override
  void onClose() {
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
}
