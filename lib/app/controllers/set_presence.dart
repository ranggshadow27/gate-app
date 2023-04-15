import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

TextEditingController overtimeTextC = TextEditingController();

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

  DateTime formatToday =
      DateFormat("yyyy-MM-dd").parse("${now.year}-${now.month}-${now.day}");

  CollectionReference<Map<String, dynamic>> collectionRef =
      await firestore.collection('users').doc(uid).collection(collectionString);

  QuerySnapshot<Map<String, dynamic>> duplicateDate = await collectionRef
      .where('date', isGreaterThanOrEqualTo: formatToday.toIso8601String())
      .get();

  int countTodayID = duplicateDate.docs.length;
  String duplicateDateId = "${dateID}_${countTodayID.toString()}";
  String duplicateDateIdOut = "${dateID}_${(countTodayID - 1).toString()}";

  QuerySnapshot<Map<String, dynamic>> getAllPresence =
      await collectionRef.get();

  DocumentSnapshot<Map<String, dynamic>> getTodayData =
      await collectionRef.doc(dateID).get();

  DocumentSnapshot<Map<String, dynamic>> getYesterdayData =
      await collectionRef.doc(yesterdayID).get();

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
    Map<String, dynamic>? dataToday = getTodayData.data();
    Map<String, dynamic>? getDuplicateData =
        duplicateDate.docs[countTodayID - 1].data();

    if (getYesterdayData.exists) {
      if (lastDayData?["pulang"] == null) {
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
      } else if (lastDayData?["pulang"] != null && !getTodayData.exists) {
        print("//---------------->Absen Masuk Normal.");

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
      } else if (lastDayData?["pulang"] != null && getTodayData.exists) {
        DateTime getPresenceInTime =
            DateTime.parse(dataToday?['masuk']['datetime']);
        Duration timeDiff = now.difference(getPresenceInTime);
        String getMinutesDiff = "${timeDiff.inMinutes} Minutes";
        if (dataToday?["pulang"] == null) {
          print("//---------------->Absen Pulang Normal.");

          await Get.defaultDialog(
            title: "Konfirmasi",
            middleText:
                "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
            actions: [
              BackButton(),
              ConfirmButton(
                type:
                    collectionString == "presence" ? "Pulang" : "Lembur Pulang",
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
        } else if (dataToday?["pulang"] != null &&
            getDuplicateData['pulang'] != null &&
            duplicateDate.docs.length < 3) {
          await Get.defaultDialog(
            title: "Konfirmasi",
            middleText:
                "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk kembali?",
            actions: [
              BackButton(),
              ConfirmButton(
                type: "Lanjut Shift Masuk",
                collectionRef: collectionRef,
                getAddress: getAddress,
                getPosition: getPosition,
                inArea: inArea,
                now: now,
                duplicateId: duplicateDateId,
                //
              ),
            ],
          );
        } else if (dataToday?["pulang"] != null &&
            getDuplicateData['pulang'] == null) {
          await Get.defaultDialog(
            title: "Konfirmasi",
            middleText:
                "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
            actions: [
              BackButton(),
              ConfirmButton(
                type: "Lanjut Shift Pulang",
                collectionRef: collectionRef,
                getAddress: getAddress,
                getPosition: getPosition,
                inArea: inArea,
                now: now,
                duplicateId: duplicateDateIdOut,
                //
              ),
            ],
          );
        } else if (dataToday?["pulang"] != null &&
            getDuplicateData['pulang'] != null &&
            duplicateDate.docs.length > 3) {
          Get.snackbar("Error",
              "Hari ini sudah melakukan 3 kali absensi, tidak dapat melakukan absensi kembali.");
        }
      }
    } else if (!getYesterdayData.exists && !getTodayData.exists) {
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
    } else if (!getYesterdayData.exists && getTodayData.exists) {
      DateTime getPresenceInTime =
          DateTime.parse(dataToday?['masuk']['datetime']);
      Duration timeDiff = now.difference(getPresenceInTime);
      String getMinutesDiff = "${timeDiff.inMinutes} Minutes";
      if (dataToday?["pulang"] == null) {
        //Absen Pulang Ketika Kemarin Libur/Tidak ada absensi.
        print("//---------------->Pulang Ketika Kemarin Libur.");

        await Get.defaultDialog(
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
              duplicateId: duplicateDateId,
              //
              overtimeTotal: getMinutesDiff,
            ),
          ],
        );
      } else if (dataToday?["pulang"] != null) {
        if (getDuplicateData['pulang'] == null) {
          print("//---------------->Lanjut Shift Pulang.");

          await Get.defaultDialog(
            title: "Konfirmasi",
            middleText:
                "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} pulang?",
            actions: [
              BackButton(),
              ConfirmButton(
                type: collectionString == "presence"
                    ? "Lanjut Shift Pulang"
                    : "Lanjut Lembur Pulang",
                collectionRef: collectionRef,
                getAddress: getAddress,
                getPosition: getPosition,
                inArea: inArea,
                now: now,
                duplicateId: duplicateDateIdOut,
                //
                overtimeTotal: getMinutesDiff,
              ),
            ],
          );
        } else if (getDuplicateData['pulang'] != null &&
            duplicateDate.docs.length < 3) {
          print("//---------------->Lanjut Shift Masuk.");

          await Get.defaultDialog(
            title: "Konfirmasi",
            middleText:
                "Apakah anda ingin mengisi ${collectionString == "presence" ? "absensi" : "lembur"} masuk kembali?",
            actions: [
              BackButton(),
              ConfirmButton(
                type: collectionString == "presence"
                    ? "Lanjut Shift Masuk"
                    : "Lanjut Lembur Masuk",
                collectionRef: collectionRef,
                getAddress: getAddress,
                getPosition: getPosition,
                inArea: inArea,
                now: now,
                duplicateId: duplicateDateId,
                //
                overtimeDesc: overtimeTextC.text,
              ),
            ],
          );
        } else if (duplicateDate.docs.length > 3) {
          Get.snackbar("Error",
              "Hari ini sudah melakukan 3 kali absensi, tidak dapat melakukan absensi kembali.");
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
                          : type == "Lanjut Shift Masuk"
                              ? () async {
                                  await collectionRef.doc(duplicateId).set(
                                        queryMasuk,
                                      );
                                  Get.back();
                                  Get.snackbar("Berhasil",
                                      "Anda sudah melakukan Absensi Masuk.");
                                }
                              : type == "Lanjut Shift Pulang"
                                  ? () async {
                                      await collectionRef
                                          .doc(duplicateId)
                                          .update(queryPulang);
                                      Get.back();
                                      Get.snackbar("Berhasil",
                                          "Anda sudah melakukan Absensi Pulang.");
                                    }
                                  : type == "Lanjut Lembur Masuk"
                                      ? () async {
                                          queryMasuk['description'] =
                                              overtimeDesc;
                                          await collectionRef
                                              .doc(duplicateId)
                                              .set(queryMasuk);
                                          Get.back();
                                          Get.snackbar("Berhasil",
                                              "Anda sudah melakukan Absensi Pulang.");
                                        }
                                      : type == "Lanjut Lembur Pulang"
                                          ? () async {
                                              queryPulang['total'] =
                                                  overtimeTotal;
                                              await collectionRef
                                                  .doc(duplicateId)
                                                  .update(queryPulang);
                                              Get.back();
                                              Get.snackbar("Berhasil",
                                                  "Anda sudah melakukan Absensi Pulang.");
                                            }
                                          : () => print("else"),
      child: Text("Confirm"),
    );
  }
}
