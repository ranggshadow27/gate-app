import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/icon_data.dart';
import 'package:gate/app/components/widgets/button.dart';
import 'package:gate/app/components/widgets/svgicon.dart';
import 'package:gate/app/components/widgets/text_widget.dart';
import 'package:gate/app/components/widgets/textfield.dart';

import 'package:get/get.dart';

import '../controllers/reset_default_password_controller.dart';

class ResetDefaultPasswordView extends GetView<ResetDefaultPasswordController> {
  @override
  Widget build(BuildContext context) {
    RxBool showPassword = true.obs;
    RxBool showConfPassword = true.obs;

    return Scaffold(
      backgroundColor: bgColor,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 68),
        children: [
          RText(
            text: "Password Default Detected",
            textStyle: interSemiBold.copyWith(
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: 16),
          RText(
            text: "Please renew password to improve your account security.",
            textStyle: interRegular,
          ),
          SizedBox(height: 36),
          Obx(
            () => RTextField(
              hintText: "Type New Password",
              icon: SvgIcon(svgData: RSvgData.lock),
              controller: controller.newPassC,
              isPassword: showConfPassword.value,
              maxLines: 1,
              suffixIcon: IconButton(
                onPressed: () {
                  showConfPassword.toggle();
                },
                icon: showConfPassword == false
                    ? SvgIcon(svgData: RSvgData.eye)
                    : SvgIcon(
                        svgData: RSvgData.eyeCrossed,
                      ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Obx(
            () => RTextField(
              hintText: "Confirm New Password",
              icon: SvgIcon(svgData: RSvgData.lock),
              controller: controller.confirmNewPassC,
              isPassword: showPassword.value,
              maxLines: 1,
              suffixIcon: IconButton(
                onPressed: () {
                  showPassword.toggle();
                },
                icon: showPassword == false
                    ? SvgIcon(svgData: RSvgData.eye)
                    : SvgIcon(
                        svgData: RSvgData.eyeCrossed,
                      ),
              ),
            ),
          ),
          SizedBox(height: 28),
          Obx(
            () => RButton(
              color: greenColor,
              text: controller.isLoading.isFalse ? "Change Password" : "Loading ..",
              callback: () {
                if (controller.isLoading.isFalse) {
                  controller.changePassword();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
