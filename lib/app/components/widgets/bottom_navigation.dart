import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:get/get.dart';
import 'package:uicons/uicons.dart';

import '../../controllers/page_setup_controller.dart';
import '../colors.dart';

class RBottomNavigation extends StatelessWidget {
  RBottomNavigation({super.key});
  final pageController = Get.find<PageSetupController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BottomBarCreative(
        items: [
          TabItem(icon: UIcons.solidRounded.home, title: "Home"),
          TabItem(icon: UIcons.solidRounded.time_quarter_to, title: "History"),
          TabItem(
            icon: pageController.isLoading.isFalse
                ? UIcons.solidRounded.fingerprint
                : UIcons.solidRounded.time_quarter_to,
          ),
          TabItem(icon: UIcons.solidRounded.document, title: "Report"),
          TabItem(icon: UIcons.solidRounded.user, title: "Profile"),
        ],
        // iconSize: 22,
        titleStyle: interSemiBold.copyWith(letterSpacing: 0),
        backgroundColor: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 6,
            spreadRadius: 1,
            offset: Offset(-2, -2),
          )
        ],
        color: whiteColor.withAlpha(60),
        colorSelected: whiteColor,
        indexSelected: pageController.initialPage.value,
        // isFloating: true,
        highlightStyle: const HighlightStyle(
          sizeLarge: true,
          background: greenColor,
          elevation: 3,
        ),
        onTap: (int index) => pageController.visitPage(index),
      ),
    );
  }
}
