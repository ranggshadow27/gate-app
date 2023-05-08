import 'package:get/get.dart';

import '../controllers/report_add_controller.dart';

class ReportAddBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportAddController>(
      () => ReportAddController(),
    );
  }
}
