import 'package:get/get.dart';

import '../controllers/presence_history_controller.dart';

class PresenceHistoryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PresenceHistoryController>(
      () => PresenceHistoryController(),
    );
  }
}
