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
    scale = Tween<double>(begin: 0.92, end: 1.1).animate(
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: escuchando ? Colors.redAccent : Colors.white,
                    border: Border.all(
                      color: escuchando
                          ? Colors.redAccent
                          : const Color(0xFF1976D2),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (escuchando
                                ? Colors.red
                                : const Color(0xFF1976D2))
                            .withValues(alpha: 0.25),
                        blurRadius: escuchando ? 28 : 10,
                        spreadRadius: escuchando ? 4 : 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    escuchando ? Icons.mic : Icons.mic_none_rounded,
                    size: 38,
                    color: escuchando ? Colors.white : const Color(0xFF1976D2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                analizando
                    ? 'Analizando...'
                    : escuchando
                        ? 'Escuchando...'
                        : 'Toca para hablar',
                key: ValueKey(analizando ? 'a' : escuchando ? 'e' : 'i'),
                style: TextStyle(
                  color: escuchando ? Colors.redAccent : Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
