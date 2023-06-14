import 'package:get/get.dart';

import '../controllers/dispensation_details_controller.dart';

class DispensationDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DispensationDetailsController>(
      () => DispensationDetailsController(),
    );
  }
}
