import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class AdminManageUsersController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Map<String, dynamic> userData = Get.arguments;

  Future<void> deleteUser(String userUID) async {
    await Get.defaultDialog(
      title: "Konfirmasi",
      middleText: "Ingin menghapus user ini?",
      actions: [
        OutlinedButton(
          onPressed: () => Get.back(),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            await firestore.collection('users').doc(userUID).delete();
            Get.offAllNamed(Routes.ADMIN_HOME);
            update();
            Get.snackbar("Berhasil", "User $userUID berhasil dihapus");
          },
          child: Text("Confirm"),
        ),
      ],
    );
  }
}
