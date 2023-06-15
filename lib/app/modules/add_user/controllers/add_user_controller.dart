import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/button.dart';
import 'package:gate/app/components/widgets/custom_snackbar.dart';
import 'package:gate/app/components/widgets/textfield.dart';
import 'package:gate/main.dart';
import 'package:get/get.dart';

import '../../../components/widgets/text_widget.dart';
import '../../../routes/app_pages.dart';

class AddUserController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  TextEditingController emailC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  String gradeC = "";
  TextEditingController fullnameC = TextEditingController();
  TextEditingController adminPassC = TextEditingController();
  TextEditingController mainSalaryC = TextEditingController();
  TextEditingController dailySalaryC = TextEditingController();
  TextEditingController allowanceSalaryC = TextEditingController();
  TextEditingController bpjsC = TextEditingController();
  TextEditingController bpjskC = TextEditingController();

  RxBool isLoading = false.obs;

  Future<void> tryAddUser() async {
    if (adminPassC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        String adminEmail = auth.currentUser!.email!;

        UserCredential userCredentialAdmin = await auth.signInWithEmailAndPassword(
          email: adminEmail,
          password: adminPassC.text,
        );

        UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: emailC.text,
          password: 'Pass@isip123',
        );

        if (userCredential.user != null) {
          String uid = userCredential.user!.uid;

          await firestore.collection('users').doc(uid).set(
            {
              "nip": nipC.text,
              "fullname": fullnameC.text,
              "email": emailC.text,
              "grade": gradeC,
              "createdAt": DateTime.now().toIso8601String(),
              "uid": uid,
              "role": "user",
            },
          );

          await firestore.collection('salary').doc(uid).set({
            'main': int.parse(mainSalaryC.text),
            'daily': int.parse(dailySalaryC.text),
            'allowance': int.parse(allowanceSalaryC.text),
            'bpjs': int.parse(bpjsC.text),
            'bpjsk': int.parse(bpjskC.text),
          });
          print("Lagi logout");
          await auth.signOut();

          print("Lagi Login");
          UserCredential userCredentialAdmin = await auth.signInWithEmailAndPassword(
            email: adminEmail,
            password: adminPassC.text,
          );
          print("${userCredentialAdmin.user!.email}");

          Get.offAllNamed(Routes.ADMIN_HOME);
          Get.showSnackbar(buildSnackSuccess("User registered successfully"));
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Get.showSnackbar(buildSnackError("Password to weak"));
        } else if (e.code == 'email-already-in-use') {
          Get.showSnackbar(
              buildSnackError("Email already in use, please contact database administrator"));
        } else if (e.code == 'wrong-password') {
          Get.showSnackbar(buildSnackError("Wrong password detected"));
        }
      } catch (e) {
        Get.showSnackbar(buildSnackError("Failed to register user, err:${e}"));
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.showSnackbar(buildSnackError("Please insert the password first"));
    }
  }

  void addUser() async {
    if (emailC.text.isNotEmpty &&
        nipC.text.isNotEmpty &&
        gradeC != "" &&
        fullnameC.text.isNotEmpty &&
        mainSalaryC.text.isNotEmpty &&
        dailySalaryC.text.isNotEmpty &&
        allowanceSalaryC.text.isNotEmpty &&
        bpjsC.text.isNotEmpty &&
        bpjskC.text.isNotEmpty) {
      Get.defaultDialog(
        title: "Admin Verification",
        titleStyle: interSemiBold.copyWith(
          color: whiteColor,
          fontSize: 14.0,
        ),
        contentPadding: EdgeInsets.all(20),
        backgroundColor: darkColor,
        content: Column(
          children: [
            RText(
              text: "Please input your password",
              textStyle: interMedium,
            ),
            SizedBox(height: 10),
            RTextField(
              hintText: "Input Admin Password",
              controller: adminPassC,
              isPassword: true,
              maxLines: 1,
            )
          ],
        ),
        actions: [
          Obx(
            () => RButton(
              color: greenColor,
              text: isLoading.isFalse ? "Add User" : "Loading..",
              callback: () async {
                if (isLoading.isFalse) {
                  await tryAddUser();
                }
              },
            ),
          ),
        ],
      );
    } else {
      Get.showSnackbar(buildSnackError("Please fill the required field"));
    }
  }
}
