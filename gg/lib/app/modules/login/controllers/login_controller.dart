import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/button.dart';
import 'package:gate/app/components/widgets/text_widget.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;
  Map<String, dynamic>? userRole;

  Future userCheck() async {
    String uid = auth.currentUser!.uid;

    DocumentSnapshot<Map<String, dynamic>> getUserRole =
        await firestore.collection('users').doc(uid).get();

    return getUserRole.data();
  }

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
            userRole = await userCheck();
            if (userRole == null) {
              auth.signOut();
              Get.snackbar("Error", "User tidak terdaftar");
            } else {
              if (passC.text == "Pass@isip123") {
                Get.snackbar("Ganti Password Default",
                    "Untuk keamanan akun dimohon untuk mengganti password default.");
                Get.offAllNamed(Routes.RESET_DEFAULT_PASSWORD);
              } else {
                Get.snackbar("Sukses", "Berhasil Login");
                if (userRole?['role'] == "user" || userRole?['role'] == null) {
                  Get.offAllNamed(Routes.HOME);
                } else {
                  Get.offAllNamed(Routes.ADMIN_HOME);
                }
              }
            }
          } else {
            auth.signOut();
            Get.defaultDialog(
              backgroundColor: bgColor,
              title: "Your Email is Unverified!",
              middleText: "Please send email verification below to continue access your account.",
              titleStyle: interSemiBold.copyWith(color: redColor),
              middleTextStyle: interRegular.copyWith(color: whiteColor, fontSize: 14.0),
              titlePadding: EdgeInsets.symmetric(vertical: 20),
              contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              confirm: RButton(
                color: greenColor,
                text: "Send Verification",
                height: 48,
                width: Get.width,
                callback: () async {
                  try {
                    await userCredential.user!.sendEmailVerification();
                    Get.back();
                    Get.snackbar(
                        "Berhasil", "Email verifikasi terkirim, silahkan cek email masuk/spam.");
                  } catch (e) {
                    Get.back();
                    Get.snackbar("Error", "Tidak dapat mengirim email verifikasi, err: {$e}");
                  }
                },
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
        print("${e}");
        Get.snackbar("Error", "Gagal login, err ${e}");
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar("Error", "Mohon isi semua field terlebih dahulu");
    }
  }
}
