import 'package:flutter/material.dart';
import 'package:gate/app/components/widgets/svgicon.dart';

import '../colors.dart';
import '../fonts.dart';
import '../icon_data.dart';

class RAppBar extends StatelessWidget {
  RAppBar({
    super.key,
    required this.onPressed,
    required this.title,
    this.color,
    this.hPadding,
  });

  final VoidCallback onPressed;
  final String title;
  Color? color;
  double? hPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPadding == null ? 0 : hPadding!),
      height: 60,
      child: Row(
        children: [
          IconButton(
            onPressed: onPressed,
            icon: SvgIcon(
              svgData: RSvgData.arrowLeft,
              color: color == null ? whiteColor : color!,
              height: 28,
              width: 28,
            ),
          ),
          Spacer(),
          Text(
            title,
            style: interBold.copyWith(
              color: color == null ? whiteColor : color!,
              fontSize: 16.0,
            ),
            textAlign: TextAlign.center,
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}
