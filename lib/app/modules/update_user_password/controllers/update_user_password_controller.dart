import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateUserPasswordController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  TextEditingController newPassC = TextEditingController();
  TextEditingController confirmPassC = TextEditingController();
  TextEditingController oldPassC = TextEditingController();

  RxBool isLoading = false.obs;

  updatePassword() async {
    if (newPassC.text.isNotEmpty &&
        confirmPassC.text.isNotEmpty &&
        oldPassC.text.isNotEmpty) {
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
            Get.snackbar("Sukses", "Berhasil memperbarui password.");
          } on FirebaseAuthException catch (e) {
            if (e.code == "weak-password") {
              Get.snackbar("Error", "Password terlalu pendek.");
            } else if (e.code == "weak-password") {
              Get.snackbar("Error", "Password lama salah.");
            } else {
              Get.snackbar(
                  "Error", "Gagal memperbarui password, err: ${e.code}.");
            }
          } finally {
            isLoading.value = false;
          }
        } else {
          Get.snackbar("Error", "Password baru tidak sesuai.");
        }
      } else {
        Get.snackbar("Error",
            "Mohon untuk tidak menggunakan password default pada password baru.");
      }
    } else {
      Get.snackbar("Error", "Mohon untuk mengisi semua field.");
    }
  }
}
