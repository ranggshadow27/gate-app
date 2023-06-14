import 'package:get/get.dart';

import '../controllers/update_user_profile_controller.dart';

class UpdateUserProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdateUserProfileController>(
      () => UpdateUserProfileController(),
    );
  }
}
