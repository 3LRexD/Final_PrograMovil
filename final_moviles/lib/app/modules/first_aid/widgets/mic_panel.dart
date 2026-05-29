import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/first_aid_controller.dart';

class MicPanel extends StatefulWidget {
  const MicPanel({super.key, required this.controller});

  final FirstAidController controller;

  @override
  State<MicPanel> createState() => _MicPanelState();
}

class _MicPanelState extends State<MicPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.92, end: 1.1).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() {
        final escuchando = widget.controller.escuchando.value;
        final analizando = widget.controller.analizando.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: analizando ? null : widget.controller.toggleEscucha,
              child: ScaleTransition(
                scale: escuchando ? _scale : const AlwaysStoppedAnimation(1.0),
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
