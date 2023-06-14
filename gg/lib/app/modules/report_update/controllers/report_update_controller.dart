import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as f;
import 'package:flutter/material.dart';
import 'package:gate/app/modules/report_add/controllers/report_add_controller.dart';
import 'package:get/get.dart';
import 'package:ntp/ntp.dart';

class ReportUpdateController extends GetxController {
  final addImageC = Get.put(ReportAddController());

  final Map<String, dynamic> reportData = Get.arguments;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  f.FirebaseStorage storage = f.FirebaseStorage.instance;

  TextEditingController subjectC = TextEditingController();
  TextEditingController descriptionC = TextEditingController();

  String? reportType;
  String? reportCategory;
  String? userName;

  RxBool isUpdate = false.obs;

  Future<Map<String, dynamic>?> getCurrentImage() async {
    String reportID = reportData['reportID'];

    DocumentSnapshot<Map<String, dynamic>> getImage =
        await firestore.collection('operational_report').doc(reportID).get();

    return getImage.data();
  }

  Future<void> updateImages(Map<String, dynamic> updateData) async {
    Map<String, dynamic>? getImage = await getCurrentImage();

    print(getImage);
    print("Apakah adaaa ? ----------> ${getImage?['images']}");

    int addedImage = addImageC.imgs.length;
    String reportID = reportData['reportID'];

    List allImageData = [];

    if (getImage?['images'] != null) {
      for (var i = 0; i < getImage!['images'].length; i++) {
        allImageData
            .add({'name': getImage['images'][i]['name'], 'url': getImage['images'][i]['url']});
      }

      for (var i = 0; i < addedImage; i++) {
        File file = File(addImageC.imgs[i].path);

        f.Reference storageRef =
            await storage.ref('report_images/$reportID/${addImageC.imgs[i].name}');

        await storageRef.putFile(file);
        String imageUrl = await storageRef.getDownloadURL();

        allImageData.add({"name": addImageC.imgs[i].name, 'url': imageUrl});

        updateData.addAll({'images': allImageData});
        print("--------------> Logic ketika images tidak null dijalankan");
      }
    } else {
      for (var i = 0; i < addedImage; i++) {
        updateData.addAll({'images': []});
        File file = File(addImageC.imgs[i].path);

        f.Reference storageRef =
            await storage.ref('report_images/$reportID/${addImageC.imgs[i].name}');

        await storageRef.putFile(file);
        String imageUrl = await storageRef.getDownloadURL();

        allImageData.add({"name": addImageC.imgs[i].name, 'url': imageUrl});

        updateData.addAll({'images': allImageData});
        print("--------------> Logic ketika images == null dijalankan");
      }
    }
  }

  updateReport() async {
    DateTime now = await NTP.now(
      lookUpAddress: "time.windows.com",
      timeout: Duration(seconds: 5),
    );

    String reportID = reportData['reportID'];
    userName = await getActiveUser();

    Map<String, dynamic> updateData = {
      "subject": subjectC.text,
      "description": descriptionC.text,
      "type": reportType == null ? reportData['type'] : reportType,
      "category": reportCategory == null ? reportData['category'] : reportCategory,
      "updateAt": now.toIso8601String(),
      "updateBy": userName,
    };

    if (addImageC.imgs.isNotEmpty || addImageC.images != null) {
      await updateImages(updateData);
      print("Hasil dari update data dijalankan");
    }

    print("Hasil dari update data tanpa img");

    Get.back();
    addImageC.images = null;
    addImageC.imgs = [];

    await firestore.collection('operational_report').doc(reportID).update(updateData);

    Get.snackbar("Berhasil", "Report ID : ${reportID} berhasil diperbarui");
  }

  Future<String> getActiveUser() async {
    String uid = auth.currentUser!.uid;

    DocumentSnapshot<Map<String, dynamic>> getDataUser =
        await firestore.collection('users').doc(uid).get();

    Map<String, dynamic>? dataUser = getDataUser.data();

    String userActive = dataUser!['fullname'];

    return userActive;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamReportData() async* {
    String reportID = reportData['reportID'];

    yield* firestore.collection('operational_report').doc(reportID).snapshots();
  }

  deleteImage(String imgName, String imgUrl) async {
    String reportID = reportData['reportID'];
    DocumentReference imageDoc = firestore.collection('operational_report').doc(reportID);

    try {
      await imageDoc.update({
        'images': FieldValue.arrayRemove([
          {
            'name': imgName,
            'url': imgUrl,
          }
        ])
      });

      f.Reference imageRef = storage.refFromURL(imgUrl);
      await imageRef.delete();
    } catch (e) {
      Get.snackbar("Error", "Gambar gagal dihapus, err: {$e}");
    }
  }
}
