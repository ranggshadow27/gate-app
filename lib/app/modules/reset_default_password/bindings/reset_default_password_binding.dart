import 'package:get/get.dart';

import '../controllers/reset_default_password_controller.dart';

class ResetDefaultPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResetDefaultPasswordController>(
      () => ResetDefaultPasswordController(),
    );
  }
}
