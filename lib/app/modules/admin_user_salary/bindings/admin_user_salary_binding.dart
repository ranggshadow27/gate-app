import 'package:get/get.dart';

import '../controllers/admin_user_salary_controller.dart';

class AdminUserSalaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminUserSalaryController>(
      () => AdminUserSalaryController(),
    );
  }
}
