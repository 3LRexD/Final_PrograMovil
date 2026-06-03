import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/modules/onboarding/controllers/onboarding_controller.dart'; 
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await GetStorage.init();
  await dotenv.load(fileName: '.env');
  runApp(const AsistenteApp()); 
}

class AsistenteApp extends StatelessWidget {
  const AsistenteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final String rutaInicial = OnboardingController.shouldShowOnboarding()
        ? AppRoutes.onboarding
        : AppRoutes.home;
    return GetMaterialApp(
      title: 'Trauma Team',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cyberpunk, 
      initialRoute: rutaInicial, 
      getPages: AppPages.pages, 
    );
  }
}