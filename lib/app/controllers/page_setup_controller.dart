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
        Get.toNamed(Routes.PRESENCE_HISTORY_DETAILS);
        break;

      case 2:
        if (i == 3) {
          print("ini halaman report");
        } else {
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
        }

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
    bool inArea = false;

    DateTime now = DateTime.now();
    int lastDay = now.day - 1;
    DateTime formatYesterday =
        DateFormat("dd-MM-yyyy").parse("${lastDay}-${now.month}-${now.year}");

    String dateID = DateFormat("dd-MM-yyyy").format(now);
    String yesterdayID = DateFormat("dd-MM-yyyy").format(formatYesterday);

    DateTime formatTodayyMd =
        DateFormat("yyyy-MM-dd").parse("${now.year}-${now.month}-${now.day}");

    DateTime formatYesterdayyMd =
        DateFormat("yyyy-MM-dd").parse("${now.year}-${now.month}-${lastDay}");

    CollectionReference<Map<String, dynamic>> collectionRef = await firestore
        .collection('users')
        .doc(uid)
        .collection(collectionString);

    QuerySnapshot<Map<String, dynamic>> duplicateDate = await collectionRef
        .where('date', isGreaterThanOrEqualTo: formatTodayyMd.toIso8601String())
        .get();

    QuerySnapshot<Map<String, dynamic>> yesterdayDuplicateDate =
        await collectionRef
            .where('date', isGreaterThan: formatYesterdayyMd.toIso8601String())
            .where(
                'date',
                isLessThan: formatYesterdayyMd
                    .add(Duration(hours: 23, minutes: 59, seconds: 59))
                    .toIso8601String())
            .get();

    int countTodayID = duplicateDate.docs.length;
    int countYesterdayID = yesterdayDuplicateDate.docs.length;

    String duplicateDateId = "${dateID}_${countTodayID.toString()}";
    String duplicateDateIdOut = "${dateID}_${(countTodayID - 1).toString()}";

    String yDuplicateDateIdOut =
        "${yesterdayID}_${(countYesterdayID - 1).toString()}";

    for (var i = 0; i < yesterdayDuplicateDate.docs.length; i++) {
      print("---------> ${yesterdayDuplicateDate.docs[i].id}");
    }

    print("-----------------------> ${lastDay}-${now.month}-${now.year}");
    print("lebih dari -----------------------> $formatYesterdayyMd");
    print(
        "kurang dari -----------------------> ${formatYesterdayyMd.add(Duration(hours: 23, minutes: 59, seconds: 59))}");
    print("-----------------------> $countYesterdayID");
    print("-----------------------> $yDuplicateDateIdOut");

    QuerySnapshot<Map<String, dynamic>> getAllPresence =
        await collectionRef.get();

    DocumentSnapshot<Map<String, dynamic>> getTodayData =
        await collectionRef.doc(dateID).get();

    DocumentSnapshot<Map<String, dynamic>> getYesterdayData =
        await collectionRef.doc(yesterdayID).get();

    DocumentSnapshot<Map<String, dynamic>> getDupeYesterdayData =
        await collectionRef.doc(yDuplicateDateIdOut).get();

    if (getDistance <= 100.0) {
      inArea = true;
    }

    print("Jaraknya ------------------------> ${getDistance} == ${inArea}");

    if (getAllPresence.docs.length == 0) {
      //Absen Masuk Pertama Kali
      print("//---------------->Absen Masuk Pertama Kali");
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
        //Data kemarin tidak ada?
        if (!getTodayData.exists) {
          //Data hari ini tidak ada?
          //Absen Masuk Ketika Kemarin libur/tidak ada absensi.
          print("//---------------->Masuk saat Kemarin tidak ada absensi.");

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
          print("//---------------->Sudah Absen Masuk dan Pulang.");

          if (dataToday?["pulang"] != null) {
            //Lembur?
            print("//---------------->Lanjut Shift?.");

            Map<String, dynamic>? getDuplicateData =
                duplicateDate.docs[countTodayID - 1].data();

            if (getDuplicateData['pulang'] != null) {
              if (duplicateDate.docs.length < 3) {
                print("//---------------->Lanjut Shift Masuk.");

                await Get.defaultDialog(
                  title: "Konfirmasi",
                  middleText:
                      "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk kembali?",
                  actions: [
                    BackButton(),
                    ConfirmButton(
                      type: collectionString == "presence"
                          ? "Masuk"
                          : "Lembur Masuk",
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
              } else {
                Get.snackbar("Error",
                    "Hari ini sudah melakukan 3 kali absensi, tidak dapat melakukan absensi kembali.");
              }
            } else {
              DateTime getPresenceInTime =
                  DateTime.parse(getDuplicateData['masuk']['datetime']);
              Duration timeDiff = now.difference(getPresenceInTime);
              String getMinutesDiff = "${timeDiff.inMinutes} Minutes";

              print("//---------------->Lanjut Shift Pulang.");

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
                    dateID: duplicateDateIdOut,
                    //
                    overtimeTotal: getMinutesDiff,
                  ),
                ],
              );
            }
          } else {
            DateTime getPresenceInTime =
                DateTime.parse(dataToday!['masuk']['datetime']);
            Duration timeDiff = now.difference(getPresenceInTime);
            String getMinutesDiff = "${timeDiff.inMinutes} Minutes";
            //Absen Pulang Ketika Kemarin Libur/Tidak ada absensi.
            print("//---------------->Pulang Ketika Kemarin Libur.");

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
                  duplicateId: duplicateDateId,
                  //
                  overtimeTotal: getMinutesDiff,
                ),
              ],
            );
          }
        }
      } else {
        Map<String, dynamic>? yesterdayDupeData = getDupeYesterdayData.data();
        if (lastDayData?["pulang"] == null) {
          //Absen Pulang saat Shift 3
          print("//---------------->Pulang saat Shift 3.");

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
          if (!getDupeYesterdayData.exists) {
            if (!getTodayData.exists) {
              //Absen Masuk Normal
              print("//---------------->Absen Masuk Normal.");

              await Get.defaultDialog(
                title: "Konfirmasi",
                middleText:
                    "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk?",
                actions: [
                  BackButton(),
                  ConfirmButton(
                    type: collectionString == "presence"
                        ? "Masuk"
                        : "Lembur Masuk",
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
              print("//---------------->Sudah Absen Masuk dan Pulang[2].");

              if (dataToday?["pulang"] != null) {
                //Lembur?
                print("//---------------->Lanjut Shift[2].");

                Map<String, dynamic>? getDuplicateData =
                    duplicateDate.docs[countTodayID - 1].data();

                if (getDuplicateData['pulang'] != null) {
                  if (duplicateDate.docs.length < 3) {
                    await Get.defaultDialog(
                      title: "Konfirmasi",
                      middleText:
                          "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk kembali?",
                      actions: [
                        BackButton(),
                        ConfirmButton(
                          type: collectionString == "presence"
                              ? "Masuk"
                              : "Lembur Masuk",
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
                  } else {
                    Get.snackbar("Error",
                        "Hari ini sudah melakukan 3 kali absensi, tidak dapat melakukan absensi kembali.");
                  }
                } else {
                  DateTime getPresenceInTime =
                      DateTime.parse(getDuplicateData['masuk']['datetime']);
                  Duration timeDiff = now.difference(getPresenceInTime);
                  String getMinutesDiff = "${timeDiff.inMinutes} Minutes";

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
                        dateID: duplicateDateIdOut,
                        //
                        overtimeTotal: getMinutesDiff,
                      ),
                    ],
                  );
                }
              } else {
                DateTime getPresenceInTime =
                    DateTime.parse(dataToday!['masuk']['datetime']);
                Duration timeDiff = now.difference(getPresenceInTime);
                String getMinutesDiff = "${timeDiff.inMinutes} Minutes";
                //Absen Pulang Normal
                print("//---------------->Absen Pulang Normal.");

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
            if (yesterdayDupeData?['pulang'] == null) {
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
                    yesterdayID: yDuplicateDateIdOut,
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
    this.duplicateId,
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
  final String? duplicateId;

  @override
  Widget build(BuildContext context) {
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

    return ElevatedButton(
      onPressed: type == "Pulang"
          ? () async {
              await collectionRef.doc(dateID).update(queryPulang);
              Get.back();
              Get.snackbar("Berhasil", "Anda sudah melakukan absensi Pulang.");
            }
          : type == "Masuk"
              ? () async {
                  await collectionRef.doc(dateID).set(queryMasuk);
                  Get.back();
                  Get.snackbar(
                      "Berhasil", "Anda sudah melakukan absensi Masuk.");
                }
              : type == "Shift 3 Pulang"
                  ? () async {
                      await collectionRef.doc(yesterdayID).update(queryPulang);
                      Get.back();
                      Get.snackbar(
                          "Berhasil", "Anda sudah melakukan absensi Pulang.");
                    }
                  : type == "Lembur Masuk"
                      ? () async {
                          queryMasuk['description'] = overtimeDesc;
                          await collectionRef.doc(dateID).set(queryMasuk);
                          Get.back();
                          Get.snackbar(
                              "Berhasil", "Anda sudah melakukan Lembur Masuk.");
                        }
                      : type == "Lembur Pulang"
                          ? () async {
                              queryPulang['total'] = overtimeTotal;
                              await collectionRef
                                  .doc(dateID)
                                  .update(queryPulang);
                              Get.back();
                              Get.snackbar("Berhasil",
                                  "Anda sudah melakukan Lembur Pulang.");
                            }
                          : () => print("else"),
      child: Text("Confirm"),
    );
  }
}
