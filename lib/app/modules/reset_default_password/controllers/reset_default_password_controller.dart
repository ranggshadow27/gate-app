import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class ResetDefaultPasswordController extends GetxController {
  TextEditingController newPassC = TextEditingController();
  TextEditingController confirmNewPassC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  RxBool isLoading = false.obs;

  void changePassword() async {
    if (confirmNewPassC.text.isNotEmpty || newPassC.text.isNotEmpty) {
      if (newPassC.text == confirmNewPassC.text) {
        if (confirmNewPassC != "Pass@isip123") {
          String email = auth.currentUser!.email!;
          isLoading.value = true;
          try {
            await auth.currentUser!.updatePassword(confirmNewPassC.text);

            await auth.signOut();

            await auth.signInWithEmailAndPassword(
              email: email,
              password: confirmNewPassC.text,
            );

            Get.offAllNamed(Routes.HOME);
            Get.snackbar("Success", "Password berhasil diganti");
          } on FirebaseAuthException catch (e) {
            if (e.code == "weak-password") {
              Get.snackbar("Error",
                  "Password terlalu lemah setidaknya 6 karakter kombinasi angka.");
            } else {
              Get.snackbar("Error", "Gagal mengganti password");
            }
          } finally {
            isLoading.value = false;
          }
        } else {
          Get.snackbar("Error",
              "Password baru masih default, mohon mengganti dengan password lain");
        }
      } else {
        Get.snackbar("Error", "Password tidak sama.");
      }
    } else {
      Get.snackbar("Error", "Mohon isi semua field terlebih dahulu");
    }
  }
}
