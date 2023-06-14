import 'package:get/get.dart';

import '../controllers/report_update_controller.dart';

class ReportUpdateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportUpdateController>(
      () => ReportUpdateController(),
    );
  }
}
