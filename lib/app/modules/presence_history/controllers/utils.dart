import 'package:intl/intl.dart';

String formatHours(String date) {
  String formatedString = DateFormat("HH:mm").format(DateTime.parse(date));

  return formatedString;
}

String formatDate(String date) {
  String formatedString = DateFormat("dd/MM/yyyy").format(DateTime.parse(date));

  return formatedString;
}

int getHour(List<dynamic> data, int i) {
  int getHourValue = 0;

  String formatTime =
      DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse(data[i]['masuk']['datetime']));
  DateTime getTime = DateTime.parse(formatTime);

  getHourValue = getTime.hour;

  return getHourValue;
}
