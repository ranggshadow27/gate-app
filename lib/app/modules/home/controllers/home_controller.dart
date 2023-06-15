import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';

class HomeController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final imagePicker = ImagePicker();
  final faceDetector = FaceDetector(options: FaceDetectorOptions());

  XFile? image;
  RxString realTimeDate = "Loading..".obs;
  RxString realTimeHour = "Loading..".obs;

  Timer? timer;

  @override
  void onInit() async {
    super.onInit();
    getTodayDate();
  }

  pickImage() async {
    image = await imagePicker.pickImage(
      source: ImageSource.camera,
    );

    showLoading();

    if (image != null) {
      print("This is your image path : ${image!.path}");
      try {
        List<Face> face = await detectFaces(image!.path);
        Get.back();

        if (face.isNotEmpty) {
          Get.defaultDialog(
            middleText: "Anjay ada wajahnya",
            content: Image.file(File(image!.path)),
          );
        } else {
          Get.defaultDialog(
            middleText: "Ini Wajahnya Gaada Pucit",
            content: Column(
              children: [
                Container(
                    height: 200,
                    width: 200,
                    child: Image.file(File(image!.path), fit: BoxFit.cover)),
                SizedBox(height: 20),
                Icon(Icons.close_rounded),
                SizedBox(height: 20),
                Text("Ini Wajahnya Gaada Pucit"),
              ],
            ),
          );
        }
      } finally {
        faceDetector.close();
      }
    }
  }

  Future<List<Face>> detectFaces(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final List<Face> faces = await faceDetector.processImage(inputImage);
    return faces;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserData() async* {
    String uid = auth.currentUser!.uid;

    yield* firestore.collection('users').doc(uid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserHistoryPresence() async* {
    String uid = auth.currentUser!.uid;

    yield* firestore
        .collection("users")
        .doc(uid)
        .collection("presence")
        .orderBy("date", descending: true)
        .limit(5)
        .snapshots();
  }

  getTodayDate() async {
    DateTime ntpNow = await NTP.now();
    realTimeDate.value = DateFormat("EEEE, dd MMMM yyyy").format(await NTP.now());
    realTimeHour.value = DateFormat("hh:mm:ss a").format(ntpNow);

    timer = Timer(Duration(seconds: 1), () {
      getTodayDate();
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserTodayPresence() async* {
    String uid = auth.currentUser!.uid;
    String dateToday = DateFormat('dd-MM-yyyy').format(await NTP.now());

    yield* firestore.collection('users').doc(uid).collection('presence').doc(dateToday).snapshots();
  }

  showLoading() {
    Get.dialog(
      Dialog(
        child: IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.all(35),
            child: Column(
              children: [
                Text("Loading ..."),
                SizedBox(height: 20),
                Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onDispose() {
    print("--------------------->Sudah didispos");
    timer?.cancel();
    super.dispose();
  }
}
