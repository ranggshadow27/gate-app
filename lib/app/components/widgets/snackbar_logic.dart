import 'package:get/get.dart';

final countSnackbar = 0.obs;

limitSnackbar(GetSnackBar snackbar) async {
  if (countSnackbar.value < 1) {
    countSnackbar.value++;
    Get.showSnackbar(snackbar);
    await Future.delayed(
      Duration(seconds: 3),
      () {
        countSnackbar.value = 0;
      },
    );
  }
}
