import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../components/widgets/custom_snackbar.dart';
import '../../../routes/app_pages.dart';

class ResetDefaultPasswordController extends GetxController {
  TextEditingController newPassC = TextEditingController();
  TextEditingController confirmNewPassC = TextEditingController();

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

  void changePassword() async {
    if (confirmNewPassC.text.isNotEmpty || newPassC.text.isNotEmpty) {
      if (newPassC.text == confirmNewPassC.text) {
        if (confirmNewPassC.text != "Pass@isip123") {
          String email = auth.currentUser!.email!;
          isLoading.value = true;
          try {
            await auth.currentUser!.updatePassword(confirmNewPassC.text);

            await auth.signOut();

            await auth.signInWithEmailAndPassword(
              email: email,
              password: confirmNewPassC.text,
            );

            userRole = await userCheck();
            print(userRole);

            if (userRole?['role'] == "user") {
              Get.offAllNamed(Routes.HOME);
            } else if (userRole!['role'] == "administrator") {
              Get.offAllNamed(Routes.ADMIN_HOME);
            }

            Get.showSnackbar(buildSnackSuccess("Password has been changed"));
          } on FirebaseAuthException catch (e) {
            if (e.code == "weak-password") {
              Get.showSnackbar(buildSnackError(
                  "Password to weak, please type at least 6 character with number"));
            } else {
              Get.showSnackbar(buildSnackError("Failed to change password"));
            }
          } finally {
            isLoading.value = false;
          }
        } else {
          Get.showSnackbar(buildSnackError("Please your default change password"));
        }
      } else {
        Get.showSnackbar(buildSnackError("Password doesnt match"));
      }
    } else {
      Get.showSnackbar(buildSnackError("Please fill all required fields"));
    }
  }
}
