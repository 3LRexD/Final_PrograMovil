import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MlErrorView extends StatelessWidget {
  const MlErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error de Conexión'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off,
                size: 80,
                color: tema.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Fallo al conectar con la API',
                style: tema.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: tema.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'No se pudo conectar con el servidor de inteligencia artificial para procesar el diagnóstico. Por favor, intente de nuevo más tarde o verifique su conexión a internet.',
                style: tema.textTheme.bodyLarge?.copyWith(
                  color: tema.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
