import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gate/app/components/colors.dart';

class SvgIcon extends StatelessWidget {
  SvgIcon({
    this.color,
    required this.svgData,
    this.height,
    this.width,
    super.key,
  });

  final String svgData;
  double? height;
  double? width;
  Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      svgData,
      height: height == null ? 20 : height,
      width: width == null ? 20 : width,
      color: color == null ? whiteColor : color,
    );
  }
}
