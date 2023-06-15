import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/appbar.dart';
import 'package:gate/app/components/widgets/button.dart';
import 'package:gate/app/components/widgets/text_widget.dart';
import 'package:gate/app/components/widgets/textfield.dart';

import 'package:get/get.dart';

import '../controllers/update_user_profile_controller.dart';

class UpdateUserProfileView extends GetView<UpdateUserProfileController> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> userData = Get.arguments;

    controller.emailC.text = userData['email'];
    controller.gradeC.text = userData['grade'];
    controller.nipC.text = userData['nip'];
    controller.fullnameC.text = userData['fullname'];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            RAppBar(
                onPressed: () {
                  controller.image = null;
                  Get.back();
                },
                title: "Update User Profile"),
            SizedBox(height: 20),
            RText(
              text: "Username.",
              textStyle: interSemiBold,
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            RTextField(hintText: 'Username', controller: controller.fullnameC),
            SizedBox(height: 20),
            RText(
              text: "Avatar.",
              textStyle: interSemiBold,
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GetBuilder<UpdateUserProfileController>(
                  builder: (controller) {
                    if (controller.image != null) {
                      return ClipOval(
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: Image.file(
                            File(controller.image!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    } else {
                      if (userData['avatar'] != null) {
                        return Row(
                          children: [
                            ClipOval(
                              child: SizedBox(
                                height: 100,
                                width: 100,
                                child: Image.network(
                                  userData['avatar'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Obx(
                              () => TextButton(
                                onPressed: () {
                                  controller.deleteAvatar();
                                },
                                child: controller.isAvatarDelete.isFalse
                                    ? RText(
                                        text: "X",
                                        textStyle: interSemiBold,
                                        color: redColor,
                                        textAlign: TextAlign.start,
                                      )
                                    : SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(),
                                      ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return RText(
                          text: "No Avatar.",
                          textStyle: interSemiBold,
                          textAlign: TextAlign.start,
                        );
                      }
                    }
                  },
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    controller.getImage();
                  },
                  child: RText(
                    color: greenColor,
                    isUnderlined: true,
                    text: "Choose file.",
                    textStyle: interSemiBold,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Obx(
              () => RButton(
                color: greenColor,
                text: controller.isLoading.isFalse ? "Update Profile." : "Loading..",
                callback: () async {
                  if (controller.isLoading.isFalse) {
                    await controller.updateProfile();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
