import 'package:get/get.dart';

import '../controllers/dispensation_add_controller.dart';

class DispensationAddBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DispensationAddController>(
      () => DispensationAddController(),
    );
  }
}
