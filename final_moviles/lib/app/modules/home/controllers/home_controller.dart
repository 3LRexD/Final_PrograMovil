import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class HomeController extends GetxController {
  void abrirPrimerosAuxilios() {
    Get.toNamed(AppRoutes.firstAid);
  }

  void abrirNavegacion() {
    Get.snackbar(
      'Próximamente',
      'El módulo de navegación aún no está disponible.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
