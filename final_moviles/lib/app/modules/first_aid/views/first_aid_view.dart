import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/first_aid_controller.dart';
import '../widgets/permission_message.dart';
import '../widgets/scanner_overlay.dart';

class FirstAidView extends GetView<FirstAidController> {
  const FirstAidView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Primeros Auxilios'),
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  controller.torchActivo.value
                      ? Icons.flashlight_on_rounded
                      : Icons.flashlight_off_rounded,
                ),
                onPressed: controller.toggleTorch,
                tooltip: 'Linterna',
              )),
        ],
      ),
      body: Obx(() => _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (controller.estado.value) {
      case CameraEstado.inicial:
      case CameraEstado.cargando:
        return const Center(child: CircularProgressIndicator());

      case CameraEstado.sinPermiso:
        return PermissionMessage(
          icono: Icons.no_photography,
          titulo: 'Permiso de cámara requerido',
          mensaje:
              'Para detectar lesiones necesitamos acceso a la cámara. Habilítalo desde los ajustes.',
          textoAccion: 'Abrir ajustes',
          onAccion: controller.abrirAjustes,
        );

      case CameraEstado.error:
        return PermissionMessage(
          icono: Icons.error_outline,
          titulo: 'Algo salió mal',
          mensaje: controller.mensajeError.value,
          textoAccion: 'Reintentar',
          onAccion: controller.inicializar,
        );

      case CameraEstado.lista:
        return _buildCamara(context);
    }
  }

  Widget _buildCamara(BuildContext context) {
    final cam = controller.cameraController!;
    //espacio arriba (barra + appbar)
    final topInset = MediaQuery.of(context).viewPadding.top + kToolbarHeight;
    //espacio abajo del panel
    const bottomInset = 130.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(cam),
        Positioned(
          top: topInset,
          bottom: bottomInset,
          left: 0,
          right: 0,
          child: const ScannerOverlay(),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 36),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.health_and_safety,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Análisis en tiempo real',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Apunta la cámara hacia la lesión o escena para comenzar.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                //TODO: resultados del modelo van aca
              ],
            ),
          ),
        ),
      ],
    );
  }
}
