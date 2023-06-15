import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/appbar.dart';
import 'package:gate/app/components/widgets/button.dart';
import 'package:gate/app/components/widgets/text_widget.dart';
import 'package:gate/app/components/widgets/textfield.dart';

import 'package:get/get.dart';

import '../controllers/admin_user_salary_controller.dart';

class AdminUserSalaryView extends GetView<AdminUserSalaryController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Obx(
        () {
          var getData = controller.map;
          controller.mainSalaryC.text =
              getData['main'] == null ? "Mengambil data .." : getData['main'].toString();
          controller.dailySalaryC.text =
              getData['daily'] == null ? "Mengambil data .." : getData['daily'].toString();
          controller.allowanceSalaryC.text =
              getData['allowance'] == null ? "Mengambil data .." : getData['allowance'].toString();
          controller.bpjsC.text =
              getData['bpjs'] == null ? "Mengambil data .." : getData['bpjs'].toString();
          controller.bpjskC.text =
              getData['bpjsk'] == null ? "Mengambil data .." : getData['bpjsk'].toString();

          return SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                RAppBar(onPressed: () => Get.back(), title: "User Salary"),
                SizedBox(height: 10),
                RSalaryTextField(
                  controller: controller.mainSalaryC,
                  title: "Main Salary",
                ),
                RSalaryTextField(
                  controller: controller.dailySalaryC,
                  title: "Daily Salary",
                ),
                RSalaryTextField(
                  controller: controller.allowanceSalaryC,
                  title: "Allowance",
                ),
                RSalaryTextField(
                  controller: controller.bpjsC,
                  title: "BPJS",
                ),
                RSalaryTextField(
                  controller: controller.bpjskC,
                  title: "BPJS Ketenagakerjaan",
                ),
                SizedBox(height: 10),
                RButton(
                  color: greenColor,
                  text: controller.isLoading.isFalse ? "Update Salary Info" : "Loading ..",
                  callback: () {
                    controller.updateUserSalary();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RSalaryTextField extends StatelessWidget {
  const RSalaryTextField({
    super.key,
    required this.controller,
    required this.title,
  });

  final TextEditingController controller;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RText(
          text: "$title.",
          textStyle: interMedium,
          color: greenColor,
        ),
        SizedBox(height: 10),
        Row(
          children: [
            RText(
              text: "Rp.",
              textStyle: interMedium,
            ),
            SizedBox(width: 10),
            Expanded(
              child: RTextField(
                hintText: title,
                controller: controller,
                inputType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
