import 'package:flutter/material.dart';

import '../../../services/ml_service.dart';

class ResultPanel extends StatelessWidget {
  const ResultPanel({super.key, required this.resultado, required this.cargando});

  final MlResult? resultado;
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Análisis', style: theme.textTheme.titleMedium),
                const Spacer(),
                if (cargando)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const Divider(),
            if (resultado == null)
              const Text('Apunta la cámara hacia la lesión o escena para comenzar.')
            else ...[
              Text(
                resultado!.titulo,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (resultado!.confianza != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Confianza: ${(resultado!.confianza! * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              Text(resultado!.descripcion, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
