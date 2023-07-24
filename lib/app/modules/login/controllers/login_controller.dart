import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/button.dart';
import 'package:gate/app/components/widgets/custom_snackbar.dart';
import 'package:gate/app/components/widgets/snackbar_logic.dart';
import 'package:get/get.dart';

import '../../../controllers/page_setup_controller.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final pageController = Get.find<PageSetupController>();

  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;
  RxBool isSentVerification = false.obs;
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
              limitSnackbar(buildSnackError("User not found"));
            } else {
              if (passC.text == "Pass@isip123") {
                limitSnackbar(buildSnack("Change Default Password",
                    "For your account safety, please to change the default password."));

                Get.offAllNamed(Routes.RESET_DEFAULT_PASSWORD);
              } else {
                limitSnackbar(
                  buildSnackSuccess("Login Succeed"),
                );

                if (userRole?['role'] == "user" || userRole?['role'] == null) {
                  pageController.visitPage(0);
                  Get.offAllNamed(Routes.HOME);
                } else {
                  Get.offAllNamed(Routes.ADMIN_HOME);
                }
              }
            }
          } else {
            auth.signOut();

            await Get.defaultDialog(
              backgroundColor: bgColor,
              title: "Your Email is Unverified!",
              middleText: "Please send email verification below to continue access your account.",
              titleStyle: interSemiBold.copyWith(color: redColor),
              middleTextStyle: interRegular.copyWith(color: whiteColor, fontSize: 14.0),
              titlePadding: EdgeInsets.symmetric(vertical: 20),
              contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              confirm: Obx(
                () => RButton(
                  color: greenColor,
                  text: isSentVerification.isFalse ? "Send Verification" : "Sending Mail ..",
                  height: 48,
                  width: Get.width,
                  callback: () async {
                    isSentVerification.value = true;
                    try {
                      await auth.signInWithEmailAndPassword(
                        email: emailC.text,
                        password: passC.text,
                      );
                      await userCredential.user!.sendEmailVerification();
                      Get.back();
                      limitSnackbar(buildSnackSuccess(
                          "Verification Mail has been sent, please check your inbox/spam"));
                    } catch (e) {
                      Get.back();
                      limitSnackbar(
                          buildSnackError("Failed to send the verification mail, err ${e}"));
                    } finally {
                      isSentVerification.value = false;
                    }
                  },
                ),
              ),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == "user-not-found") {
          limitSnackbar(buildSnackError("User not found"));
        } else if (e.code == "wrong-password") {
          limitSnackbar(buildSnackError("Please check your email&password"));
        } else {
          limitSnackbar(buildSnackError("Login Failed, err ${e.code}"));
        }
      } catch (e) {
        print("${e}");
        limitSnackbar(buildSnackError("Login Failed, err ${e}"));
      } finally {
        isLoading.value = false;
      }
    } else {
      limitSnackbar(buildSnackError("Please fill all required field"));
    }
  }
}
