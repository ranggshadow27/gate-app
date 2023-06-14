import 'package:flutter/material.dart';
import 'package:gate/app/modules/dispensation_add/controllers/api_services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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
      return Get.snackbar("Error", "Mohon untuk mengisi tipe dispensasi");
    }
    if (subjectC.text.isEmpty || descC.text.isEmpty) {
      return Get.snackbar("Error", "Mohon untuk mengisi semua kolom yang ada");
    }

    Get.defaultDialog(
      title: "Konfirmasi",
      middleText:
          "Anda yakin untuk mengajukan dispensasi dengan keterangan $dispensationType?",
      actions: [
        OutlinedButton(onPressed: () => Get.back(), child: Text("Kembali")),
        ElevatedButton(
          onPressed: () async {
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
              Get.snackbar("Berhasil",
                  "Dispensasi $dispensationType berhasil ditambahkan");
            } on FormatException catch (e) {
            } finally {
              isLoading.value = false;
            }
          },
          child: Text("Konfirmasi"),
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
    if (image != null) {
      print("Ini pathnya : ${image!.path}");
      print("Ini namenya : ${image!.name}");
    }
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
