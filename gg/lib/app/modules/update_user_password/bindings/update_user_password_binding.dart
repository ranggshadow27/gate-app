import 'package:get/get.dart';

import '../controllers/update_user_password_controller.dart';

class UpdateUserPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdateUserPasswordController>(
      () => UpdateUserPasswordController(),
    );
  }
}
