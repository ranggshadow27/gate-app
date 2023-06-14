import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fs;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';

import '../routes/app_pages.dart';

class PageSetupController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  fs.FirebaseStorage storage = fs.FirebaseStorage.instance;

  final imagePicker = ImagePicker();
  final faceDetector = FaceDetector(options: FaceDetectorOptions());

  TextEditingController overtimeTextC = TextEditingController();

  XFile? image;
  RxInt initialPage = 0.obs;
  RxBool isLoading = false.obs;

  void visitPage(int i) async {
    print("Page $i Visited");
    initialPage.value = i;
    switch (i) {
      case 0:
        Get.offAllNamed(Routes.HOME);
        break;

      case 1:
        Get.toNamed(Routes.PRESENCE_HISTORY_DETAILS);
        break;

      case 2:
        // Get.dialog(
        //   Dialog(
        //     backgroundColor: Colors.transparent,
        //     elevation: 0,
        //     child: Center(
        //       child: CircularProgressIndicator(),
        //     ),
        //   ),
        // );

        // await doPresence(presenceType: "normal");

        await pickImage();
        break;

      case 3:
        Get.offAllNamed(Routes.REPORT);
        break;

      case 4:
        Get.offAllNamed(Routes.USER_PROFILE);
        break;

      default:
        Get.offAllNamed(Routes.HOME);
    }
  }

  showLoading() {
    Get.dialog(
      barrierDismissible: true,
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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

  pickImage() async {
    image = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    showLoading();

    if (image == null) {
      return visitPage(0);
    }

    if (image != null) {
      print("This is your image path : ${image!.path}");
      try {
        List<Face> face = await detectFaces(image!.path);
        Get.back();

        if (face.isNotEmpty) {
          // showLoading();
          await doPresence(presenceType: 'normal');
        } else {
          Get.defaultDialog(
            barrierDismissible: false,
            content: Column(
              children: [
                Container(
                    height: 200,
                    width: 200,
                    child: Image.file(File(image!.path), fit: BoxFit.cover)),
                SizedBox(height: 20),
                Icon(Icons.close_rounded),
                Text("Ini Wajahnya Gaada Pucit"),
                SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      Get.back();
                      visitPage(0);
                    },
                    child: Text("Back"))
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

  Future<void> updatePosition({
    required Position getPosition,
    required String getAddress,
  }) async {
    String uid = await auth.currentUser!.uid;

    await firestore.collection('users').doc(uid).update({
      'address': getAddress,
    });
  }

  Future<Map<String, dynamic>> getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return {
        "message": "Mohon untuk mengaktifkan lokasi device.",
        "isError": true,
      };
      // return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return {
          "message": "Mohon untuk mengizinkan akses lokasi device saat ini.",
          "isError": true,
        };
        // return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return {
        "message":
            "Akses lokasi untuk aplikasi ini ditolak permanen, mohon untuk mengizinkan akses lokasi pada pengaturan device anda.",
        "isError": true,
      };
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 20),
    );

    return {
      "position": currentPosition,
      "message": "Berhasil",
      "isError": false,
    };
  }

  Future<DateTime?> getNetworkTime() async {
    DateTime? now;
    try {
      now = await NTP.now(
        lookUpAddress: "time.windows.com",
        timeout: Duration(seconds: 5),
      );
    } catch (e) {}

    if (now != null) {
      print(now);
      return now;
    }
    print(now);

    return null;
  }

  Future<void> doPresence({required String presenceType}) async {
    try {
      isLoading.value = true;
      showLoading();
      Map<String, dynamic> positionResponse = await getPosition();
      DateTime now = await NTP.now(
        lookUpAddress: "time.windows.com",
        timeout: Duration(seconds: 5),
      );

      // String lastestDevice = await getUserLastestDevice();
      // Map<String, dynamic> deviceInfo = await getDeviceInfo();

      if (positionResponse["isError"] != true) {
        Position position = positionResponse["position"];
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
          localeIdentifier: "id",
        );

        double distance = Geolocator.distanceBetween(
          -6.354521,
          107.143887,
          position.latitude,
          position.longitude,
        );

        print(placemarks[0]);

        String address =
            "${placemarks[0].name}, ${placemarks[0].locality}, ${placemarks[0].subLocality}";

        await updatePosition(
          getPosition: position,
          getAddress: address,
        );

        if (presenceType == "normal") {
          return await setPresence(
            getAddress: address,
            getPosition: position,
            getDistance: distance,
            collectionString: "presence",
            now: now,
          );
        }

        if (presenceType == "overtime") {
          return await setPresence(
            getAddress: address,
            getPosition: position,
            getDistance: distance,
            collectionString: "overtime",
            now: now,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          positionResponse["message"],
        );
      }
    } catch (e) {
      Get.snackbar(
          "Error", "Gagal melakukan absensi mohon cek koneksi internet dan coba lagi, err: $e");
    } finally {
      isLoading.value = false;
      visitPage(0);
    }
  }

  Future<void> setPresence({
    required Position getPosition,
    required String getAddress,
    required double getDistance,
    required String collectionString,
    required DateTime now,
  }) async {
    String uid = auth.currentUser!.uid;
    bool inArea = false;

    print(now);

    int lastDay = now.day - 1;
    DateTime formatYesterday =
        DateFormat("dd-MM-yyyy").parse("${lastDay}-${now.month}-${now.year}");

    String dateID = DateFormat("dd-MM-yyyy").format(now);
    String yesterdayID = DateFormat("dd-MM-yyyy").format(formatYesterday);

    DateTime formatTodayyMd = DateFormat("yyyy-MM-dd").parse("${now.year}-${now.month}-${now.day}");

    DateTime formatYesterdayyMd =
        DateFormat("yyyy-MM-dd").parse("${now.year}-${now.month}-${lastDay}");

    CollectionReference<Map<String, dynamic>> collectionRef =
        await firestore.collection('users').doc(uid).collection(collectionString);

    QuerySnapshot<Map<String, dynamic>> duplicateDate = await collectionRef
        .where('date', isGreaterThanOrEqualTo: formatTodayyMd.toIso8601String())
        .get();

    QuerySnapshot<Map<String, dynamic>> yesterdayDuplicateDate = await collectionRef
        .where('date', isGreaterThan: formatYesterdayyMd.toIso8601String())
        .where('date',
            isLessThan: formatYesterdayyMd
                .add(Duration(hours: 23, minutes: 59, seconds: 59))
                .toIso8601String())
        .get();

    int countTodayID = duplicateDate.docs.length;
    int countYesterdayID = yesterdayDuplicateDate.docs.length;

    String duplicateDateId = "${dateID}_${countTodayID.toString()}";
    String duplicateDateIdOut = "${dateID}_${(countTodayID - 1).toString()}";

    String yDuplicateDateIdOut = "${yesterdayID}_${(countYesterdayID - 1).toString()}";

    // for (var i = 0; i < yesterdayDuplicateDate.docs.length; i++) {
    //   print("---------> ${yesterdayDuplicateDate.docs[i].id}");
    // }

    // print("-----------------------> ${lastDay}-${now.month}-${now.year}");
    // print("lebih dari -----------------------> $formatYesterdayyMd");
    // print(
    //     "kurang dari -----------------------> ${formatYesterdayyMd.add(Duration(hours: 23, minutes: 59, seconds: 59))}");
    // print("total YesterdayID-----------------------> $countYesterdayID");
    // print("yDuplicateDateIdOut -----------------------> $yDuplicateDateIdOut");
    // print(
    //     "countTodayId (duplicateDate.length) ------------------> ${duplicateDate.docs.length}");

    QuerySnapshot<Map<String, dynamic>> getAllPresence = await collectionRef.get();
    DocumentSnapshot<Map<String, dynamic>> getTodayData = await collectionRef.doc(dateID).get();

    DocumentSnapshot<Map<String, dynamic>> getYesterdayData =
        await collectionRef.doc(yesterdayID).get();

    DocumentSnapshot<Map<String, dynamic>> getDupeYesterdayData =
        await collectionRef.doc(yDuplicateDateIdOut).get();

    Map<String, dynamic>? todayDuplicateData;
    Map<String, dynamic>? dataToday = getTodayData.data();
    Map<String, dynamic>? lastDayData = getYesterdayData.data();
    Map<String, dynamic>? yesterdayDupeData = getDupeYesterdayData.data();

    if (duplicateDate.docs.length > 1) {
      todayDuplicateData = duplicateDate.docs[countTodayID - 1].data();
    } else {
      todayDuplicateData = null;
    }
    print("ini adalah data lanjut shift terakhir ----> $todayDuplicateData");

    DateTime getPresenceInTime;

    if (dataToday != null) {
      getPresenceInTime = DateTime.parse(dataToday['masuk']['datetime']);
    } else {
      getPresenceInTime = now;
    }

    Duration timeDiff = now.difference(getPresenceInTime);
    String getMinutesDiff = "${timeDiff.inMinutes} Minutes";

    if (getDistance <= 50.0) {
      inArea = true;
    }

    if (getDistance > 50.0) {
      return Get.defaultDialog(
        title: "Error",
        middleText:
            "Tidak dapat melakukan absensi karena lokasi anda saat ini terlalu jauh dengan lokasi kantor.",
      );
    }

    print("Jaraknya ------------------------> ${getDistance} == ${inArea}");

    if (getAllPresence.docs.length == 0) {
      //Absen Masuk Pertama Kali
      print("//---------------->Absen Masuk Pertama Kali");

      return await buildConfirmDialog(
        type: collectionString == "presence" ? "Masuk" : "Lembur Masuk",
        collectionRef: collectionRef,
        getAddress: getAddress,
        getPosition: getPosition,
        inArea: inArea,
        now: now,
        dateID: dateID,
        //
        overtimeDesc: overtimeTextC.text,
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk?",
      );
      return await Get.defaultDialog(
        title: "Konfirmasi",
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk?",
        actions: [
          BackButton(),
          ConfirmButton(
            type: collectionString == "presence" ? "Masuk" : "Lembur Masuk",
            collectionRef: collectionRef,
            getAddress: getAddress,
            getPosition: getPosition,
            inArea: inArea,
            now: now,
            dateID: dateID,
            //
            overtimeDesc: overtimeTextC.text,
          ),
        ],
      );
    }

    if (!getTodayData.exists && !getYesterdayData.exists) {
      //Data hari ini tidak ada?
      //Absen Masuk Ketika Kemarin libur/tidak ada absensi.
      print("//---------------->Masuk saat Kemarin tidak ada absensi.");

      return await buildConfirmDialog(
        type: collectionString == "presence" ? "Masuk" : "Lembur Masuk",
        collectionRef: collectionRef,
        getAddress: getAddress,
        getPosition: getPosition,
        inArea: inArea,
        now: now,
        dateID: dateID,
        //
        overtimeDesc: overtimeTextC.text,
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk?",
      );

      return await Get.defaultDialog(
        title: "Konfirmasi",
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk?",
        actions: [
          BackButton(),
          ConfirmButton(
            type: collectionString == "presence" ? "Masuk" : "Lembur Masuk",
            collectionRef: collectionRef,
            getAddress: getAddress,
            getPosition: getPosition,
            inArea: inArea,
            now: now,
            dateID: dateID,
            //
            overtimeDesc: overtimeTextC.text,
          ),
        ],
      );
    }

    if (getTodayData.exists && dataToday?["pulang"] == null) {
      print("//------------>Absen pulang Normal.");

      return await buildConfirmDialog(
        type: collectionString == "presence" ? "Pulang" : "Lembur Pulang",
        collectionRef: collectionRef,
        now: now,
        getPosition: getPosition,
        getAddress: getAddress,
        inArea: inArea,
        dateID: dateID,
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
      );
    }

    if (
        // getYesterdayData.exists &&
        getTodayData.exists &&
            dataToday?["pulang"] != null &&
            todayDuplicateData?['pulang'] == null) {
      print("//---------------->Lanjut Shift Pulang.");

      return await buildConfirmDialog(
        type: collectionString == "presence" ? "Pulang" : "Lembur Pulang",
        collectionRef: collectionRef,
        getAddress: getAddress,
        getPosition: getPosition,
        inArea: inArea,
        now: now,
        dateID: duplicateDateIdOut,
        //
        overtimeTotal: getMinutesDiff,
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
      );

      if (!getYesterdayData.exists &&
          dataToday?["pulang"] != null &&
          // todayDuplicateData?['pulang'] != null &&
          duplicateDate.docs.length < 3) {
        print("//---------------->Lanjut Shift Masuk.");

        return await buildConfirmDialog(
          type: collectionString == "presence" ? "Masuk" : "Lembur Masuk",
          collectionRef: collectionRef,
          getAddress: getAddress,
          getPosition: getPosition,
          inArea: inArea,
          now: now,
          dateID: duplicateDateId,
          //
          overtimeDesc: overtimeTextC.text,
          middleText:
              "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk kembali?",
        );

        return await Get.defaultDialog(
          title: "Konfirmasi",
          middleText:
              "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk kembali?",
          actions: [
            BackButton(),
            ConfirmButton(
              type: collectionString == "presence" ? "Masuk" : "Lembur Masuk",
              collectionRef: collectionRef,
              getAddress: getAddress,
              getPosition: getPosition,
              inArea: inArea,
              now: now,
              dateID: duplicateDateId,
              //
              overtimeDesc: overtimeTextC.text,
            ),
          ],
        );
      }

      return await Get.defaultDialog(
        title: "Konfirmasi",
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
        actions: [
          BackButton(),
          ConfirmButton(
            type: collectionString == "presence" ? "Pulang" : "Lembur Pulang",
            collectionRef: collectionRef,
            getAddress: getAddress,
            getPosition: getPosition,
            inArea: inArea,
            now: now,
            dateID: duplicateDateIdOut,
            //
            overtimeTotal: getMinutesDiff,
          ),
        ],
      );
    }

    if (!getYesterdayData.exists && getTodayData.exists && dataToday?["pulang"] == null) {
      //Absen Pulang Ketika Kemarin Libur/Tidak ada absensi.
      print("//---------------->Pulang Ketika Kemarin Libur.");

      return await buildConfirmDialog(
        type: collectionString == "presence" ? "Pulang" : "Lembur Pulang",
        collectionRef: collectionRef,
        getAddress: getAddress,
        getPosition: getPosition,
        inArea: inArea,
        now: now,
        dateID: dateID,
        //
        overtimeTotal: getMinutesDiff,
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
      );

      return await Get.defaultDialog(
        title: "Konfirmasi",
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
        actions: [
          BackButton(),
          ConfirmButton(
            type: collectionString == "presence" ? "Pulang" : "Lembur Pulang",
            collectionRef: collectionRef,
            getAddress: getAddress,
            getPosition: getPosition,
            inArea: inArea,
            now: now,
            dateID: dateID,
            //
            overtimeTotal: getMinutesDiff,
          ),
        ],
      );
    }

    if (getYesterdayData.exists && lastDayData?["pulang"] == null) {
      //Absen Pulang saat Shift 3
      print("//------------->Pulang saat Shift 3 ketika kemarin ada absensi.");

      return await buildConfirmDialog(
        type: "Shift 3 Pulang",
        collectionRef: collectionRef,
        getAddress: getAddress,
        getPosition: getPosition,
        inArea: inArea,
        now: now,
        yesterdayID: yesterdayID,
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
      );

      return await Get.defaultDialog(
        title: "Konfirmasi",
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
        actions: [
          BackButton(),
          ConfirmButton(
            type: "Shift 3 Pulang",
            collectionRef: collectionRef,
            getAddress: getAddress,
            getPosition: getPosition,
            inArea: inArea,
            now: now,
            yesterdayID: yesterdayID,
          ),
        ],
      );
    }

    if (
        // !getDupeYesterdayData.exists &&
        // todayDuplicateData?['pulang'] != null &&
        // getYesterdayData.exists &&
        // lastDayData?["pulang"] != null &&

        getTodayData.exists &&
            dataToday?["pulang"] != null &&
            // todayDuplicateData?['pulang'] != null &&
            duplicateDate.docs.length < 3) {
      print("//---------------->Lanjut Shift Masuk[2].");

      return await buildConfirmDialog(
        type: collectionString == "presence" ? "Masuk" : "Lembur Masuk",
        collectionRef: collectionRef,
        getAddress: getAddress,
        getPosition: getPosition,
        inArea: inArea,
        now: now,
        dateID: duplicateDateId,
        //
        overtimeDesc: overtimeTextC.text,
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk kembali?",
      );

      return await Get.defaultDialog(
        title: "Konfirmasi",
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk kembali?",
        actions: [
          BackButton(),
          ConfirmButton(
            type: collectionString == "presence" ? "Masuk" : "Lembur Masuk",
            collectionRef: collectionRef,
            getAddress: getAddress,
            getPosition: getPosition,
            inArea: inArea,
            now: now,
            dateID: duplicateDateId,
            //
            overtimeDesc: overtimeTextC.text,
          ),
        ],
      );
    }

    if (getYesterdayData.exists &&
        lastDayData?["pulang"] != null &&
        getTodayData.exists &&
        dataToday?["pulang"] != null &&
        getDupeYesterdayData.exists &&
        yesterdayDupeData?['pulang'] == null) {
      // DateTime getPresenceInTime =
      //     DateTime.parse(todayDuplicateData?['masuk']['datetime']);
      // Duration timeDiff = now.difference(getPresenceInTime);
      // String getMinutesDiff = "${timeDiff.inMinutes} Minutes";

      print("//----------->Absen Pulang ketika lembur shift 3.");

      return await buildConfirmDialog(
        type: collectionString == "presence" ? "Pulang" : "Lembur Pulang",
        collectionRef: collectionRef,
        getAddress: getAddress,
        getPosition: getPosition,
        inArea: inArea,
        now: now,
        dateID: duplicateDateIdOut,
        //
        overtimeTotal: getMinutesDiff,
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
      );

      return await Get.defaultDialog(
        title: "Konfirmasi",
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
        actions: [
          BackButton(),
          ConfirmButton(
            type: collectionString == "presence" ? "Pulang" : "Lembur Pulang",
            collectionRef: collectionRef,
            getAddress: getAddress,
            getPosition: getPosition,
            inArea: inArea,
            now: now,
            dateID: duplicateDateIdOut,
            //
            overtimeTotal: getMinutesDiff,
          ),
        ],
      );
    }

    if (getYesterdayData.exists &&
        lastDayData?["pulang"] != null &&
        !getDupeYesterdayData.exists &&
        getTodayData.exists &&
        dataToday?["pulang"] == null) {
      DateTime getPresenceInTime = DateTime.parse(dataToday?['masuk']['datetime']);
      Duration timeDiff = now.difference(getPresenceInTime);
      String getMinutesDiff = "${timeDiff.inMinutes} Minutes";
      //Absen Pulang Normal
      print("//---------------->Absen Pulang ketika kemarin tidak ada lembur.");

      return await buildConfirmDialog(
        type: collectionString == "presence" ? "Pulang" : "Lembur Pulang",
        collectionRef: collectionRef,
        getAddress: getAddress,
        getPosition: getPosition,
        inArea: inArea,
        now: now,
        dateID: dateID,
        //
        overtimeTotal: getMinutesDiff,
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
      );

      return await Get.defaultDialog(
        title: "Konfirmasi",
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
        actions: [
          BackButton(),
          ConfirmButton(
            type: collectionString == "presence" ? "Pulang" : "Lembur Pulang",
            collectionRef: collectionRef,
            getAddress: getAddress,
            getPosition: getPosition,
            inArea: inArea,
            now: now,
            dateID: dateID,
            //
            overtimeTotal: getMinutesDiff,
          ),
        ],
      );
    }

    if (getYesterdayData.exists &&
        lastDayData?["pulang"] != null &&
        !getDupeYesterdayData.exists &&
        !getTodayData.exists) {
      //Absen Masuk Normal
      print("//---------------->Absen Masuk ketika kemarin tidak ada lembur.");

      return await buildConfirmDialog(
        type: collectionString == "presence" ? "Masuk" : "Lembur Masuk",
        collectionRef: collectionRef,
        getAddress: getAddress,
        getPosition: getPosition,
        inArea: inArea,
        now: now,
        dateID: dateID,
        //
        overtimeDesc: overtimeTextC.text,
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk?",
      );

      return await Get.defaultDialog(
        title: "Konfirmasi",
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk?",
        actions: [
          BackButton(),
          ConfirmButton(
            type: collectionString == "presence" ? "Masuk" : "Lembur Masuk",
            collectionRef: collectionRef,
            getAddress: getAddress,
            getPosition: getPosition,
            inArea: inArea,
            now: now,
            dateID: dateID,
            //
            overtimeDesc: overtimeTextC.text,
          ),
        ],
      );
    }

    if (getYesterdayData.exists && lastDayData?["pulang"] != null && getDupeYesterdayData.exists) {
      //Absen Masuk Normal
      print("//---------------->Absen Masuk ketika kemarin ada lembur.");

      return await buildConfirmDialog(
        type: collectionString == "presence" ? "Masuk" : "Lembur Masuk",
        collectionRef: collectionRef,
        getAddress: getAddress,
        getPosition: getPosition,
        inArea: inArea,
        now: now,
        dateID: dateID,
        //
        overtimeDesc: overtimeTextC.text,
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk?",
      );

      return await Get.defaultDialog(
        title: "Konfirmasi",
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk?",
        actions: [
          BackButton(),
          ConfirmButton(
            type: collectionString == "presence" ? "Masuk" : "Lembur Masuk",
            collectionRef: collectionRef,
            getAddress: getAddress,
            getPosition: getPosition,
            inArea: inArea,
            now: now,
            dateID: dateID,
            //
            overtimeDesc: overtimeTextC.text,
          ),
        ],
      );
    }

    if (getYesterdayData.exists &&
        lastDayData?["pulang"] != null &&
        getDupeYesterdayData.exists &&
        yesterdayDupeData?['pulang'] != null &&
        !getTodayData.exists) {
      //Absen Masuk Normal
      print("//------------>Absen Masuk saat kemarin ada lembur.");

      return await buildConfirmDialog(
        type: collectionString == "presence" ? "Masuk" : "Lembur Masuk",
        collectionRef: collectionRef,
        getAddress: getAddress,
        getPosition: getPosition,
        inArea: inArea,
        now: now,
        dateID: dateID,
        //
        overtimeDesc: overtimeTextC.text,
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk?",
      );

      return await Get.defaultDialog(
        title: "Konfirmasi",
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk?",
        actions: [
          BackButton(),
          ConfirmButton(
            type: collectionString == "presence" ? "Masuk" : "Lembur Masuk",
            collectionRef: collectionRef,
            getAddress: getAddress,
            getPosition: getPosition,
            inArea: inArea,
            now: now,
            dateID: dateID,
            //
            overtimeDesc: overtimeTextC.text,
          ),
        ],
      );
    }

    if (getYesterdayData.exists &&
        lastDayData?["pulang"] != null &&
        getDupeYesterdayData.exists &&
        yesterdayDupeData?['pulang'] == null &&
        !getTodayData.exists) {
      print("/-->Absen Pulang Sip3 saat kemarin lembur sip3 hari ini blm absen.");

      return await buildConfirmDialog(
        type: "Shift 3 Pulang",
        collectionRef: collectionRef,
        getAddress: getAddress,
        getPosition: getPosition,
        inArea: inArea,
        now: now,
        yesterdayID: yDuplicateDateIdOut,
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
      );

      return await Get.defaultDialog(
        title: "Konfirmasi",
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
        actions: [
          BackButton(),
          ConfirmButton(
            type: "Shift 3 Pulang",
            collectionRef: collectionRef,
            getAddress: getAddress,
            getPosition: getPosition,
            inArea: inArea,
            now: now,
            yesterdayID: yDuplicateDateIdOut,
          ),
        ],
      );
    }

    if (getYesterdayData.exists &&
        lastDayData?["pulang"] != null &&
        getDupeYesterdayData.exists &&
        yesterdayDupeData?['pulang'] != null &&
        getTodayData.exists &&
        dataToday?["pulang"] == null) {
      print("//--------->Absen Pulang Normal saat kemarin ada lembur.");

      return await buildConfirmDialog(
        type: collectionString == "presence" ? "Pulang" : "Lembur Pulang",
        collectionRef: collectionRef,
        getAddress: getAddress,
        getPosition: getPosition,
        inArea: inArea,
        now: now,
        dateID: dateID,
        //
        overtimeDesc: overtimeTextC.text,
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
      );

      return await Get.defaultDialog(
        title: "Konfirmasi",
        middleText:
            "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
        actions: [
          BackButton(),
          ConfirmButton(
            type: collectionString == "presence" ? "Pulang" : "Lembur Pulang",
            collectionRef: collectionRef,
            getAddress: getAddress,
            getPosition: getPosition,
            inArea: inArea,
            now: now,
            dateID: dateID,
            //
            overtimeDesc: overtimeTextC.text,
          ),
        ],
      );
    }

    return Get.defaultDialog(
      title: "Error",
      middleText: "Hari ini sudah melakukan 3 kali absensi, tidak dapat melakukan absensi kembali.",
    );
  }

  uploadImage(
      {required String presenceType, String? dateID, required Map<String, dynamic> query}) async {
    fs.Reference? storageRef;
    String uid = auth.currentUser!.uid;
    File file = File(image!.path);
    String ext = image!.name.split(".").last;
    String? fileName;

    print("Uploading Image ...........");

    if (presenceType == "Pulang") {
      fileName = "pulang";
      String folderName = "presence";
      storageRef = storage.ref('user_presence/$uid/$folderName/$dateID/$fileName');
    }

    if (presenceType == "Masuk") {
      fileName = "masuk";
      String folderName = "presence";
      storageRef = storage.ref('user_presence/$uid/$folderName/$dateID/$fileName');
    }

    if (presenceType == "Shift 3 Pulang") {
      fileName = "pulang";
      String folderName = "presence";
      storageRef = storage.ref('user_presence/$uid/$folderName/$dateID/$fileName');
    }

    if (presenceType == "Lembur Pulang") {
      fileName = "pulang";
      String folderName = "overtime";
      return storageRef = storage.ref('user_presence/$uid/$folderName/$dateID/$fileName');
    }

    if (presenceType == "Lembur Masuk") {
      fileName = "masuk";
      String folderName = "overtime";
      storageRef = storage.ref('user_presence/$uid/$folderName/$dateID/$fileName');
    }

    await storageRef!.putFile(file);

    String imageUrl = await storageRef.getDownloadURL();
    query[fileName!].addAll({'image': imageUrl});
  }

  Future<String> getUserLastestDevice() async {
    String uid = await auth.currentUser!.uid;

    String? userDevice =
        await firestore.collection('users').doc(uid).get().then((value) => value.data()?['device']);

    print(userDevice);

    return userDevice ?? '';
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

    String androidId = androidInfo.id;
    String currentDeviceId = androidInfo.androidId;
    String deviceModel = "${androidInfo.manufacturer} ${androidInfo.model}";

    print("$currentDeviceId - $androidId - $deviceModel");

    return {
      'id': currentDeviceId,
      'model': deviceModel,
    };

    // showLoadingDialog();

    // String deviceId = await getUserLastestDevice();
    // print("-----------------> $deviceId");

    // if (deviceId.isEmpty) {
    //   return Get.defaultDialog(
    //       middleText:
    //           "Your new Device ID is : $currentDeviceId \n Your new Device Name is : $deviceModel",
    //       confirm: ElevatedButton(
    //           onPressed: () {
    //             Get.back();
    //             Get.back();
    //           },
    //           child: Text("OK")));
    // }

    // if (deviceId != currentDeviceId) {
    //   return Get.defaultDialog(
    //       middleText:
    //           "Your Device ID is : $deviceId \n Your Device Name is : $deviceModel",
    //       confirm: ElevatedButton(
    //           onPressed: () {
    //             Get.back();
    //             Get.back();
    //           },
    //           child: Text("OK")));
    // }

    // return Get.defaultDialog(
    //     middleText: "Your Device Doesnt Identified yet",
    //     confirm: ElevatedButton(
    //         onPressed: () {
    //           Get.back();
    //         },
    //         child: Text("OK")));
  }

  buildConfirmDialog({
    required String type,
    required CollectionReference collectionRef,
    required DateTime now,
    required Position getPosition,
    required String getAddress,
    required bool inArea,
    required String middleText,
    final String? dateID,
    final String? yesterdayID,
    final String? overtimeTotal,
    final String? overtimeDesc,
  }) async {
    return await Get.dialog(
      barrierDismissible: false,
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.all(35),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 200,
                    width: 200,
                    child: Image.file(File(image!.path), fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: 20),
                Icon(Icons.check),
                Text("Wajah terdeteksi"),
                Divider(),
                Text(
                  middleText,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BackButton(),
                    ConfirmButton(
                      type: type,
                      collectionRef: collectionRef,
                      getAddress: getAddress,
                      getPosition: getPosition,
                      inArea: inArea,
                      now: now,
                      dateID: dateID,
                      overtimeDesc: overtimeDesc,
                      overtimeTotal: overtimeTotal,
                      yesterdayID: yesterdayID,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget ConfirmButton({
    required String type,
    required CollectionReference collectionRef,
    required String getAddress,
    required Position getPosition,
    required bool inArea,
    required DateTime now,
    String? dateID,
    String? yesterdayID,
    String? overtimeTotal,
    String? overtimeDesc,
  }) {
    Map<String, dynamic> queryPulang = {
      "pulang": {
        "datetime": now.toIso8601String(),
        "latitude": getPosition.latitude,
        "longitude": getPosition.longitude,
        "address": getAddress,
        "inArea": inArea,
      }
    };

    Map<String, dynamic> queryMasuk = {
      "date": now.toIso8601String(),
      "status": "normal",
      "masuk": {
        "datetime": now.toIso8601String(),
        "latitude": getPosition.latitude,
        "longitude": getPosition.longitude,
        "address": getAddress,
        "inArea": inArea,
      }
    };

    presenceLogic(Map<String, dynamic> queryMasuk, Map<String, dynamic> queryPulang) {
      if (type == "Pulang") {
        return () async {
          showLoading();
          await uploadImage(presenceType: type, dateID: dateID, query: queryPulang);
          await collectionRef.doc(dateID).update(queryPulang);

          Get.back();
          Get.back();
          Get.snackbar("Berhasil", "Anda sudah melakukan absensi Pulang.");
        };
      }

      if (type == "Masuk") {
        return () async {
          showLoading();
          await uploadImage(presenceType: type, dateID: dateID, query: queryMasuk);
          await collectionRef.doc(dateID).set(queryMasuk);

          Get.back();
          Get.back();
          Get.snackbar("Berhasil", "Anda sudah melakukan absensi Masuk.");
        };
      }

      if (type == "Shift 3 Pulang") {
        return () async {
          showLoading();
          await uploadImage(presenceType: type, dateID: yesterdayID, query: queryPulang);
          await collectionRef.doc(yesterdayID).update(queryPulang);

          Get.back();
          Get.back();
          Get.snackbar("Berhasil", "Anda sudah melakukan absensi Pulang.");
        };
      }

      if (type == "Lembur Masuk") {
        return () async {
          showLoading();
          await uploadImage(presenceType: type, dateID: dateID, query: queryMasuk);
          queryMasuk['description'] = overtimeDesc;
          await collectionRef.doc(dateID).set(queryMasuk);

          Get.back();
          Get.back();
          Get.snackbar("Berhasil", "Anda sudah melakukan Lembur Masuk.");
        };
      }

      if (type == "Lembur Pulang") {
        return () async {
          showLoading();
          await uploadImage(presenceType: type, dateID: dateID, query: queryPulang);
          queryPulang['total'] = overtimeTotal;
          await collectionRef.doc(dateID).update(queryPulang);

          Get.back();
          Get.back();
          Get.snackbar("Berhasil", "Anda sudah melakukan Lembur Pulang.");
        };
      }

      // type == "Pulang"
      //     ?
      //     : type == "Masuk"
      //         ?
      //         : type == "Shift 3 Pulang"
      //             ?
      //             : type == "Lembur Masuk"
      //                 ?
      //                 : type == "Lembur Pulang"
      //                     ?
      //                     : () => print("else");
    }

    return ElevatedButton(
      onPressed: presenceLogic(queryMasuk, queryPulang),
      child: Text("Confirm"),
    );
  }
}

showLoadingDialog() {
  return Get.dialog(LoadingDialog());
}

class BackButton extends StatelessWidget {
  const BackButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => Get.back(),
      child: Text("Back"),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: IntrinsicHeight(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              Center(child: CircularProgressIndicator()),
              SizedBox(height: 20),
              Text("Please Wait .."),
            ],
          ),
        ),
      ),
    );
  }
}
