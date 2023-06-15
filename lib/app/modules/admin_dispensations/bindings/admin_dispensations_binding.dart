import 'package:get/get.dart';

import '../controllers/admin_dispensations_controller.dart';

class AdminDispensationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminDispensationsController>(
      () => AdminDispensationsController(),
    );
  }
}
