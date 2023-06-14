import 'package:flutter/material.dart';

import '../colors.dart';

class RText extends StatelessWidget {
  RText({
    required this.text,
    required this.textStyle,
    this.color,
    this.fontSize,
    this.maxLine,
    this.isOverflow,
  });

  final String text;
  final TextStyle textStyle;
  final int? maxLine;
  Color? color;
  double? fontSize;
  bool? isOverflow;
  TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLine,
      overflow: isOverflow == true ? TextOverflow.ellipsis : null,
      style: textStyle.copyWith(
        color: color ?? whiteColor,
        fontSize: fontSize ?? 14,
      ),
      textAlign: TextAlign.center,
    );
  }
}
