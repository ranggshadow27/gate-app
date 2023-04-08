import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'utils.dart';

pw.Widget buildTable(List<dynamic> dataPresence, Map<String, pw.Font> font) {
  return pw.Table(
    border: pw.TableBorder.all(),
    children: [
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey400),
        children: [
          tableHeaders('Date', pw.CrossAxisAlignment.start, font['bold']),
          tableHeaders('Masuk', pw.CrossAxisAlignment.center, font['bold']),
          tableHeaders('Pulang', pw.CrossAxisAlignment.center, font['bold']),
          tableHeaders('Status', pw.CrossAxisAlignment.center, font['bold']),
          tableHeaders('Keperluan', pw.CrossAxisAlignment.center, font['bold']),
        ],
      ),
      for (var i = 0; i < dataPresence.length; i++)
        pw.TableRow(
          children: [
            RDateRow(
              formatDate(dataPresence[i]['date']),
              4,
              font['bold'],
            ),
            RHourRows(
              formatHours(dataPresence[i]['masuk']['datetime']),
              2,
              dataPresence[i]['masuk']['inArea'],
              font['bold'],
            ),
            dataPresence[i]['pulang'] != null
                ? RHourRows(formatHours(dataPresence[i]['pulang']['datetime']),
                    2, dataPresence[i]['pulang']['inArea'], font['bold'])
                : RHourRows(
                    "-",
                    2,
                    true,
                    font['bold'],
                  ),
            RRows(
              dataPresence[i]['status'],
              2,
              true,
              font['regular'],
            ),
            RRows(
              getHour(dataPresence, i) < 10
                  ? "Shift 1"
                  : getHour(dataPresence, i) < 18
                      ? "Shift 2"
                      : "Shift 3",
              2,
              true,
              font['bold'],
            ),
          ],
        ),
    ],
  );
}

pw.Padding tableHeaders(
    String title, pw.CrossAxisAlignment position, pw.Font? font) {
  return pw.Padding(
    padding: pw.EdgeInsets.all(6),
    child: pw.Column(
      crossAxisAlignment: position,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
      ],
    ),
  );
}

pw.Expanded RHourRows(String datetime, int flex, bool inArea, pw.Font? font) {
  return pw.Expanded(
    flex: flex,
    child: pw.Container(
      color: inArea == false ? PdfColors.grey300 : PdfColors.white,
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
    ),
  );
}

pw.Expanded RRows(String datetime, int flex, bool inArea, pw.Font? font) {
  return pw.Expanded(
    flex: flex,
    child: pw.Padding(
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
    ),
  );
}

pw.Expanded RDateRow(String data, int flex, pw.Font? font) {
  return pw.Expanded(
    flex: flex,
    child: pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            data,
            style: pw.TextStyle(font: font, fontSize: 10),
          ),
        ],
      ),
    ),
  );
}
