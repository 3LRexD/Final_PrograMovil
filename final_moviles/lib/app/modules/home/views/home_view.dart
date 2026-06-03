import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart';
import '../../onboarding/controllers/onboarding_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/menu_button.dart';
import '../widgets/tips_carousel.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeroSection(),
            const SizedBox(height: 20),
            TipsCarousel(),
            const SizedBox(height: 8),
            MenuButton(
              icon: Icons.medical_services_rounded,
              title: 'Primeros Auxilios',
              subtitle: 'Asistencia con cámara en tiempo real.',
              color: AppTheme.secondary,
              onTap: controller.abrirPrimerosAuxilios,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,//amarillo vibrante
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.secondary,//borde celeste abajo
            width: 4,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //icono principal
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: ShapeDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      shape: BeveledRectangleBorder(
                        side: BorderSide(color: theme.colorScheme.error, width: 2),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.local_hospital_rounded,
                      color: theme.colorScheme.error,//icono rojo
                      size: 42,
                    ),
                  ),

                  const Spacer(),

                  Tooltip(
                    message: 'Ver tutorial',
                    child: InkWell(
                      onTap: OnboardingController.resetOnboarding,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: ShapeDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          shape: BeveledRectangleBorder(
                            side: BorderSide(color: theme.colorScheme.secondary, width: 1.5),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.help_outline_rounded,
                          color: theme.colorScheme.secondary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text(
                'TRAUMA TEAM',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ASISTENCIA MÉDICA DE EMERGENCIA',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.black87,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}