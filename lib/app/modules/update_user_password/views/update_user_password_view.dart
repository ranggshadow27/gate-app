import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/icon_data.dart';
import 'package:gate/app/components/widgets/appbar.dart';
import 'package:gate/app/components/widgets/button.dart';
import 'package:gate/app/components/widgets/svgicon.dart';
import 'package:gate/app/components/widgets/text_widget.dart';
import 'package:gate/app/components/widgets/textfield.dart';

import 'package:get/get.dart';

import '../controllers/update_user_password_controller.dart';

class UpdateUserPasswordView extends GetView<UpdateUserPasswordController> {
  @override
  Widget build(BuildContext context) {
    RxBool showOldPass = true.obs;
    RxBool showNewPass = true.obs;
    RxBool showConfirmPass = true.obs;

    return Scaffold(
      backgroundColor: bgColor,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        children: [
          RAppBar(
            onPressed: () => Get.back(),
            title: "Update Password",
          ),
          SizedBox(height: 30),
          RText(
            text: "Change your account password anytime to improve account security.",
            textStyle: interRegular,
          ),
          SizedBox(height: 30),
          RText(
            text: "Old Password.",
            textStyle: interMedium,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 10),
          Obx(
            () => RTextField(
              hintText: "Old Password",
              icon: SvgIcon(svgData: RSvgData.lock),
              controller: controller.oldPassC,
              isPassword: showOldPass.value,
              maxLines: 1,
              suffixIcon: IconButton(
                onPressed: () {
                  showOldPass.toggle();
                },
                icon: SvgIcon(svgData: showOldPass.isTrue ? RSvgData.eyeCrossed : RSvgData.eye),
              ),
            ),
          ),
          SizedBox(height: 20),
          RText(
            text: "New Password.",
            textStyle: interMedium,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 10),
          Obx(
            () => RTextField(
              hintText: "New Password",
              icon: SvgIcon(svgData: RSvgData.lock),
              controller: controller.newPassC,
              isPassword: showNewPass.value,
              maxLines: 1,
              suffixIcon: IconButton(
                onPressed: () {
                  showNewPass.toggle();
                },
                icon: SvgIcon(svgData: showNewPass.isTrue ? RSvgData.eyeCrossed : RSvgData.eye),
              ),
            ),
          ),
          SizedBox(height: 20),
          RText(
            text: "Confirm New Password.",
            textStyle: interMedium,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 10),
          Obx(
            () => RTextField(
              hintText: "Confirm New Password",
              icon: SvgIcon(svgData: RSvgData.lock),
              controller: controller.confirmPassC,
              isPassword: showConfirmPass.value,
              maxLines: 1,
              suffixIcon: IconButton(
                onPressed: () {
                  showConfirmPass.toggle();
                },
                icon: SvgIcon(svgData: showConfirmPass.isTrue ? RSvgData.eyeCrossed : RSvgData.eye),
              ),
            ),
          ),
          SizedBox(height: 20),
          Obx(
            () => RButton(
              color: greenColor,
              text: controller.isLoading.isFalse ? "Update Password." : "Loading..",
              callback: () async {
                if (controller.isLoading.isFalse) {
                  await controller.updatePassword();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
