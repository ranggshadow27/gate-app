import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

import '../colors.dart';
import '../fonts.dart';

class RTextField extends StatelessWidget {
  RTextField({
    required this.hintText,
    required this.icon,
    required this.controller,
    this.isPassword,
    this.inputType,
    this.suffixIcon,
  });

  final String hintText;
  final Widget icon;
  final TextEditingController controller;
  final TextInputType? inputType;
  bool? isPassword = false;
  Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    RxBool suffix = false.obs;

    return TextField(
      autocorrect: false,
      autofocus: false,
      cursorColor: whiteColor,
      obscureText: isPassword == true ? true : false,
      keyboardType: inputType,
      controller: controller,
      style: interMedium.copyWith(color: whiteColor, fontSize: 14.0),
      onChanged: (value) {
        if (value != "") {
          suffix.value = true;
        }
        if (value == "") {
          suffix.value = false;
        }
      },
      decoration: InputDecoration(
        prefixIcon: icon,
        prefixIconConstraints: BoxConstraints(minWidth: 60),
        suffixIcon: suffixIcon,
        suffixIconConstraints: BoxConstraints(minWidth: 20),
        hintText: hintText,
        hintStyle: interMedium.copyWith(color: whiteColor.withAlpha(90)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: whiteColor,
          ),
        ),
      ),
    );
  }
}
