import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'utils.dart';

pw.Widget buildTable({
  required List<dynamic> dataValue,
  required Map<String, pw.Font> font,
  required String tableType,
}) {
  return pw.Table(
    border: pw.TableBorder.all(),
    children: [
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey400),
        children: [
          tableHeaders(title: 'Tanggal', font: font['bold'], flex: 2),
          tableHeaders(title: 'Jam Masuk', font: font['bold'], flex: 2),
          tableHeaders(title: 'Jam Pulang', font: font['bold'], flex: 2),
          tableHeaders(title: 'Keterangan Lembur', font: font['bold'], flex: 4),
          tableHeaders(
            title: tableType == "Presence" ? 'Keperluan' : 'Total',
            font: font['bold'],
            flex: 2,
          ),
        ],
      ),
      for (var i = 0; i < dataValue.length; i++)
        pw.TableRow(
          children: [
            RNormalRows(
              formatDate(dataValue[i]['date']),
              font['bold'],
            ),
            RHourRows(
              formatHours(dataValue[i]['masuk']['datetime']),
              dataValue[i]['masuk']['inArea'],
              font['bold'],
            ),
            dataValue[i]['pulang'] != null
                ? RHourRows(
                    formatHours(dataValue[i]['pulang']['datetime']),
                    dataValue[i]['pulang']['inArea'],
                    font['bold'],
                  )
                : RHourRows(
                    "-",
                    true,
                    font['bold'],
                  ),
            RNormalRows(
              tableType == "Presence" ? "-" : dataValue[i]['description'],
              font['bold'],
            ),
            tableType == "Presence"
                ? RNormalRows(
                    getHour(dataValue, i) > 3 && getHour(dataValue, i) < 12
                        ? "Shift 1"
                        : getHour(dataValue, i) >= 13 && getHour(dataValue, i) <= 18
                            ? "Shift 2"
                            : "Shift 3",
                    font['bold'],
                  )
                : RNormalRows(
                    dataValue[i]['total'] == null
                        ? "-"
                        : overtimeToHours(dataValue: dataValue, i: i) >= 8
                            ? "1 Shift"
                            : "${overtimeToHours(dataValue: dataValue, i: i)} Jam",
                    font['bold'],
                  ),
          ],
        ),
    ],
  );
}

int overtimeToHours({required List<dynamic> dataValue, required int i}) {
  int overtime = 0;

  String getUserOvertime = dataValue[i]['total'].toString().replaceAll(" Minutes", "");

  double overtimeToHours = int.parse(getUserOvertime) / 60;

  overtime = overtimeToHours.toInt();
  print(overtime);

  return overtime;
}

pw.Expanded tableHeaders({
  required String title,
  required int flex,
  pw.Font? font,
}) {
  return pw.Expanded(
    flex: flex,
    child: pw.Padding(
      padding: pw.EdgeInsets.all(6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(font: font, fontSize: 10),
          ),
        ],
      ),
    ),
  );
}

pw.Container RHourRows(String datetime, bool inArea, pw.Font? font) {
  return pw.Container(
    color: inArea == false ? PdfColors.grey300 : null,
    padding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 6),
    child: pw.Column(
      children: [
        pw.Text(
          datetime,
          style: pw.TextStyle(
            color: inArea == false ? PdfColors.red800 : PdfColors.black,
            font: font,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

pw.Padding RNormalRows(String data, pw.Font? font) {
  return pw.Padding(
    padding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 6),
    child: pw.Column(
      children: [
        pw.Text(
          data,
          maxLines: 2,
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}
