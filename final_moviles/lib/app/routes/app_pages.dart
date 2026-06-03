import 'package:get/get.dart';

import '../modules/first_aid/bindings/first_aid_binding.dart';
import '../modules/first_aid/views/first_aid_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/first_aid/views/ml_error_view.dart';
import 'app_routes.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';

abstract class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.onboarding, 
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fade, 
    ),
    
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    
    GetPage(
      name: AppRoutes.firstAid,
      page: () => const FirstAidView(),
      binding: FirstAidBinding(),
    ),
    
    GetPage(
      name: AppRoutes.mlError,
      page: () => const MlErrorView(),
    ),
  ];
}