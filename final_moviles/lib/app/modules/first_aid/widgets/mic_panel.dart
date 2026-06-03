import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/first_aid_controller.dart';

class MicPanelController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final AnimationController pulse;
  late final Animation<double> scale;

  @override
  void onInit() {
    super.onInit();
    pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);
    scale = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void onClose() {
    pulse.dispose();
    super.onClose();
  }
}

class MicPanel extends StatelessWidget {
  MicPanel({super.key, required this.controller});

  final FirstAidController controller;
  final micController = Get.put(MicPanelController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Obx(() {
        final escuchando = controller.escuchando.value;
        final analizando = controller.analizando.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: analizando ? null : controller.toggleEscucha,
              child: ScaleTransition(
                scale: escuchando
                    ? micController.scale
                    : const AlwaysStoppedAnimation(1.0),
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: ShapeDecoration(
                    color: escuchando ? theme.colorScheme.error : Colors.transparent,
                    shape: BeveledRectangleBorder(
                      side: BorderSide(
                        color: escuchando
                            ? theme.colorScheme.error
                            : theme.colorScheme.secondary,
                        width: 3.0,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(22),
                        topRight: Radius.circular(22),
                      ),
                    ),
                    shadows: [
                      if (escuchando)
                        BoxShadow(
                          color: theme.colorScheme.error.withValues(alpha: 0.4),
                          blurRadius: 28,
                          spreadRadius: 4,
                        )
                      else
                        BoxShadow(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  child: Icon(
                    escuchando ? Icons.mic : Icons.mic_none_rounded,
                    size: 38,
                    color: escuchando ? Colors.black : theme.colorScheme.secondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                analizando
                    ? 'ANALIZANDO...'
                    : escuchando
                        ? 'ESCUCHANDO...'
                        : 'TOCA PARA HABLAR',
                key: ValueKey(analizando ? 'a' : escuchando ? 'e' : 'i'),
                style: TextStyle(
                  color: escuchando ? theme.colorScheme.error : theme.colorScheme.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
