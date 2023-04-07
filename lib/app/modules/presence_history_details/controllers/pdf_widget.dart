import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'utils.dart';

pw.Widget buildTable(List<dynamic> dataPresence) {
  return pw.Table(
    border: pw.TableBorder.all(),
    children: [
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey400),
        children: [
          tableHeaders('Date', pw.CrossAxisAlignment.start),
          tableHeaders('Masuk', pw.CrossAxisAlignment.center),
          tableHeaders('Pulang', pw.CrossAxisAlignment.center),
          tableHeaders('Status', pw.CrossAxisAlignment.center),
          tableHeaders('Keperluan', pw.CrossAxisAlignment.center),
        ],
      ),
      for (var i = 0; i < dataPresence.length; i++)
        pw.TableRow(
          children: [
            RDateRow(formatDate(dataPresence[i]['date']), 4),
            RHourRows(
              formatHours(dataPresence[i]['masuk']['datetime']),
              2,
              dataPresence[i]['masuk']['inArea'],
            ),
            dataPresence[i]['pulang'] != null
                ? RHourRows(formatHours(dataPresence[i]['pulang']['datetime']),
                    2, dataPresence[i]['pulang']['inArea'])
                : RHourRows("-", 2, true),
            RRows(dataPresence[i]['status'], 2, true),
            RRows(
              getHour(dataPresence, i) < 10
                  ? "Shift 1"
                  : getHour(dataPresence, i) < 18
                      ? "Shift 2"
                      : "Shift 3",
              2,
              true,
            ),
          ],
        ),
    ],
  );
}

pw.Padding tableHeaders(String title, pw.CrossAxisAlignment pos) {
  return pw.Padding(
    padding: pw.EdgeInsets.all(6),
    child: pw.Column(
      crossAxisAlignment: pos,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ],
    ),
  );
}

pw.Expanded RHourRows(String datetime, int flex, bool inArea) {
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
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

pw.Expanded RRows(String datetime, int flex, bool inArea) {
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
              fontWeight:
                  inArea == false ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}

pw.Expanded RDateRow(String data, int flex) {
  return pw.Expanded(
    flex: flex,
    child: pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            data,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}
