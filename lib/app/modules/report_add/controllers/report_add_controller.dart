import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as f;

class ReportAddController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  f.FirebaseStorage storage = f.FirebaseStorage.instance;

  TextEditingController subjectC = TextEditingController();
  TextEditingController descriptionC = TextEditingController();
  TextEditingController newTypeC = TextEditingController();

  String? reportType;
  String? reportCategory;
  RxString selectedReport = "".obs;

  DateTime now = DateTime.now();
  RxBool isLoading = false.obs;

  final ImagePicker picker = ImagePicker();
  List<XFile>? images;
  List<XFile> imgs = [];

  getImage() async {
    images = await picker.pickMultiImage();

    if (images != null) {
      for (var i = 0; i < images!.length; i++) {
        imgs.add(images![i]);
      }
    }

    update();
  }

  submitImages(Map<String, dynamic> inputData) async {
    String dateFormat = DateFormat("yyMM").format(now);
    String totalData = "${await getDataLength() + 1}".padLeft(3, '0');

    String reportID = "INC-INF-$dateFormat$totalData";

    inputData.addAll({'images': []});

    for (var i = 0; i < imgs.length; i++) {
      File file = File(imgs[i].path);

      f.Reference storageRef =
          await storage.ref('report_images/$reportID/${imgs[i].name}');

      await storageRef.putFile(file);
      String imageUrl = await storageRef.getDownloadURL();

      inputData['images'].addAll([
        {
          "name": imgs[i].name,
          "url": imageUrl,
        },
      ]);
    }
  }

  Future<void> submitReport() async {
    try {
      if (subjectC.text.isNotEmpty &&
          descriptionC.text.isNotEmpty &&
          reportType != null &&
          reportCategory != null) {
        String dateFormat = DateFormat("yyMM").format(now);
        String totalData = "${await getDataLength() + 1}".padLeft(3, '0');

        String reportID = "INC-INF-$dateFormat$totalData";
        String userName = await getUserName();

        Map<String, dynamic> inputData = {
          "subject": subjectC.text,
          "description": descriptionC.text,
          "type": reportType,
          "category": reportCategory,
          "createdAt": now.toIso8601String(),
          "createdBy": userName,
          "reportID": reportID,
        };

        isLoading.value = true;

        if (imgs.isNotEmpty || images != null) {
          await submitImages(inputData);
          print(inputData);
        }

        await firestore
            .collection('operational_report')
            .doc(reportID)
            .set(inputData);

        await firestore.collection('report_log').doc(reportID).set(inputData);

        Get.back();
        images = null;
        imgs = [];

        Get.snackbar("Berhasil", "Report sudah ditambahkan");
      } else {
        Get.snackbar("Error", "Mohon isi semua data yang diperlukan");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal menambahkan report, err: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> getDataLength() async {
    String formatNow = DateFormat("yyyy-MM").format(now);
    String firstDayofMonth = "$formatNow-01T00:00:00";

    QuerySnapshot<Map<String, dynamic>> snapshotReport = await firestore
        .collection('report_log')
        .where('createdAt', isGreaterThan: firstDayofMonth)
        .where('createdAt', isLessThan: now.toIso8601String())
        .get();

    int countData = await snapshotReport.docs.length;

    return countData;
  }

  Future<String> getUserName() async {
    String uid = auth.currentUser!.uid;

    DocumentSnapshot<Map<String, dynamic>> docSnap =
        await firestore.collection('users').doc(uid).get();

    Map<String, dynamic>? data = docSnap.data();

    String userName = data!['fullname'];

    return userName;
  }

  submitNewCategory() async {
    try {
      if (newTypeC.text.isNotEmpty && reportCategory != null) {
        await firestore.collection('report_category').doc('category').update({
          '${reportCategory!.toLowerCase()}':
              FieldValue.arrayUnion([newTypeC.text]),
        });
        Get.back();
        reportCategory = null;
        newTypeC.clear();

        Get.snackbar("Berhasil", "Item berhasil ditambahkan");
      } else {
        Get.snackbar("Error", "Mohon isi semua field yang diperlukan");
      }
    } catch (e) {}
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamReportCategory() async* {
    yield* firestore.collection('report_category').doc('category').snapshots();
  }

  String? getCategory(String value, String type) {
    String getValue;

    if (type == "category") {
      getValue = value;
      reportCategory = getValue;
      print(reportCategory);
    } else {
      getValue = value;
      reportType = getValue;
      print(reportType);
    }

    return getValue;
  }

  getReportList(String type) async {
    DocumentSnapshot<Map<String, dynamic>> getData =
        await firestore.collection('report_category').doc('category').get();

    List<dynamic> reportData = getData.data()![type];

    return reportData;
  }

  updateCategory(String type) async {
    try {
      if (reportCategory != null || reportType != null) {
        isLoading.value = true;

        List<dynamic> reportData = await getReportList(type);

        int getDataIndex = reportData
            .indexOf("${type == 'category' ? reportCategory : reportType}");

        await reportData.removeAt(getDataIndex);

        await firestore.collection('report_category').doc('category').update({
          type: reportData,
        });

        Get.back();
        Get.snackbar("Berhasil",
            "${type == 'category' ? reportCategory : reportData} berhasil dihapus");

        reportType = null;
        reportCategory = null;
        selectedReport.value = "";
      } else {
        Get.snackbar(
            "Error", "Mohon untuk mengisi kategori/tipe yang ingin dihapus");
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }
}
