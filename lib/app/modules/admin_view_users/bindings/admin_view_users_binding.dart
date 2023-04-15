import 'package:get/get.dart';

import '../controllers/admin_view_users_controller.dart';

class AdminViewUsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminViewUsersController>(
      () => AdminViewUsersController(),
    );
  }
}
