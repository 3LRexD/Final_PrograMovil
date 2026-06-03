import 'package:get/get.dart';

import '../../../services/sintoma_service.dart';
import '../../../services/llm_service.dart';
import '../controllers/first_aid_controller.dart';

class FirstAidBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LlmService());
    Get.lazyPut(() => FirstAidController(
          sintomas: MockSintomaService(),
        ));
  }
}
