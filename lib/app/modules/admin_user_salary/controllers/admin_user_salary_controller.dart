import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:gate/app/components/widgets/custom_snackbar.dart';
import 'package:get/get.dart';

class AdminUserSalaryController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String uid = Get.arguments;
  var map = {}.obs;
  RxBool isLoading = false.obs;

  TextEditingController mainSalaryC = TextEditingController();
  TextEditingController dailySalaryC = TextEditingController();
  TextEditingController allowanceSalaryC = TextEditingController();
  TextEditingController bpjsC = TextEditingController();
  TextEditingController bpjskC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getUserSalary();
  }

  getUserSalary() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection('salary').doc(uid).get();

    map.value = snapshot.data()!;

    return map;
  }

  updateUserSalary() async {
    try {
      if (mainSalaryC.text.isNotEmpty &&
          dailySalaryC.text.isNotEmpty &&
          allowanceSalaryC.text.isNotEmpty &&
          bpjsC.text.isNotEmpty &&
          bpjskC.text.isNotEmpty) {
        isLoading.value = true;
        await firestore.collection('salary').doc(uid).update({
          'main': int.parse(mainSalaryC.text),
          'daily': int.parse(dailySalaryC.text),
          'allowance': int.parse(allowanceSalaryC.text),
          'bpjs': int.parse(bpjsC.text),
          'bpjsk': int.parse(bpjskC.text),
        });

        Get.back();
        Get.showSnackbar(buildSnackSuccess("Salary info updated successfully"));
      } else {
        Get.showSnackbar(buildSnackError("Please fill all the required field"));
      }
    } catch (e) {
      Get.showSnackbar(buildSnackError("Failed to Update Salary Info, err: $e"));
    } finally {
      isLoading.value = false;
    }
  }
}
