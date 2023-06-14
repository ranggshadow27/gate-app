import 'package:get/get.dart';

import '../controllers/admin_user_presence_history_controller.dart';

class AdminUserPresenceHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminUserPresenceHistoryController>(
      () => AdminUserPresenceHistoryController(),
    );
  }
}
