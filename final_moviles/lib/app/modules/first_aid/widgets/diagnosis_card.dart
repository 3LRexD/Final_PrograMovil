import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/sintoma_service.dart';
import '../controllers/first_aid_controller.dart';

class DiagnosisCard extends StatelessWidget {
  const DiagnosisCard({
    super.key,
    required this.diagnostico,
    this.transcripcion,
  });

  final Diagnostico diagnostico;
  final String? transcripcion;

  Color get _color {
    switch (diagnostico.urgencia) {
      case 'alta':
        return const Color(0xFFFF0033);//rojo neon
      case 'media':
        return const Color(0xFFF3E600);//amarillo neon
      default:
        return const Color(0xFF00E6E6);//celeste neon
    }
  }

  String get _etiqueta {
    switch (diagnostico.urgencia) {
      case 'alta':
        return 'URGENCIA ALTA';
      case 'media':
        return 'URGENCIA MEDIA';
      default:
        return 'URGENCIA BAJA';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _abrirDetalle(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: ShapeDecoration(
          color: theme.colorScheme.surface,
          shape: BeveledRectangleBorder(
            side: BorderSide(color: _color, width: 1.5),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: _color, shape: BoxShape.rectangle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diagnostico.causa.toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Toca para ver el tratamiento',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  void _abrirDetalle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetalleSheet(
        diagnostico: diagnostico,
        color: _color,
        etiqueta: _etiqueta,
        transcripcion: transcripcion,
      ),
    );
  }
}

class _DetalleSheet extends StatelessWidget {
  const _DetalleSheet({
    required this.diagnostico,
    required this.color,
    required this.etiqueta,
    this.transcripcion,
  });

  final Diagnostico diagnostico;
  final Color color;
  final String etiqueta;
  final String? transcripcion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scroll) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
          border: Border(top: BorderSide(color: color, width: 3)),
        ),
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    border: Border.all(color: color, width: 1),
                  ),
                  child: Text(
                    etiqueta,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        fontSize: 12),
                  ),
                ),
                const Spacer(),
                Obx(() {
                  final hablando = Get.find<FirstAidController>().hablando.value;
                  return TextButton.icon(
                    onPressed: Get.find<FirstAidController>().toggleAudio,
                    icon: Icon(hablando ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 16),
                    label: Text(hablando ? 'DETENER AUDIO' : 'REPRODUCIR AUDIO'),
                    style: TextButton.styleFrom(
                      foregroundColor: hablando ? theme.colorScheme.error : theme.colorScheme.primary,
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              diagnostico.causa.toUpperCase(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              diagnostico.descripcion,
              style: const TextStyle(
                  fontSize: 15, color: Colors.white70, height: 1.5),
            ),

            if (transcripcion != null && transcripcion!.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'ENTRADA REGISTRADA',
                style:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1.0),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  border: Border(left: BorderSide(color: theme.colorScheme.secondary, width: 3)),
                ),
                child: Text(
                  '"$transcripcion"',
                  style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70),
                ),
              ),
            ],

            const SizedBox(height: 24),
            const Text(
              'TRATAMIENTO RECOMENDADO',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1.0),
            ),
            const SizedBox(height: 10),
            Text(
              diagnostico.tratamiento,
              style: const TextStyle(fontSize: 15, height: 1.7, color: Colors.white),
            ),
            const SizedBox(height: 32),
            Text(
              'ADVERTENCIA: Esta información es orientativa. Busque asistencia médica profesional inmediatamente si los síntomas persisten.',
              style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

