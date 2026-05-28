import 'package:get/get.dart';

import '../modules/first_aid/bindings/first_aid_binding.dart';
import '../modules/first_aid/views/first_aid_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final pages = <GetPage>[
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
  ];
}
