import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/widgets/custom_snackbar.dart';
import 'package:gate/app/components/widgets/snackbar_logic.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  TextEditingController emailC = TextEditingController();
  RxBool isLoading = false.obs;
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> forgotPassword() async {
    if (emailC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        await auth.sendPasswordResetEmail(email: emailC.text);
        Get.back();
        limitSnackbar(buildSnackSuccess(
            "Reset link has been sent to your email, please check your mail inbox/spam"));
      } on FirebaseAuthException catch (e) {
        if (e.code == "user-not-found") {
          limitSnackbar(buildSnackError("Email not registered"));
        } else {
          limitSnackbar(buildSnackError("Failed to send reset password link, err: ${e.code}"));
        }
      } finally {
        isLoading.value = false;
      }
    } else {
      limitSnackbar(buildSnackError("Please fill the required field"));
    }
  }
}
