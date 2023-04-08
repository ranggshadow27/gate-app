import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_widget.dart';

class PresenceHistoryDetailsController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? startTime;
  String endTime = DateTime.now().toIso8601String();

  // var data = [].obs;

  Future<QuerySnapshot<Map<String, dynamic>>> getUserPresenceHistory() async {
    String uid = auth.currentUser!.uid;

    if (startTime == null) {
      print("Ini adalah start -> $startTime");
      print("Ini adalah end -> $endTime");

      return await firestore
          .collection("users")
          .doc(uid)
          .collection("presence")
          .where("date", isLessThan: endTime)
          .orderBy("date", descending: true)
          .get();
    } else {
      print(startTime);
      print(endTime);

      return await firestore
          .collection("users")
          .doc(uid)
          .collection("presence")
          .where("date", isGreaterThan: startTime)
          .where("date", isLessThan: endTime)
          .orderBy("date", descending: true)
          .get();
    }
  }

  void pickDate(DateTime pickStartTime, DateTime pickEndTime) {
    startTime = pickStartTime.toIso8601String();
    endTime = pickEndTime
        .add(Duration(hours: 23, minutes: 59, seconds: 59))
        .toIso8601String();
    update();
  }

  Future<void> createPDF(
      List<dynamic> dataPresence, List<dynamic> dataUsers) async {
    Get.back();

    if (dataPresence.length == 0) {
      Get.snackbar("Error", "Tidak ada data yang dapat di Export");
    } else {
      final pdf = pw.Document();

      var getRegularFont =
          await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      var robotoRegularFont = pw.Font.ttf(getRegularFont);

      var getBoldFont = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
      var robotoBoldFont = pw.Font.ttf(getBoldFont);

      Map<String, pw.Font> fonts = {
        'regular': robotoRegularFont,
        'bold': robotoBoldFont,
      };

      var imageBytes = await rootBundle.load('assets/img/infracomlog.png');
      var image = imageBytes.buffer.asUint8List();

      pdf.addPage(
        pw.MultiPage(
          footer: (context) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Column(
                children: [
                  pw.Text("Penerima Tugas,"),
                  pw.SizedBox(height: 60),
                  pw.Text(dataUsers[0]['fullname']),
                  pw.Text("Gateway Operator"),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text("Pemberi Tugas,"),
                  pw.SizedBox(height: 60),
                  pw.Text(dataUsers[0]['fullname']),
                  pw.Text("GO Supervisor"),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text("Menyetujui,"),
                  pw.SizedBox(height: 60),
                  pw.Text(dataUsers[0]['fullname']),
                  pw.Text("Gateway Manager"),
                ],
              ),
            ],
          ),
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 1,
                        child: pw.Container(
                          width: 80,
                          child: pw.Image(
                            pw.MemoryImage(image),
                            fit: pw.BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      pw.Spacer(flex: 1),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          "SURAT PERINTAH LEMBUR",
                          style: pw.TextStyle(
                            font: robotoBoldFont,
                            fontSize: 12,
                            decoration: pw.TextDecoration.underline,
                          ),
                        ),
                      ),
                      pw.Spacer(flex: 2),
                    ],
                  ),

                  // pw.Text("jumlah data absen: ${dataPresence.length}",
                  //     textAlign: pw.TextAlign.left),
                  // pw.Text("jumlah data user: ${dataUsers.length}"),

                  RtitleRow(dataUsers, 'Name', 'fullname', fonts),
                  pw.SizedBox(height: 2),
                  RtitleRow(dataUsers, 'NIP', 'nip', fonts),
                  pw.SizedBox(height: 2),
                  RtitleRow(dataUsers, 'Jabatan', 'grade', fonts),
                  pw.SizedBox(height: 2),
                  RtitleRow(
                    dataUsers,
                    'Divisi/Departement',
                    'createdAt',
                    fonts,
                  ),
                  pw.SizedBox(height: 2),
                  RtitleRow(
                    dataUsers,
                    'Lokasi Kerja',
                    'address',
                    fonts,
                  ),
                  pw.SizedBox(height: 10),
                  buildTable(dataPresence, fonts),

                  pw.SizedBox(height: 10),
                ],
              ),
            ];
          },
        ),
      );

      Uint8List bytes = await pdf.save();

      final dir = await getApplicationDocumentsDirectory();
      final filePath = File('${dir.path}/MyPDF.pdf');

      await filePath.writeAsBytes(bytes);

      await OpenFile.open(filePath.path);
    }
  }

  pw.Row RtitleRow(
    List<dynamic> dataUsers,
    String text,
    String dataValue,
    Map<String, pw.Font> font,
  ) {
    pw.TextStyle boldFontStyle = pw.TextStyle(font: font['bold'], fontSize: 10);
    return pw.Row(
      children: [
        pw.Container(
          width: 120,
          child: pw.Text(
            "${text} : ",
            style: boldFontStyle,
          ),
        ),
        pw.Text(
          dataUsers[0][dataValue],
          style: boldFontStyle,
        ),
      ],
    );
  }
}

class DataController extends GetxController {
  final historyC = Get.find<PresenceHistoryDetailsController>();
  FirebaseAuth auth = FirebaseAuth.instance;
  var dataPresence = [].obs;
  var dataUser = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    String uid = auth.currentUser!.uid;

    QuerySnapshot<Map<String, dynamic>> snapshotPresence = await historyC
        .firestore
        .collection("users")
        .doc(uid)
        .collection("presence")
        .where("date", isGreaterThan: historyC.startTime)
        .where("date", isLessThan: historyC.endTime)
        .orderBy("date", descending: true)
        .get();

    DocumentSnapshot<Map<String, dynamic>> snapshotUser =
        await historyC.firestore.collection('users').doc(uid).get();

    Map<String, dynamic>? getDataUser = snapshotUser.data();

    dataUser.value = [getDataUser];
    dataPresence.value = snapshotPresence.docs.map((e) => e.data()).toList();
  }
}
