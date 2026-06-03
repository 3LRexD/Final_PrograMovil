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
    final theme = Theme.of(context);
    return Container(
      height: 46,
      decoration: ShapeDecoration(
        color: theme.colorScheme.surface,
        shape: const BeveledRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          ),
        ),
        shadows: [
          BoxShadow(
            color: theme.colorScheme.secondary.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
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
                decoration: ShapeDecoration(
                  color: theme.colorScheme.primary,
                  shape: const BeveledRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
          //tabs encima llenando todo el espacio
          Positioned.fill(
            child: Row(
              children: [
                _Tab(
                  icon: Icons.camera_alt_rounded,
                  label: 'Cámara',
                  activo: modoActual == Modo.camara,
                  onTap: () => onCambiar(Modo.camara),
                  theme: theme,
                ),
                _Tab(
                  icon: Icons.mic_rounded,
                  label: 'Micrófono',
                  activo: modoActual == Modo.microfono,
                  onTap: () => onCambiar(Modo.microfono),
                  theme: theme,
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
    required this.theme,
  });

  final IconData icon;
  final String label;
  final bool activo;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final color = activo ? Colors.black : theme.colorScheme.secondary;
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
