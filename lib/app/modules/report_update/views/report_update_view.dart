import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/widgets/appbar.dart';
import 'package:gate/app/components/widgets/textfield.dart';
import 'package:gate/app/modules/report_add/controllers/report_add_controller.dart';

import 'package:get/get.dart';
import 'package:uicons/uicons.dart';

import '../../../components/colors.dart';
import '../../../components/fonts.dart';
import '../../../components/widgets/button.dart';
import '../../../components/widgets/custom_icon.dart';
import '../../../components/widgets/text_widget.dart';
import '../controllers/report_update_controller.dart';

class ReportUpdateView extends GetView<ReportUpdateController> {
  final controllerAddReport = Get.put(ReportAddController());

  final Map<String, dynamic> reportData = Get.arguments;

  @override
  Widget build(BuildContext context) {
    controller.subjectC.text = reportData['subject'];
    controller.descriptionC.text = reportData['description'];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                RAppBar(onPressed: () => Get.back(), title: "Update Report"),
                SizedBox(height: 20),
                RTextField(hintText: 'Input subject', controller: controller.subjectC),
                SizedBox(height: 10),
                RDropdownMenu(
                  controller: controller,
                  dataType: 'category',
                  title: "Category",
                  isEnabled: true,
                  selectedItem: reportData['category'],
                ),
                SizedBox(height: 10),
                RDropdownMenu(
                  controller: controller,
                  dataType: 'type',
                  title: "Type",
                  isEnabled: true,
                  selectedItem: reportData['type'],
                ),
                SizedBox(height: 10),
                RTextField(
                  hintText: 'Input report description',
                  controller: controller.descriptionC,
                  maxLines: null,
                  inputType: TextInputType.multiline,
                ),
                SizedBox(height: 20),
                StreamBuilder(
                  stream: controller.streamReportData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Text("Memuat gambar"),
                      );
                    }
                    Map<String, dynamic> reportStream = snapshot.data!.data()!;

                    if (reportStream['images'] == null || reportStream['images'].length == 0) {
                      return SizedBox();
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: reportStream['images'].length,
                      itemBuilder: (context, index) {
                        String imageUrl = reportStream['images'][index]['url'];
                        String imageName = reportStream['images'][index]['name'];

                        return Stack(
                          children: [
                            Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: SizedBox(
                                    width: Get.width,
                                    height: controller.isUpdate.isFalse ? 200 : 200,
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        controller.deleteImage(imageName, imageUrl);
                                      },
                                      child: RText(
                                        text: "Delete",
                                        textStyle: interSemiBold,
                                        color: redColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 20),
                GetBuilder<ReportAddController>(
                  builder: (c) => ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount:
                        controllerAddReport.imgs.isNotEmpty ? controllerAddReport.imgs.length : 0,
                    itemBuilder: (context, index) {
                      if (controllerAddReport.imgs.isEmpty) {
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
                                          File(controllerAddReport.imgs[index].path),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    RText(
                                      text: controllerAddReport.imgs[index].name,
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
                                      if (controllerAddReport.imgs.isNotEmpty) {
                                        controllerAddReport.imgs.removeAt(index);
                                        controllerAddReport.update();
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
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.all(16),
                    fixedSize: Size(Get.width, 50),
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    controllerAddReport.getImage();
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
                Obx(
                  () => RButton(
                    color: greenColor,
                    text: controller.isLoading.isFalse ? "Update Report" : "Loading ..",
                    callback: () async {
                      await controller.updateReport();
                    },
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
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
    this.selectedItem,
  }) : super(key: key);

  final ReportUpdateController controller;
  final String dataType;
  final String title;
  final bool isEnabled;
  String? selectedItem;

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
            selectedItem: selectedItem ?? null,
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
