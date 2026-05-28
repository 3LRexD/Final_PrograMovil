import 'package:flutter/material.dart';

class PermissionMessage extends StatelessWidget {
  const PermissionMessage({
    super.key,
    required this.icono,
    required this.titulo,
    required this.mensaje,
    required this.onAccion,
    required this.textoAccion,
  });

  final IconData icono;
  final String titulo;
  final String mensaje;
  final VoidCallback onAccion;
  final String textoAccion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onAccion, child: Text(textoAccion)),
          ],
        ),
      ),
    );
  }
}
