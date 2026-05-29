import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/first_aid_controller.dart';
import '../widgets/diagnosis_card.dart';
import '../widgets/mic_panel.dart';
import '../widgets/mode_selector.dart';
import '../widgets/permission_message.dart';
import '../widgets/scanner_overlay.dart';

class FirstAidView extends GetView<FirstAidController> {
  const FirstAidView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _AppBarReactivo(controller: controller),
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
          mensaje: 'Para detectar lesiones necesitamos acceso a la cámara. Habilítalo desde los ajustes.',
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
        return _buildContenido(context);
    }
  }

  Widget _buildContenido(BuildContext context) {
    final cam = controller.cameraController!;
    final topInset = MediaQuery.of(context).viewPadding.top + kToolbarHeight;

    //cambia layout completo segun modo
    return Obx(() {
      if (controller.modo.value == Modo.microfono) {
        return ColoredBox(
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(height: topInset),
              Expanded(child: MicPanel(controller: controller)),
              _BottomPanel(controller: controller, isDark: false),
            ],
          ),
        );
      }

      //modo camara
      return Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(cam),
          Positioned(
            top: topInset,
            bottom: 220,
            left: 0,
            right: 0,
            child: const ScannerOverlay(),
          ),

          Obx(() {
            if (controller.diagnostico.value == null) {
              return const SizedBox.shrink();
            }
            
            return Positioned(
              top: topInset + 60,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: const Text(
                        'CORTADURA 0.54',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 3.5),
                        color: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          //detector de presion larga encima del scanner, debajo del panel
          Positioned(
            top: 0,
            bottom: 220,
            left: 0,
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (_) => controller.iniciarPresion(),
              onTapUp: (_) => controller.cancelarPresion(),
              onTapCancel: controller.cancelarPresion,
            ),
          ),
         Positioned(
            left: 0, right: 0, bottom: 0,
            child: _BottomPanel(controller: controller, isDark: true),
          ),  
        ],
      );
    });
  }
}

//appbar que cambia color segun modo
class _AppBarReactivo extends StatelessWidget implements PreferredSizeWidget {
  const _AppBarReactivo({required this.controller});

  final FirstAidController controller;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isMic = controller.modo.value == Modo.microfono;
      return AppBar(
        backgroundColor:
            isMic ? const Color(0xFF1976D2) : Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Primeros Auxilios'),
        actions: [
          if (!isMic)
            Obx(() => IconButton(
                  icon: Icon(controller.torchActivo.value
                      ? Icons.flashlight_on_rounded
                      : Icons.flashlight_off_rounded),
                  onPressed: controller.toggleTorch,
                  tooltip: 'Linterna',
                )),
        ],
      );
    });
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({required this.controller, required this.isDark});

  final FirstAidController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, isDark ? 40 : 12, 16, 36),
      decoration: isDark
          ? const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            )
          : const BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //tarjeta de diagnostico + boton de parar audio
          Obx(() {
            final d = controller.diagnostico.value;
            if (d == null) return const SizedBox.shrink();
            final transcripcion =
                !isDark && controller.textoEscuchado.value.isNotEmpty
                    ? controller.textoEscuchado.value
                    : null;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Row(
                key: ValueKey(d.causa),
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: DiagnosisCard(
                      diagnostico: d,
                      transcripcion: transcripcion,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: controller.pararAudio,
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.9)
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stop_rounded,
                          size: 20, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),

          //selector de modo
          Obx(() => ModeSelector(
                modoActual: controller.modo.value,
                onCambiar: controller.cambiarModo,
              )),
          const SizedBox(height: 10),

          //etiqueta de estado
          _StatusLabel(controller: controller, isDark: isDark),
        ],
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.controller, required this.isDark});

  final FirstAidController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final textColor = isDark ? Colors.white70 : Colors.black54;
      final emTextColor = isDark ? Colors.white : Colors.black87;

      if (controller.modo.value == Modo.microfono) {
        if (controller.analizando.value) {
          return _InfoRow(
            icon: Icons.hourglass_top_rounded,
            texto: 'Analizando síntomas...',
            textColor: textColor,
          );
        }
        if (controller.escuchando.value &&
            controller.textoEscuchado.value.isNotEmpty) {
          return Text(
            '"${controller.textoEscuchado.value}"',
            style: TextStyle(
              color: emTextColor,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          );
        }
        return _InfoRow(
          icon: Icons.mic_none_rounded,
          texto: 'Toca el micrófono y describe los síntomas',
          textColor: textColor,
        );
      }
      return _InfoRow(
        icon: Icons.health_and_safety,
        texto: 'Mantén presionado 3 s para ver un diagnóstico',
        textColor: textColor,
      );
    });
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.texto,
    this.textColor = Colors.white70,
  });

  final IconData icon;
  final String texto;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 15),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(texto, style: TextStyle(color: textColor, fontSize: 12)),
        ),
      ],
    );
  }
}
