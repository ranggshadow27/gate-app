import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:get/get.dart';

import 'text_widget.dart';

class RButton extends StatelessWidget {
  RButton({
    required this.color,
    required this.text,
    required this.callback,
    this.width,
    this.height,
    this.borderC,
    this.borderWidth,
    this.fontColor,
  });

  final Color color;
  final String text;
  final VoidCallback callback;
  Color? borderC;
  Color? fontColor;
  double? borderWidth;
  double? width;
  double? height;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: callback,
      child: RText(
        text: text,
        textStyle: interSemiBold,
        color: fontColor ?? whiteColor,
      ),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(width == null ? Get.width : width!, height == null ? 60 : height!),
        // elevation: 0,
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: borderC ?? Colors.transparent,
            width: borderWidth ?? 0,
          ),
        ),
      ),
    );
  }
}
