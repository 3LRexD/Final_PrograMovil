import 'package:flutter/material.dart';

import '../controllers/first_aid_controller.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({
    super.key,
    required this.modoActual,
    required this.onCambiar,
  });

  final Modo modoActual;
  final void Function(Modo) onCambiar;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Stack(
        children: [
          //burbuja deslizante
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            alignment: modoActual == Modo.camara
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(19),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          //tabs encima, llenando todo el espacio
          Positioned.fill(
            child: Row(
              children: [
                _Tab(
                  icon: Icons.camera_alt_rounded,
                  label: 'Cámara',
                  activo: modoActual == Modo.camara,
                  onTap: () => onCambiar(Modo.camara),
                ),
                _Tab(
                  icon: Icons.mic_rounded,
                  label: 'Micrófono',
                  activo: modoActual == Modo.microfono,
                  onTap: () => onCambiar(Modo.microfono),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.activo,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = activo ? Colors.black87 : Colors.white70;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: activo ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
