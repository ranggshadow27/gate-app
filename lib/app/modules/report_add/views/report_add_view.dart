import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/appbar.dart';
import 'package:gate/app/components/widgets/button.dart';
import 'package:gate/app/components/widgets/custom_icon.dart';
import 'package:gate/app/components/widgets/text_widget.dart';
import 'package:gate/app/components/widgets/textfield.dart';

import 'package:get/get.dart';
import 'package:uicons/uicons.dart';

import '../controllers/report_add_controller.dart';

class ReportAddView extends GetView<ReportAddController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            RAppBar(onPressed: () => Get.back(), title: "New Report"),
            SizedBox(height: 20),
            RText(
              text: "Subject.",
              textStyle: interSemiBold,
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            RTextField(
              hintText: "Input Subject",
              controller: controller.subjectC,
              textStyle: interRegular.copyWith(color: whiteColor, fontSize: 14),
            ),
            SizedBox(height: 20),
            RText(
              text: "Type.",
              textStyle: interSemiBold,
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            RDropdownMenu(
              isEnabled: true,
              controller: controller,
              dataType: 'type',
              title: 'Type',
            ),
            SizedBox(height: 20),
            RText(
              text: "Category.",
              textStyle: interSemiBold,
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            RDropdownMenu(
              isEnabled: true,
              controller: controller,
              dataType: "category",
              title: "Category",
            ),
            SizedBox(height: 20),
            Divider(color: borderColor),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    fixedSize: Size(Get.width * .42, 60),
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Get.dialog(
                      buildAddCategoryDialog(),
                    );
                  },
                  child: RText(
                    text: "Add Category",
                    textStyle: interRegular,
                    color: greenColor,
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    fixedSize: Size(Get.width * .42, 60),
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Get.dialog(
                      buildDeleteCategoryDialog(),
                    );
                  },
                  child: RText(
                    text: "Delete Category",
                    textStyle: interRegular,
                    color: redColor,
                  ),
                ),
              ],
            ),
            Divider(color: borderColor),
            SizedBox(height: 20),
            RText(
              text: "Description.",
              textStyle: interSemiBold,
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            RTextField(
              hintText: "Description",
              controller: controller.descriptionC,
              inputType: TextInputType.multiline,
              textStyle: interRegular.copyWith(color: whiteColor, fontSize: 14),
              maxLines: null,
            ),
            SizedBox(height: 20),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.all(16),
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                controller.getImage();
              },
              child: RText(
                text: "Upload Images",
                textStyle: interSemiBold,
                color: greenColor,
                fontSize: 12.0,
                isUnderlined: true,
              ),
            ),
            SizedBox(height: 20),
            GetBuilder<ReportAddController>(
              builder: (c) => ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.imgs.isNotEmpty ? controller.imgs.length : 0,
                itemBuilder: (context, index) {
                  if (controller.imgs.isEmpty) {
                    return SizedBox();
                  } else {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: borderColor),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: SizedBox(
                                    width: Get.width,
                                    height: 180,
                                    child: Image.file(
                                      File(controller.imgs[index].path),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 6),
                                RText(
                                  text: controller.imgs[index].name,
                                  textStyle: interRegular,
                                ),
                                SizedBox(height: 6),
                              ],
                            ),
                            Positioned(
                              right: 0,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(60, 60),
                                  backgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(200),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  if (controller.imgs.isNotEmpty) {
                                    controller.imgs.removeAt(index);
                                    controller.update();
                                  }
                                },
                                child: Icon(
                                  UIcons.solidRounded.cross_small,
                                  color: redColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            Obx(
              () => RButton(
                color: greenColor,
                text: controller.isLoading.isFalse ? "Submit" : "Loading ..",
                callback: () {
                  controller.submitReport();
                },
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildAddCategoryDialog() {
    return Dialog(
      backgroundColor: borderColor.withOpacity(.8),
      child: IntrinsicHeight(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RText(
                text: "New Category/Type.",
                textStyle: interSemiBold,
                textAlign: TextAlign.start,
                fontSize: 12.0,
              ),
              SizedBox(height: 10),
              RTextField(
                hintText: "Type New Category/Type",
                controller: controller.newTypeC,
                textStyle: interRegular.copyWith(color: whiteColor, fontSize: 14),
              ),
              SizedBox(height: 10),
              Theme(
                data: ThemeData(
                  textTheme: TextTheme(
                    titleMedium: interRegular.copyWith(
                      color: whiteColor,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                child: DropdownSearch(
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: whiteColor),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      labelText: "Select Type/Category",
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
                  items: [
                    "Type",
                    "Category",
                  ],
                  onChanged: (value) {
                    controller.reportCategory = value;
                    print(controller.reportCategory);
                  },
                ),
              ),
              SizedBox(height: 20),
              Obx(
                () => RButton(
                  color: greenColor,
                  width: Get.width,
                  height: 50,
                  text: controller.isLoading.isFalse ? "Submit" : "Loading ..",
                  callback: () {
                    controller.submitNewCategory();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDeleteCategoryDialog() {
    return Dialog(
      backgroundColor: borderColor.withOpacity(.8),
      child: IntrinsicHeight(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              RText(
                text: "Delete Category/Type.",
                textStyle: interSemiBold,
                textAlign: TextAlign.start,
                fontSize: 12.0,
              ),
              SizedBox(height: 20),
              Theme(
                data: ThemeData(
                  textTheme: TextTheme(
                    titleMedium: interRegular.copyWith(
                      color: whiteColor,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                child: DropdownSearch(
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: whiteColor),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      labelText: "Select Type/Category",
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
                  items: [
                    "Type",
                    "Category",
                  ],
                  onChanged: (value) {
                    if (value == "Category") {
                      controller.selectedReport.value = "category";
                    } else {
                      controller.selectedReport.value = "type";
                    }
                  },
                ),
              ),
              SizedBox(height: 10),
              Obx(
                () => RDropdownMenu(
                  controller: controller,
                  dataType: controller.selectedReport.value == "category" ? "category" : "type",
                  title: controller.selectedReport.value == "category"
                      ? "Please select Category"
                      : "Please select Type",
                  isEnabled: controller.selectedReport.value.isNotEmpty ? true : false,
                ),
              ),
              SizedBox(height: 20),
              Obx(
                () => RButton(
                  callback: () {
                    controller.updateCategory(controller.selectedReport.value);
                  },
                  text: controller.isLoading.isFalse ? "Delete" : "Loading ..",
                  color: redColor,
                  width: Get.width,
                  height: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RDropdownMenu extends StatelessWidget {
  RDropdownMenu({
    Key? key,
    required this.controller,
    required this.dataType,
    required this.title,
    required this.isEnabled,
  }) : super(key: key);

  final ReportAddController controller;
  final String dataType;
  final String title;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: controller.streamReportCategory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Memuat data ..");
        }

        List<dynamic>? getReport = snapshot.data!.data()![dataType];
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
                labelText: title,
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
            enabled: isEnabled,
            items: getReport == null ? ["No Data Found"] : getReport,
            onChanged: (value) {
              controller.getCategory(value, dataType);
              // print(onChanged);
            },
          ),
        );
      },
    );
  }
}
