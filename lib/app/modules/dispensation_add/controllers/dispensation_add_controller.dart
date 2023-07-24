import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/custom_snackbar.dart';
import 'package:gate/app/modules/dispensation_add/controllers/api_services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../components/widgets/button.dart';
import '../../../components/widgets/snackbar_logic.dart';
import '../../../components/widgets/text_widget.dart';

class DispensationAddController extends GetxController {
  final ApiService apiService = ApiService();
  final ImagePicker imagePicker = ImagePicker();

  RxBool isLoading = false.obs;
  TextEditingController subjectC = TextEditingController();
  TextEditingController descC = TextEditingController();

  DateTime now = DateTime.now();
  String? dispensationType;
  String? currentUserUid;
  XFile? image;

  submitDispensation() async {
    if (dispensationType == null) {
      return limitSnackbar(buildSnackError("Please select Dispensation Type"));
    }
    if (subjectC.text.isEmpty || descC.text.isEmpty) {
      return limitSnackbar(buildSnackError("Please fill the required fields"));
    }

    Get.defaultDialog(
      title: "Confirm",
      middleText: "Insert dispensation data with reason of : $dispensationType?",
      titleStyle: interSemiBold,
      middleTextStyle: interMedium,
      contentPadding: EdgeInsets.all(20),
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: borderColor,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => Get.back(),
          child: RText(
            text: "Back",
            textStyle: interMedium,
            color: borderColor,
          ),
        ),
        RButton(
          height: 40,
          width: 100,
          color: greenColor,
          text: "Confirm",
          callback: () async {
            isLoading.value = true;
            Get.back();
            showLoadingDialog();
            try {
              await apiService.submitDispensation(
                type: dispensationType!,
                subject: subjectC.text,
                description: descC.text,
                dateTime: now.toIso8601String(),
                imageFile: image,
              );

              image = null;

              Get.back();
              Get.back();

              limitSnackbar(buildSnackSuccess("Dispensation $dispensationType successfully added"));
            } on FormatException catch (e) {
            } finally {
              isLoading.value = false;
            }
          },
        ),
      ],
    );
  }

  getActiveUid() async {
    currentUserUid = await apiService.getCurrentUserUid();
    print("This is : $currentUserUid");
  }

  getImage() async {
    image = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (image != null) {}
    update();
  }

  showLoadingDialog() {
    Get.dialog(Dialog(
      child: IntrinsicHeight(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Loading, Please wait .."),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
