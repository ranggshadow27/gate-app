import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/custom_snackbar.dart';
import 'package:get/get.dart';

import '../../../components/widgets/text_widget.dart';
import '../../../routes/app_pages.dart';

class AdminManageUsersController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Map<String, dynamic> userData = Get.arguments;

  Future<void> deleteUser(String userUID) async {
    await Get.defaultDialog(
      title: "Confirm",
      middleText: "Are you sure to delete this user?",
      titleStyle: interSemiBold.copyWith(fontSize: 16.0),
      middleTextStyle: interMedium,
      contentPadding: EdgeInsets.all(20),
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: darkColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => Get.back(),
          child: RText(text: "Cancel", textStyle: interMedium, color: bgColor),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: greenColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () async {
            await firestore.collection('users').doc(userUID).delete();
            Get.offAllNamed(Routes.ADMIN_HOME);
            update();
            Get.showSnackbar(buildSnackSuccess("User $userUID deleted successfully"));
          },
          child: RText(text: "Confirm", textStyle: interMedium, color: whiteColor),
        ),
      ],
    );
  }
}
