import 'package:get/get.dart';

import '../controllers/presence_history_details_controller.dart';

class PresenceHistoryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PresenceHistoryDetailsController>(
      () => PresenceHistoryDetailsController(),
    );
  }
}
