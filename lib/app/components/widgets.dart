import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';

import 'fonts.dart';

class RGateButton extends StatelessWidget {
  RGateButton({
    required this.color,
    required this.text,
    required this.height,
    required this.width,
    required this.callback,
  });

  final Color color;
  final RText text;
  final double width;
  final double height;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: callback,
      child: text,
      style: ElevatedButton.styleFrom(
        fixedSize: Size(width, height),
        // elevation: 0,
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class RText extends StatelessWidget {
  RText({
    required this.text,
    required this.textStyle,
    this.color,
    this.size,
    this.maxLine,
  });

  final String text;
  final TextStyle textStyle;
  Color? color = whiteColor;
  double? size = 14;
  final int? maxLine;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLine,
      overflow: TextOverflow.ellipsis,
      style: textStyle.copyWith(
        color: color,
        fontSize: size,
      ),
    );
  }
}

class RNormalTextField extends StatelessWidget {
  const RNormalTextField({
    required this.hintText,
    required this.icon,
    required this.controller,
  });

  final String hintText;
  final IconData icon;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: interMedium.copyWith(color: whiteColor),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: whiteColor),
        hintText: hintText,
        hintStyle: interMedium.copyWith(color: bgColor.withAlpha(90)),
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
