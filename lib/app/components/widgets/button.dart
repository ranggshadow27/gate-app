import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';

import 'text_widget.dart';

class RButton extends StatelessWidget {
  RButton({
    required this.color,
    required this.text,
    required this.callback,
    this.width,
    this.height,
  });

  final Color color;
  final String text;
  final VoidCallback callback;
  double? width;
  double? height;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: callback,
      child: RText(
        text: text,
        textStyle: interSemiBold,
      ),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(width == null ? double.infinity : width!, height == null ? 60 : height!),
        // elevation: 0,
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
