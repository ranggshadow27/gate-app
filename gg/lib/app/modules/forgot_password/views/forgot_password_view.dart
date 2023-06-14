import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';

import 'package:get/get.dart';

import '../../../components/fonts.dart';
import '../../../components/icon_data.dart';
import '../../../components/widgets/appbar.dart';
import '../../../components/widgets/button.dart';
import '../../../components/widgets/svgicon.dart';
import '../../../components/widgets/text_widget.dart';
import '../../../components/widgets/textfield.dart';
import '../../../routes/app_pages.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          RAppBar(
            onPressed: () => Get.offAllNamed(Routes.LOGIN),
            title: "Forgot Password",
          ),
          Container(
            height: Get.height - Get.statusBarHeight,
            padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
            child: Column(
              children: [
                Expanded(
                  flex: 9,
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      RText(
                        text:
                            "Please input your email address, we will send reset form to your email!",
                        textStyle: interRegular,
                        color: whiteColor,
                      ),
                      SizedBox(height: 30),
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
                      SizedBox(height: 24),
                      Obx(
                        () => RButton(
                          color: greenColor,
                          text: controller.isLoading.isFalse ? "Send Reset Password" : "Loading ..",
                          height: 60,
                          width: Get.width,
                          callback: () async {
                            if (controller.isLoading.isFalse) {
                              await controller.forgotPassword();
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
