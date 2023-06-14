import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
        Get.snackbar('Berhasil',
            "Link reset Password terkirim, silahkan cek Email/Spam");
      } on FirebaseAuthException catch (e) {
        if (e.code == "user-not-found") {
          Get.snackbar('Error', "Email tidak terdaftar.");
        } else {
          Get.snackbar(
              'Error', "Gagal mengirim link reset Password, \nerr: ${e.code}");
        }
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar("Error", "Mohon isi field email terlebih dahulu");
    }
  }
}