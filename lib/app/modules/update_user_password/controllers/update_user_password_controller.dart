import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/widgets/custom_snackbar.dart';
import 'package:get/get.dart';

class UpdateUserPasswordController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  TextEditingController newPassC = TextEditingController();
  TextEditingController confirmPassC = TextEditingController();
  TextEditingController oldPassC = TextEditingController();

  RxBool isLoading = false.obs;

  updatePassword() async {
    if (newPassC.text.isNotEmpty && confirmPassC.text.isNotEmpty && oldPassC.text.isNotEmpty) {
      if (newPassC.text != "Pass@isip123") {
        if (newPassC.text == confirmPassC.text) {
          isLoading.value = true;
          try {
            String getEmailUser = auth.currentUser!.email!;

            await auth.signInWithEmailAndPassword(
              email: getEmailUser,
              password: oldPassC.text,
            );

            await auth.currentUser!.updatePassword(confirmPassC.text);

            Get.back();
            Get.showSnackbar(buildSnackSuccess("Password updated successfully"));
          } on FirebaseAuthException catch (e) {
            if (e.code == "weak-password") {
              Get.showSnackbar(buildSnackError("Password to short"));
            } else if (e.code == "weak-password") {
              Get.showSnackbar(buildSnackError("Password to weak, type at least 6 characters"));
            } else {
              Get.showSnackbar(buildSnackError("Failed to update password, err: ${e.code}"));
            }
          } finally {
            isLoading.value = false;
          }
        } else {
          Get.showSnackbar(buildSnackError("New Password doesnt match"));
        }
      } else {
        Get.showSnackbar(
            buildSnackError("Default password is not allowed, please change to other password"));
      }
    } else {
      Get.showSnackbar(buildSnackError("Please fill all required fields"));
    }
  }
}
