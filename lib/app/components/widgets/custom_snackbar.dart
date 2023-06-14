import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';

import '../colors.dart';
import '../fonts.dart';

GetSnackBar buildSnackError(
  String middleText,
) {
  return GetSnackBar(
    titleText: Text(
      "Error",
      style: interBold.copyWith(
        color: bgColor,
        fontSize: 16.0,
      ),
    ),
    messageText: Text(
      middleText,
      style: interRegular.copyWith(
        color: bgColor,
      ),
    ),
    backgroundColor: whiteColor.withOpacity(.5),
    duration: Duration(seconds: 2),
    snackPosition: SnackPosition.TOP,
    snackStyle: SnackStyle.FLOATING,
    borderRadius: 16,
    margin: EdgeInsets.all(10),
  );
}

GetSnackBar buildSnackSuccess(
  String middleText,
) {
  return GetSnackBar(
    titleText: Text(
      "Success",
      style: interBold.copyWith(
        color: bgColor,
        fontSize: 16.0,
      ),
    ),
    messageText: Text(
      middleText,
      style: interRegular.copyWith(
        color: bgColor,
      ),
    ),
    backgroundColor: whiteColor.withOpacity(.5),
    duration: Duration(seconds: 2),
    snackPosition: SnackPosition.TOP,
    snackStyle: SnackStyle.FLOATING,
    borderRadius: 16,
    margin: EdgeInsets.all(10),
  );
}

GetSnackBar buildSnack(
  String title,
  String middleText,
) {
  return GetSnackBar(
    titleText: Text(
      title,
      style: interBold.copyWith(
        color: bgColor,
        fontSize: 16.0,
      ),
    ),
    messageText: Text(
      middleText,
      style: interRegular.copyWith(
        color: bgColor,
      ),
    ),
    backgroundColor: whiteColor.withOpacity(.5),
    duration: Duration(seconds: 2),
    snackPosition: SnackPosition.TOP,
    snackStyle: SnackStyle.FLOATING,
    borderRadius: 16,
    margin: EdgeInsets.all(10),
  );
}
