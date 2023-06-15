import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/widgets/appbar.dart';
import 'package:gate/app/components/widgets/button.dart';
import 'package:gate/app/components/widgets/textfield.dart';

import 'package:get/get.dart';
import 'package:uicons/uicons.dart';

import '../../../components/fonts.dart';
import '../../../components/widgets/custom_icon.dart';
import '../../../components/widgets/text_widget.dart';
import '../controllers/dispensation_add_controller.dart';

class DispensationAddView extends GetView<DispensationAddController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            RAppBar(onPressed: () => Get.back(), title: "Add Dispensation"),
            SizedBox(height: 20),
            RDropdownSearch(controller: controller),
            SizedBox(height: 20),
            RTextField(
              hintText: 'Subject',
              controller: controller.subjectC,
              maxLines: 1,
            ),
            SizedBox(height: 20),
            RTextField(
              hintText: 'Description',
              controller: controller.descC,
            ),
            SizedBox(height: 20),
            GetBuilder<DispensationAddController>(
              builder: (controller) {
                if (controller.image != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(
                      File(controller.image!.path),
                      fit: BoxFit.cover,
                    ),
                  );
                }

                return SizedBox();
              },
            ),
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => controller.getImage(),
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              child: RText(
                text: "Pick a file",
                textStyle: interSemiBold,
              ),
            ),
            SizedBox(height: 20),
            Obx(
              () => RButton(
                color: greenColor,
                text: controller.isLoading.isFalse ? "Submit Dispensation." : "Loading..",
                callback: () {
                  controller.submitDispensation();
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class RDropdownSearch extends StatelessWidget {
  const RDropdownSearch({
    super.key,
    required this.controller,
  });

  final DispensationAddController controller;

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
        items: ["Sakit", "Izin"],
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
            labelText: "Please select dispensation type",
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
          controller.dispensationType = value;
          print(controller.dispensationType);
        },
      ),
    );
  }
}
