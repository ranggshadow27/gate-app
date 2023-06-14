import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/appbar.dart';
import 'package:gate/app/components/widgets/button.dart';
import 'package:gate/app/components/widgets/text_widget.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uicons/uicons.dart';

import '../../../routes/app_pages.dart';
import '../controllers/report_detail_controller.dart';

class ReportDetailView extends GetView<ReportDetailController> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> reportData = Get.arguments;

    DateFormat dateFormat = DateFormat("EEEE, dd MMMM yyyy");
    DateFormat hourFormat = DateFormat("kk:mm");

    String formattedDate = dateFormat.format(DateTime.parse("${reportData['createdAt']}"));
    String formattedHour = hourFormat.format(DateTime.parse("${reportData['createdAt']}"));

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            RAppBar(onPressed: () => Get.back(), title: "Report Details"),
            Divider(),
            IntrinsicHeight(
              child: Container(
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: Get.width * .6,
                          child: RText(
                            text: "${reportData['subject']}",
                            textStyle: interSemiBold,
                            textAlign: TextAlign.start,
                            maxLine: 2,
                            isOverflow: true,
                          ),
                        ),
                        Spacer(),
                        Container(
                          width: 40,
                          height: 40,
                          child: IconButton(
                            onPressed: () {
                              print(controller.reportID);
                              Get.defaultDialog(
                                backgroundColor: borderColor,
                                title: "Confirm",
                                middleText: "Hapus data report ${reportData['reportID']}?",
                                actions: [
                                  OutlinedButton(
                                    onPressed: () => Get.back(),
                                    child: Text("Back"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      controller.deleteReport();
                                    },
                                    child: Text("Delete"),
                                  ),
                                ],
                              );
                            },
                            icon: Icon(
                              UIcons.regularRounded.cross_small,
                              color: redColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(color: borderColor),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        RText(
                          text: "$formattedDate - ",
                          textStyle: interRegular,
                          fontSize: 12,
                          textAlign: TextAlign.start,
                        ),
                        RText(
                          text: "$formattedHour WIB",
                          textStyle: interBold,
                          fontSize: 12,
                          textAlign: TextAlign.start,
                          color: greenColor,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        RText(
                          text: "Incident ID : ",
                          textStyle: interRegular,
                          textAlign: TextAlign.start,
                          fontSize: 12,
                        ),
                        RText(
                          text: "${reportData['reportID']}",
                          textAlign: TextAlign.start,
                          textStyle: interBold,
                          fontSize: 12,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        RText(
                          text: "Created by : ",
                          textStyle: interRegular,
                          textAlign: TextAlign.start,
                          fontSize: 12,
                        ),
                        RText(
                          text: "${reportData['createdBy']}",
                          textAlign: TextAlign.start,
                          textStyle: interBold,
                          fontSize: 12,
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: RText(
                        text: "Description.",
                        textStyle: interBold,
                        textAlign: TextAlign.start,
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(height: 5),
                    RText(
                      text: "${reportData['description']}",
                      textAlign: TextAlign.justify,
                      textStyle: interRegular,
                      fontSize: 12.0,
                    ),
                    SizedBox(height: 20),
                    RButton(
                      width: Get.width,
                      color: greenColor,
                      text: "Update",
                      callback: () => Get.offNamed(
                        Routes.REPORT_UPDATE,
                        arguments: reportData,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        RText(
                          text: "Category : ",
                          textStyle: interRegular,
                          textAlign: TextAlign.start,
                          fontSize: 10,
                        ),
                        RText(
                          text: "${reportData['category']}",
                          textAlign: TextAlign.start,
                          textStyle: interBold,
                          fontSize: 10,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        RText(
                          text: "Type : ",
                          textStyle: interRegular,
                          textAlign: TextAlign.start,
                          fontSize: 10,
                        ),
                        RText(
                          text: "${reportData['type']}",
                          textAlign: TextAlign.start,
                          textStyle: interBold,
                          fontSize: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                children: [
                  RText(text: "Attachment.", textStyle: interBold),
                  SizedBox(height: 20),
                  reportData['images'] != null
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: reportData['images'].length,
                          itemBuilder: (context, index) {
                            final String imageName = reportData['images'][index]['name'];
                            final String imageUrl = reportData['images'][index]['url'];

                            return Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: Get.width,
                                    height: 150,
                                    child: Image.network(
                                      reportData['images'][index]['url'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: Get.width * .7,
                                      child: Obx(
                                        () => InkWell(
                                          onTap: () {
                                            if (controller.isLoading.isFalse) {
                                              Get.dialog(
                                                Dialog(
                                                  elevation: 0,
                                                  backgroundColor: Colors.transparent,
                                                  child: Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        CircularProgressIndicator(),
                                                        SizedBox(height: 10),
                                                        Text(
                                                          "Downloading $imageName ..",
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                              controller.downloadImage(imageUrl, imageName);
                                            } else {
                                              SizedBox();
                                            }
                                          },
                                          child: RText(
                                            text: "${reportData['images'][index]['name']}",
                                            isOverflow: controller.isLoading.isTrue ? true : true,
                                            textAlign: TextAlign.center,
                                            textStyle: interRegular,
                                            fontSize: 12.0,
                                            isUnderlined: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),
                              ],
                            );
                          },
                        )
                      : RText(
                          text: "No Attachment",
                          textStyle: interRegular,
                          fontSize: 12.0,
                        ),
                ],
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
