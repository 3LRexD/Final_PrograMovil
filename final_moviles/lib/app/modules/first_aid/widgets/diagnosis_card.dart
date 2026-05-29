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
        return const Color(0xFFE53935);
      case 'media':
        return const Color(0xFFFF8F00);
      default:
        return const Color(0xFF43A047);
    }
  }

  String get _etiqueta {
    switch (diagnostico.urgencia) {
      case 'alta':
        return 'Urgencia alta';
      case 'media':
        return 'Urgencia media';
      default:
        return 'Urgencia baja';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _abrirDetalle(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diagnostico.causa,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Toca para ver el tratamiento',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.grey),
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
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
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
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    etiqueta,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: Get.find<FirstAidController>().pararAudio,
                  icon: const Icon(Icons.stop_rounded, size: 16),
                  label: const Text('Detener audio'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    textStyle: const TextStyle(fontSize: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              diagnostico.causa,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              diagnostico.descripcion,
              style: const TextStyle(
                  fontSize: 14, color: Colors.black54, height: 1.5),
            ),

            //transcripcion del microfono si existe
            if (transcripcion != null && transcripcion!.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Lo que describiste',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '"$transcripcion"',
                  style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54),
                ),
              ),
            ],

            const SizedBox(height: 24),
            const Text(
              'Tratamiento sugerido',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              diagnostico.tratamiento,
              style: const TextStyle(fontSize: 14, height: 1.7),
            ),
            const SizedBox(height: 28),
            Text(
              'Esta información es orientativa. Si los síntomas persisten o empeoran, consulta a un médico.',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
