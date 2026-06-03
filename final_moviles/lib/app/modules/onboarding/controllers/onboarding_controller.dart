import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_routes.dart';

class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class OnboardingController extends GetxController {
  late final PageController pageController;
  final RxInt currentPage = 0.obs;
  final List<OnboardingPage> pages = const [
    OnboardingPage(
      title: 'Primeros Auxilios al Instante',
      description: 'Entra a la app y toca el botón de "Primeros Auxilios" para iniciar la asistencia inmediata.',
      imagePath: 'assets/images/help1.png', 
    ),
    OnboardingPage(
      title: 'Análisis Inteligente',
      description: 'Usa tu cámara para enfocar la herida o el problema y se analizará la imagen al instante.',
      imagePath: 'assets/images/help2.png', 
    ),
    OnboardingPage(
      title: 'Diagnósticos y Pasos',
      description: 'Recibe instrucciones paso a paso basadas en guías oficiales para estabilizar la situación.',
      imagePath: 'assets/images/help3.png', 
    ),
  ];

  static const _kOnboardingKey = 'onboarding_completed';
  final _storage = GetStorage();

  bool get isLastPage => currentPage.value == pages.length - 1;
  int get totalPages => pages.length;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) => currentPage.value = index;

  void nextPage() {
    if (isLastPage) {
      finishOnboarding();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void skip() {
    pageController.animateToPage(
      pages.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void finishOnboarding() {
    _storage.write(_kOnboardingKey, true);
    Get.offAllNamed(AppRoutes.home); 
  }

  static bool shouldShowOnboarding() {
    final storage = GetStorage();
    return storage.read(_kOnboardingKey) != true;
  }

  static void resetOnboarding() {
    final storage = GetStorage();
    storage.remove(_kOnboardingKey);
    Get.toNamed(AppRoutes.onboarding); 
  }
}