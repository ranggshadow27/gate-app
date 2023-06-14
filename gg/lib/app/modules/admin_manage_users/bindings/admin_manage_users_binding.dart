import 'package:get/get.dart';

import '../controllers/admin_manage_users_controller.dart';

class AdminManageUsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminManageUsersController>(
      () => AdminManageUsersController(),
    );
  }
}
