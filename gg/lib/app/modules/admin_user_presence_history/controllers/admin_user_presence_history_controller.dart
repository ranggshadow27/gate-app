import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gate/app/modules/presence_history/controllers/utils.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../presence_history/controllers/pdf_widget.dart';

class AdminUserPresenceHistoryController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String getUserUID = Get.arguments;

  String filterOption = "Normal Presence";
  bool filterType = true;
  String? startDate;
  String endDate = DateTime.now().toIso8601String();
  List<dynamic> dataPresence = [];
  List<dynamic> dataOvertime = [];
  List<dynamic> dataUser = [];

  Future<QuerySnapshot<Map<String, dynamic>>> getUserPresenceHistory(
    String getFilterOption,
    bool getFilterType,
  ) async {
    DocumentReference<Map<String, dynamic>> documentRef =
        firestore.collection('users').doc(getUserUID);

    if (startDate == null) {
      return await documentRef
          .collection(
            '${getFilterOption == filterOption ? 'presence' : 'overtime'}',
          )
          .where('date', isLessThan: endDate)
          .orderBy(
            'date',
            descending: getFilterType == filterType ? true : false,
          )
          .get();
    } else {
      return await documentRef
          .collection(
            '${getFilterOption == filterOption ? 'presence' : 'overtime'}',
          )
          .where('date', isGreaterThan: startDate)
          .where('date', isLessThan: endDate)
          .orderBy(
            'date',
            descending: getFilterType == filterType ? true : false,
          )
          .get();
    }
  }

  Future<void> getUserData() async {
    DocumentReference<Map<String, dynamic>> documentRef =
        firestore.collection('users').doc(getUserUID);

    QuerySnapshot<Map<String, dynamic>> userPresenceData = await documentRef
        .collection('presence')
        .where("date", isGreaterThan: startDate)
        .where("date", isLessThan: endDate)
        .orderBy("date", descending: false)
        .get();

    QuerySnapshot<Map<String, dynamic>> userOvertimeData = await documentRef
        .collection('overtime')
        .where("date", isGreaterThan: startDate)
        .where("date", isLessThan: endDate)
        .orderBy("date", descending: false)
        .get();

    DocumentSnapshot<Map<String, dynamic>> getUserInfo =
        await documentRef.get();

    Map<String, dynamic>? userInfo = getUserInfo.data();

    dataUser = [userInfo];
    dataPresence = userPresenceData.docs.map((e) => e.data()).toList();
    dataOvertime = userOvertimeData.docs.map((e) => e.data()).toList();
  }

  getDate({
    required DateTime? getStartDate,
    required DateTime getEndDate,
  }) async {
    startDate = getStartDate!.toIso8601String();
    endDate =
        getEndDate.add(Duration(hours: 23, minutes: 59)).toIso8601String();

    update();
  }

  String dateFormat(String inputDate) {
    String formatDate =
        DateFormat("EEEE, dd MMMM yyyy").format(DateTime.parse(inputDate));

    return formatDate;
  }

  Future<void> createPDF() async {
    await getUserData();

    if (dataPresence.length == 0) {
      Get.snackbar("Error", "Tidak ada data yang dapat di Export");
    } else {
      final pdf = pw.Document();

      final nowFormat =
          formatDate(DateTime.now().toIso8601String()).replaceAll("/", "");

      var getRegularFont =
          await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      var robotoRegularFont = pw.Font.ttf(getRegularFont);

      var getBoldFont = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
      var robotoBoldFont = pw.Font.ttf(getBoldFont);

      Map<String, pw.Font> myFonts = {
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
              RFooterPage(
                dataUsers: dataUser,
                title: "Penerima Tugas,",
                dataValue: '${dataUser[0]['fullname']}',
                grade: "Gateway Operator",
                font: myFonts['bold'],
              ),
              RFooterPage(
                dataUsers: dataUser,
                title: "Pemberi Tugas,",
                dataValue: "Sifaudin",
                grade: "GO Supervisor",
                font: myFonts['bold'],
              ),
              RFooterPage(
                dataUsers: dataUser,
                title: "Menyetujui,",
                dataValue: "Eko Cahyo P.",
                grade: "Gateway Manager",
                font: myFonts['bold'],
              ),
            ],
          ),
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Stack(
                children: [
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
                      RtitleRow(
                        dataUsers: dataUser,
                        text: 'Name',
                        dataValue: 'fullname',
                        font: myFonts,
                      ),
                      RtitleRow(
                        dataUsers: dataUser,
                        text: 'NIP',
                        dataValue: 'nip',
                        font: myFonts,
                      ),
                      RtitleRow(
                        dataUsers: dataUser,
                        text: 'Jabatan',
                        dataValue: 'grade',
                        font: myFonts,
                      ),
                      RtitleRow(
                        dataUsers: dataUser,
                        text: 'Divisi/Departement',
                        dataValue: 'createdAt',
                        font: myFonts,
                      ),
                      RtitleRow(
                        dataUsers: dataUser,
                        text: 'Lokasi Kerja',
                        dataValue: 'address',
                        font: myFonts,
                      ),
                      pw.SizedBox(height: 10),
                      buildTable(
                        tableType: "Presence",
                        dataValue: dataPresence,
                        font: myFonts,
                      ),
                      dataOvertime.isEmpty || dataOvertime.length == 0
                          ? pw.SizedBox()
                          : pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.SizedBox(height: 10),
                                pw.Text(
                                  "Overtime",
                                  style: pw.TextStyle(
                                    font: myFonts['bold'],
                                    fontSize: 10,
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                buildTable(
                                  tableType: "Overtime",
                                  dataValue: dataOvertime,
                                  font: myFonts,
                                ),
                              ],
                            ),
                      pw.SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ];
          },
        ),
      );

      Uint8List bytes = await pdf.save();

      final dir = await getApplicationDocumentsDirectory();
      final filePath = File(
          '${dir.path}/${nowFormat}_ExportPDF_${dataUser[0]['fullname']}.pdf');

      await filePath.writeAsBytes(bytes);

      await OpenFile.open(filePath.path);
    }
  }

  pw.Column RFooterPage({
    required List<dynamic> dataUsers,
    required String title,
    required String dataValue,
    required String grade,
    pw.Font? font,
  }) {
    pw.TextStyle fontStyle = pw.TextStyle(font: font, fontSize: 10);
    return pw.Column(
      children: [
        pw.Text(title, style: fontStyle),
        pw.SizedBox(height: 60),
        pw.Text(
          dataValue.toUpperCase(),
          style: fontStyle.copyWith(decoration: pw.TextDecoration.underline),
        ),
        pw.Text(grade.toUpperCase(), style: fontStyle),
      ],
    );
  }

  pw.Row RtitleRow({
    required List<dynamic> dataUsers,
    required String text,
    required String dataValue,
    required Map<String, pw.Font> font,
  }) {
    pw.TextStyle boldFontStyle = pw.TextStyle(font: font['bold'], fontSize: 10);
    return pw.Row(
      children: [
        pw.Container(
          width: 100,
          child: pw.Text(
            text,
            style: boldFontStyle,
          ),
        ),
        pw.Text(
          " : ",
          style: boldFontStyle,
        ),
        pw.Text(
          dataUsers[0][dataValue],
          style: boldFontStyle,
        ),
      ],
    );
  }
}
