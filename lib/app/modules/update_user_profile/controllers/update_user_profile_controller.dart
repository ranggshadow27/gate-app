import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/widgets/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;

import '../../../components/widgets/snackbar_logic.dart';

class UpdateUserProfileController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  fStorage.FirebaseStorage storage = fStorage.FirebaseStorage.instance;

  TextEditingController emailC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  TextEditingController gradeC = TextEditingController();
  TextEditingController fullnameC = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool isAvatarDelete = false.obs;

  final ImagePicker picker = ImagePicker();
  XFile? image;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  void getImage() async {
    image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      image;
    } else {}
    update();
  }

  Future<void> updateAvatar({required inputData}) async {
    File file = File(image!.path);
    String ext = image!.name.split(".").last;

    await storage.ref('users_avatar/$uid/${uid}_av.$ext').putFile(file);

    String imageURL = await storage.ref('users_avatar/$uid/${uid}_av.$ext').getDownloadURL();

    inputData.addAll({"avatar": imageURL});
  }

  Future<void> updateProfile() async {
    Map<String, dynamic> inputData = {
      'fullname': fullnameC.text,
      "nip": nipC.text,
      "grade": gradeC.text,
    };

    if (emailC.text.isNotEmpty &&
        nipC.text.isNotEmpty &&
        gradeC.text.isNotEmpty &&
        fullnameC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        if (image != null) {
          await updateAvatar(inputData: inputData);
        }

        await firestore.collection('users').doc(uid).update(inputData);
        image = null;

        Get.back();
        limitSnackbar(buildSnackSuccess("Profile updated successfully"));
      } catch (e) {
        limitSnackbar(buildSnackError("Failed to update profile, err: $e"));
      } finally {
        isLoading.value = false;
      }
    } else {
      limitSnackbar(buildSnackError("Please fill the required field"));
    }
  }

  Future<void> deleteAvatar() async {
    isAvatarDelete.value = true;
    try {
      await firestore.collection('users').doc(uid).update({
        "avatar": FieldValue.delete(),
      });
      Get.back();
      limitSnackbar(buildSnackSuccess("Avatar deleted"));
    } catch (e) {
      limitSnackbar(buildSnackError("Failed to delete avatar, err: $e"));
    } finally {
      isAvatarDelete.value = false;
      update();
    }
  }
}
