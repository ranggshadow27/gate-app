import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  RxBool isLoading = false.obs;

  Future<void> login() async {
    if (emailC.text.isNotEmpty && passC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: emailC.text,
          password: passC.text,
        );

        if (userCredential.user != null) {
          if (userCredential.user!.emailVerified != false) {
            if (passC.text == "Pass@isip123") {
              Get.snackbar("Ganti Password Default",
                  "Untuk keamanan akun dimohon untuk mengganti password default.");
              Get.offAllNamed(Routes.RESET_DEFAULT_PASSWORD);
            } else {
              Get.snackbar("Sukses", "Berhasil Login");
              Get.offAllNamed(Routes.HOME);
            }
          } else {
            Get.defaultDialog(
              title: "Email Belum Terverifikasi",
              middleText: "Mohon untuk memverifikasi email terlebih dahulu.",
              confirm: ElevatedButton(
                onPressed: () async {
                  try {
                    await userCredential.user!.sendEmailVerification();
                    Get.back();
                    Get.snackbar("Berhasil",
                        "Email verifikasi terkirim, silahkan cek email masuk/spam.");
                  } catch (e) {
                    Get.back();
                    Get.snackbar("Error",
                        "Tidak dapat mengirim email verifikasi, err: {$e}");
                  }
                },
                child: Text("Kirim Verifikasi"),
              ),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == "user-not-found") {
          Get.snackbar("Error", "Mohon maaf user tidak ditemukan");
        } else if (e.code == "wrong-password") {
          Get.snackbar("Error", "Password yang dimasukan salah");
        } else {
          Get.snackbar("Error", "Tidak dapat melakukan login, err ${e.code}");
        }
      } catch (e) {
        Get.snackbar("Error", "Gagal login, err ${e}");
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar("Error", "Mohon isi semua field terlebih dahulu");
    }
  }
}
