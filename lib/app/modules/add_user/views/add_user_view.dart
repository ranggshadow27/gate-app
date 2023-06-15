import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/appbar.dart';
import 'package:gate/app/components/widgets/button.dart';
import 'package:gate/app/components/widgets/text_widget.dart';
import 'package:gate/app/components/widgets/textfield.dart';

import 'package:get/get.dart';
import 'package:uicons/uicons.dart';

import '../../../components/widgets/custom_icon.dart';
import '../controllers/add_user_controller.dart';

class AddUserView extends GetView<AddUserController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            RAppBar(onPressed: () => Get.back(), title: "Add User"),
            SizedBox(height: 20),
            RAddUserTile(
              title: "Email",
              controller: controller.emailC,
              isSalary: false,
              inputType: TextInputType.emailAddress,
            ),
            RAddUserTile(
              title: "NIP",
              controller: controller.nipC,
              isSalary: false,
              inputType: TextInputType.number,
            ),
            RAddUserTile(
              title: "Full Name",
              controller: controller.fullnameC,
              isSalary: false,
            ),
            RText(
              text: "Grade.",
              textStyle: interSemiBold,
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            RDropdownSearch(controller: controller),
            Divider(color: whiteColor),
            SizedBox(height: 20),
            RAddUserTile(
              title: 'Main Salary',
              controller: controller.mainSalaryC,
              isSalary: true,
            ),
            RAddUserTile(
              title: 'Daily Salary',
              controller: controller.dailySalaryC,
              isSalary: true,
            ),
            RAddUserTile(
              title: "Allowance",
              controller: controller.allowanceSalaryC,
              isSalary: true,
            ),
            RAddUserTile(
              title: "BPJS",
              controller: controller.bpjsC,
              isSalary: true,
            ),
            RAddUserTile(
              title: "BPJS Ketenagakerjaan",
              controller: controller.bpjskC,
              isSalary: true,
            ),
            RButton(
              color: greenColor,
              text: controller.isLoading.isFalse ? "Register User." : "Loading..",
              callback: () {
                if (controller.isLoading.isFalse) {
                  controller.addUser();
                }
              },
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class RDropdownSearch extends StatelessWidget {
  RDropdownSearch({
    super.key,
    required this.controller,
  });

  final AddUserController controller;

  final List<String> items = [
    "Gateway Operator",
    "GO Supervisor",
    "Office Boy",
    "Staff Umum",
    "VSAT Engineer"
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: TextTheme(
          titleMedium: interRegular.copyWith(
            color: whiteColor,
            fontSize: 14.0,
          ),
        ),
      ),
      child: DropdownSearch(
        items: items,
        selectedItem: items[0],
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.never,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: bgColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: whiteColor),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            labelText: "Select Category",
            labelStyle: interRegular.copyWith(
              fontSize: 14.0,
              color: whiteColor.withAlpha(150),
            ),
          ),
        ),
        popupProps: PopupProps.menu(
          fit: FlexFit.loose,
          menuProps: MenuProps(
            backgroundColor: borderColor,
          ),
        ),
        dropdownButtonProps: DropdownButtonProps(
          icon: RIcon(icon: UIcons.boldRounded.caret_down),
        ),
        onChanged: (value) {
          controller.gradeC = value;
          print("${controller.gradeC}");
        },
      ),
    );
  }
}

class RAddUserTile extends StatelessWidget {
  RAddUserTile({
    super.key,
    required this.controller,
    required this.title,
    this.isSalary,
    this.inputType,
  });

  final TextEditingController controller;
  final TextInputType? inputType;
  final String title;
  bool? isSalary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RText(text: "$title.", textStyle: interSemiBold),
        SizedBox(height: 10),
        if (isSalary == false)
          RTextField(
            hintText: title,
            controller: controller,
            inputType: inputType,
          ),
        if (isSalary == true)
          Row(
            children: [
              RText(
                text: "Rp.",
                textStyle: interMedium,
                color: greenColor,
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
        SizedBox(height: 20),
      ],
    );
  }
}
