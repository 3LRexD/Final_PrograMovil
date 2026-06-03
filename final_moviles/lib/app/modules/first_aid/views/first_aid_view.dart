import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/first_aid_controller.dart';
import '../widgets/diagnosis_card.dart';
import '../widgets/mic_panel.dart';
import '../widgets/mode_selector.dart';
import '../widgets/permission_message.dart';

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

    //cambia layout completo segun el modo
    return Obx(() {
      if (controller.modo.value == Modo.microfono) {
        return ColoredBox(
          color: Theme.of(context).colorScheme.background,
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
          Obx(() {
            final det = controller.ultimaDeteccion.value;
            if (det == null) return const SizedBox.shrink();

            final size = MediaQuery.of(context).size;
            final camH = size.height - topInset - 220;
            final bb   = det.boundingBox;

            final left = (bb.x     * size.width).clamp(0.0, size.width  - 4);
            final top  = (topInset + bb.y * camH).clamp(topInset, topInset + camH - 4);
            final boxW = (bb.ancho * size.width).clamp(4.0, size.width);
            final boxH = (bb.alto  * camH).clamp(4.0, camH);

            return CustomPaint(
              painter: _DetectionBoxPainter(
                Rect.fromLTWH(left, top, boxW, boxH),
                Theme.of(context).colorScheme.error,
              ),
              child: const SizedBox.expand(),
            );
          }),
         Positioned(
            left: 0, right: 0, bottom: 0,
            child: _BottomPanel(controller: controller, isDark: true),
          ),  
        ],
      );
    });
  }
}

//appbar cambia de color segun el modo
class _AppBarReactivo extends StatelessWidget implements PreferredSizeWidget {
  const _AppBarReactivo({required this.controller});

  final FirstAidController controller;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final isMic = controller.modo.value == Modo.microfono;
      return AppBar(
        backgroundColor:
            isMic ? theme.colorScheme.surface : Colors.transparent,
        foregroundColor: isMic ? theme.colorScheme.primary : theme.colorScheme.secondary,
        elevation: 0,
        shape: isMic 
          ? Border(
              bottom: BorderSide(color: theme.colorScheme.secondary, width: 2),
            ) 
          : null,
        title: Text(
          isMic ? 'CONEXIÓN DE AUDIO ESTABLECIDA' : 'ESCÁNER MÉDICO ACTIVO',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          if (!isMic)
            Obx(() => IconButton(
                  icon: Icon(controller.torchActivo.value
                      ? Icons.flashlight_on_rounded
                      : Icons.flashlight_off_rounded),
                  onPressed: controller.toggleTorch,
                  tooltip: 'Linterna',
                  color: controller.torchActivo.value ? theme.colorScheme.primary : theme.colorScheme.secondary,
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
                colors: [Colors.black, Colors.transparent],
              ),
            )
          : BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //tarjeta de diagnostico y boton para parar el audio
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
                    onTap: controller.toggleAudio,
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.9)
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Obx(() => Icon(
                          controller.hablando.value ? Icons.stop_rounded : Icons.play_arrow_rounded,
                          size: 20, color: Colors.black87)),
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
          _StatusLabel(controller: controller),
        ],
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.controller});

  final FirstAidController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        shape: BeveledRectangleBorder(
          side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5), width: 1),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
      ),
      child: Obx(() {
        const textColor = Colors.white70;
        const emTextColor = Colors.white;

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
        if (controller.analizando.value) {
          return _InfoRow(
            icon: Icons.radar_rounded,
            texto: 'Escaneando...',
            textColor: textColor,
          );
        }
        return _InfoRow(
          icon: Icons.health_and_safety,
          texto: 'Escaneo automático activo',
          textColor: textColor,
        );
      }),
    );
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
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 15),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(texto, style: TextStyle(color: textColor, fontSize: 12)),
        ),
      ],
    );
  }
}

//dibuja el cuadro de deteccion con las esquinas recortadas
class _DetectionBoxPainter extends CustomPainter {
  const _DetectionBoxPainter(this.box, this.color);

  final Rect box;
  final Color color;

  static const _arm = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final l  = box.left;
    final t  = box.top;
    final r  = box.right;
    final b  = box.bottom;
    const arm = _arm;

    //arriba izquierda
    canvas.drawLine(Offset(l, t + arm), Offset(l, t), paint);
    canvas.drawLine(Offset(l, t), Offset(l + arm, t), paint);

    //arriba derecha
    canvas.drawLine(Offset(r - arm, t), Offset(r, t), paint);
    canvas.drawLine(Offset(r, t), Offset(r, t + arm), paint);

    //abajo derecha
    canvas.drawLine(Offset(r, b - arm), Offset(r, b), paint);
    canvas.drawLine(Offset(r, b), Offset(r - arm, b), paint);

    //abajo izquierda
    canvas.drawLine(Offset(l + arm, b), Offset(l, b), paint);
    canvas.drawLine(Offset(l, b), Offset(l, b - arm), paint);
    
    //mira en el centro
    final cx = box.center.dx;
    final cy = box.center.dy;
    final crossPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(cx - 15, cy), Offset(cx + 15, cy), crossPaint);
    canvas.drawLine(Offset(cx, cy - 15), Offset(cx, cy + 15), crossPaint);
  }

  @override
  bool shouldRepaint(_DetectionBoxPainter old) => old.box != box;
}
