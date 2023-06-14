import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/icon_data.dart';
import 'package:gate/app/components/widgets/button.dart';
import 'package:gate/app/components/widgets/svgicon.dart';
import 'package:gate/app/components/widgets/text_widget.dart';
import 'package:gate/app/components/widgets/textfield.dart';

import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  RxBool isPassword = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        body: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Container(
              height: Get.height - Get.statusBarHeight,
              padding: EdgeInsets.fromLTRB(30, 80, 30, 0),
              child: Column(
                children: [
                  Expanded(
                    flex: 9,
                    child: Column(
                      children: [
                        Text.rich(
                          style: interBold.copyWith(color: whiteColor, fontSize: 16.0),
                          TextSpan(
                            text: "Hi. Welcome to ",
                            children: [
                              TextSpan(text: "Gate", style: interBold.copyWith(color: greenColor)),
                              TextSpan(text: "!"),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        RText(
                          text: "Please Sign In to your account first.",
                          textStyle: interRegular,
                          color: whiteColor,
                          fontSize: 16,
                        ),
                        SizedBox(height: 62),
                        RTextField(
                          hintText: 'Email',
                          icon: SvgIcon(
                            svgData: RSvgData.envelope,
                            height: 20,
                            width: 20,
                            color: whiteColor,
                          ),
                          inputType: TextInputType.emailAddress,
                          controller: controller.emailC,
                        ),
                        SizedBox(height: 16),
                        Obx(
                          () => RTextField(
                            hintText: 'Password',
                            icon: SvgIcon(svgData: RSvgData.lock),
                            suffixIcon: IconButton(
                              onPressed: () {
                                isPassword.toggle();
                              },
                              icon: SvgIcon(
                                  svgData: isPassword.isFalse ? RSvgData.eye : RSvgData.eyeCrossed),
                            ),
                            inputType: TextInputType.emailAddress,
                            isPassword: isPassword.isFalse ? false : true,
                            controller: controller.passC,
                          ),
                        ),
                        SizedBox(height: 24),
                        Obx(
                          () => RButton(
                            color: greenColor,
                            text: controller.isLoading.isFalse ? "Sign In" : "Loading ..",
                            width: Get.width,
                            callback: () async {
                              if (controller.isLoading.isFalse) {
                                await controller.login();
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 14),
                        TextButton(
                          onPressed: () => Get.toNamed(Routes.FORGOT_PASSWORD),
                          child: Text(
                            "Forgot Password?",
                            style: interBold.copyWith(
                              color: redColor,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        RText(
                          text: "GATE",
                          color: greenColor,
                          fontSize: 24.0,
                          textStyle: interBold,
                        ),
                        RText(text: "Application", fontSize: 16.0, textStyle: interRegular),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
