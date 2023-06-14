import 'package:get/get.dart';

import '../controllers/dispensation_controller.dart';

class DispensationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DispensationController>(
      () => DispensationController(),
    );
  }
}
