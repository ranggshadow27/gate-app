import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gate/app/components/colors.dart';

class RIcon extends StatelessWidget {
  RIcon({
    super.key,
    required this.icon,
    this.color,
    this.size,
  });
  final IconData icon;
  Color? color;
  double? size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size ?? 18,
      color: color ?? whiteColor,
    );
  }
}
