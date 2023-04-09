import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../routes/app_pages.dart';

class PageSetupController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  TextEditingController overtimeTextC = TextEditingController();

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
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
        await doPresence(presenceType: "normal");
        break;

      case 2:
        Get.offAllNamed(Routes.USER_PROFILE);
        break;

      default:
        Get.offAllNamed(Routes.HOME);
    }
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

  Future<void> doPresence({required String presenceType}) async {
    try {
      isLoading.value = true;
      Map<String, dynamic> positionResponse = await getPosition();

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
          await setPresence(
            getAddress: address,
            getPosition: position,
            getDistance: distance,
            collectionString: "presence",
          );
        } else if (presenceType == "overtime") {
          await setPresence(
            getAddress: address,
            getPosition: position,
            getDistance: distance,
            collectionString: "overtime",
          );
        } else {
          Get.snackbar("Error", "No action");
        }

        // Get.snackbar(
        //   positionResponse["message"],
        //   "Lokasi saat ini : ${position.latitude} , ${position.longitude}}",
        // );
      } else {
        Get.snackbar(
          "Error",
          positionResponse["message"],
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal melakukan absensi, err: ${e}");
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
  }) async {
    String uid = auth.currentUser!.uid;

    DateTime now = DateTime.now();
    int lastDay = now.day - 1;
    DateTime formatYesterday =
        DateFormat("dd-MM-yyyy").parse("${lastDay}-${now.month}-${now.year}");
    bool inArea = false;

    String dateID = DateFormat("dd-MM-yyyy").format(now);
    String yesterdayID = DateFormat("dd-MM-yyyy").format(formatYesterday);

    CollectionReference<Map<String, dynamic>> collectionRef = await firestore
        .collection('users')
        .doc(uid)
        .collection(collectionString);

    QuerySnapshot<Map<String, dynamic>> snapshotPresence =
        await collectionRef.get();

    DocumentSnapshot<Map<String, dynamic>> getTodayData =
        await collectionRef.doc(dateID).get();

    DocumentSnapshot<Map<String, dynamic>> getYesterdayData =
        await collectionRef.doc(yesterdayID).get();

    print(overtimeTextC.text);

    // String getMinutesNumber = getMinutesDiff.replaceAll(" Minutes", "");
    // int convertToInt = int.parse(getMinutesNumber);

    // print("This is In --------------------> $getPresenceInTime");
    // print("This is Now --------------------> $now");
    // print("This is Duration --------------------> $timeDiff");
    // print("This is Duration in Minutes --------------------> $getMinutesDiff");
    // print(
    //     "This is Duration in Minutes but just number --------------------> ${getMinutesNumber}");
    // print(
    //     "This is a converted Minutes ---------------------> ${convertToInt} type is ${convertToInt.runtimeType}");
    // print(
    //     "Jumlah Uang Lemburan -------------------> ${(convertToInt / 60) * 150000}");

    if (getDistance <= 100.0) {
      inArea = true;
    }

    print("Jaraknya ------------------------> ${getDistance} == ${inArea}");

    if (snapshotPresence.docs.length == 0) {
      //Absen Masuk Pertama Kali
      await Get.defaultDialog(
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
    } else {
      Map<String, dynamic>? lastDayData = getYesterdayData.data();

      if (!getYesterdayData.exists) {
        if (!getTodayData.exists) {
          //Absen Masuk Ketika Kemarin libur/tidak ada absensi.
          await Get.defaultDialog(
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
        } else {
          Map<String, dynamic>? dataToday = getTodayData.data();
          //Sudah Absen Masuk dan Pulang
          if (dataToday?["pulang"] != null) {
            //Lembur?
            Get.snackbar("Peringatan",
                "Anda sudah absen masuk dan pulang hari ini, apakah ingin lembur?");
          } else {
            DateTime getPresenceInTime =
                DateTime.parse(dataToday!['masuk']['datetime']);
            Duration timeDiff = now.difference(getPresenceInTime);
            String getMinutesDiff = "${timeDiff.inMinutes} Minutes";
            //Absen Pulang Ketika Kemarin Libur/Tidak ada absensi.
            await Get.defaultDialog(
              title: "Konfirmasi",
              middleText:
                  "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
              actions: [
                BackButton(),
                ConfirmButton(
                  type: collectionString == "presence"
                      ? "Pulang"
                      : "Lembur Pulang",
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
        }
      } else {
        if (lastDayData?["pulang"] == null) {
          //Absen Pulang saat Shift 3
          await Get.defaultDialog(
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
        } else {
          if (!getTodayData.exists) {
            //Absen Masuk Normal
            await Get.defaultDialog(
              title: "Konfirmasi",
              middleText:
                  "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk?",
              actions: [
                BackButton(),
                ConfirmButton(
                  type:
                      collectionString == "presence" ? "Masuk" : "Lembur Masuk",
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
          } else {
            Map<String, dynamic>? dataToday = getTodayData.data();

            //Sudah Absen Masuk dan Pulang
            if (dataToday?["pulang"] != null) {
              //Lembur?
              Get.snackbar("Peringatan",
                  "Anda sudah absen masuk dan pulang hari ini, apakah ingin lembur?");
            } else {
              DateTime getPresenceInTime =
                  DateTime.parse(dataToday!['masuk']['datetime']);
              Duration timeDiff = now.difference(getPresenceInTime);
              String getMinutesDiff = "${timeDiff.inMinutes} Minutes";
              //Absen Pulang Normal
              await Get.defaultDialog(
                title: "Konfirmasi",
                middleText:
                    "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
                actions: [
                  BackButton(),
                  ConfirmButton(
                    type: collectionString == "presence"
                        ? "Pulang"
                        : "Lembur Pulang",
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
          }
        }
      }
    }
  }
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

class ConfirmButton extends StatelessWidget {
  const ConfirmButton({
    Key? key,
    required this.type,
    required this.collectionRef,
    required this.getAddress,
    required this.getPosition,
    required this.inArea,
    required this.now,
    this.dateID,
    this.yesterdayID,
    this.overtimeTotal,
    this.overtimeDesc,
  }) : super(key: key);

  final String type;
  final CollectionReference collectionRef;
  final DateTime now;
  final Position getPosition;
  final String getAddress;
  final bool inArea;
  final String? dateID;
  final String? yesterdayID;
  final String? overtimeTotal;
  final String? overtimeDesc;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: type == "Pulang"
          ? () async {
              await collectionRef.doc(dateID).update(
                {
                  "pulang": {
                    "datetime": now.toIso8601String(),
                    "latitude": getPosition.latitude,
                    "longitude": getPosition.longitude,
                    "address": getAddress,
                    "inArea": inArea,
                  }
                },
              );
              Get.back();
              Get.snackbar("Berhasil", "Anda sudah melakukan absensi Pulang.");
            }
          : type == "Masuk"
              ? () async {
                  await collectionRef.doc(dateID).set(
                    {
                      "date": now.toIso8601String(),
                      "status": "normal",
                      "masuk": {
                        "datetime": now.toIso8601String(),
                        "latitude": getPosition.latitude,
                        "longitude": getPosition.longitude,
                        "address": getAddress,
                        "inArea": inArea,
                      }
                    },
                  );
                  Get.back();
                  Get.snackbar(
                      "Berhasil", "Anda sudah melakukan absensi Masuk.");
                }
              : type == "Shift 3 Pulang"
                  ? () async {
                      await collectionRef.doc(yesterdayID).update(
                        {
                          "pulang": {
                            "datetime": now.toIso8601String(),
                            "latitude": getPosition.latitude,
                            "longitude": getPosition.longitude,
                            "address": getAddress,
                            "inArea": inArea,
                          }
                        },
                      );
                      Get.back();
                      Get.snackbar(
                          "Berhasil", "Anda sudah melakukan absensi Pulang.");
                    }
                  : type == "Lembur Masuk"
                      ? () async {
                          await collectionRef.doc(dateID).set(
                            {
                              "date": now.toIso8601String(),
                              "masuk": {
                                "datetime": now.toIso8601String(),
                                "latitude": getPosition.latitude,
                                "longitude": getPosition.longitude,
                                "address": getAddress,
                                "inArea": inArea,
                              },
                              "description": overtimeDesc
                            },
                          );
                          Get.back();
                          Get.snackbar(
                              "Berhasil", "Anda sudah melakukan Lembur Masuk.");
                        }
                      : type == "Lembur Pulang"
                          ? () async {
                              await collectionRef.doc(dateID).update(
                                {
                                  "pulang": {
                                    "datetime": now.toIso8601String(),
                                    "latitude": getPosition.latitude,
                                    "longitude": getPosition.longitude,
                                    "address": getAddress,
                                    "inArea": inArea,
                                  },
                                  "total": overtimeTotal,
                                },
                              );
                              Get.back();
                              Get.snackbar("Berhasil",
                                  "Anda sudah melakukan Lembur Pulang.");
                            }
                          : () => print("else"),
      child: Text("Confirm"),
    );
  }
}
