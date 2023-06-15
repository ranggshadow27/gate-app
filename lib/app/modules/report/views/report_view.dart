import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/bottom_navigation.dart';
import 'package:gate/app/components/widgets/text_widget.dart';
import 'package:gate/app/controllers/page_setup_controller.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:uicons/uicons.dart';

import '../../../components/widgets/custom_icon.dart';
import '../../../routes/app_pages.dart';
import '../controllers/report_controller.dart';

class ReportView extends GetView<ReportController> {
  final pageController = Get.find<PageSetupController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: FutureBuilder(
                      future: controller.getCategory(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text("Memuat data");
                        }

                        Map<String, dynamic> categoryData = snapshot.data!.data()!;

                        List listData = ["Show All"];
                        listData.addAll(categoryData['category']);

                        print(listData);

                        return RDropdownSearch(listData: listData, controller: controller);
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Obx(
                    () => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: greenColor,
                        fixedSize: Size(Get.width * .15, Get.width * .15),
                      ),
                      onPressed: () {
                        controller.isDescending.toggle();
                        controller.update();
                        print(controller.isDescending);
                      },
                      child: RIcon(
                        size: 24,
                        icon: controller.isDescending.isTrue
                            ? UIcons.regularRounded.arrow_small_down
                            : UIcons.regularRounded.arrow_small_up,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenColor,
                      fixedSize: Size(Get.width * .15, Get.width * .15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      showCalendar();
                    },
                    child: RIcon(icon: UIcons.regularRounded.calendar),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 8,
              child: GetBuilder<ReportController>(builder: (c) {
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: controller.getReportDatas(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: RText(
                          text: "No Report Found.",
                          textStyle: interSemiBold,
                          color: redColor,
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> reportData = snapshot.data!.docs[index].data();

                        String formattedDate = DateFormat("EEEE, dd MMMM yyyy")
                            .format(DateTime.parse("${reportData['createdAt']}"));

                        String formattedHour = DateFormat("kk:mm")
                            .format(DateTime.parse("${reportData['createdAt']}"));

                        print("Ini data Formatnya ----------> $formattedDate");

                        return ReportListTile(
                          reportData: reportData,
                          formattedDate: formattedDate,
                          formattedHour: formattedHour,
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.REPORT_ADD),
        backgroundColor: greenColor,
        child: Icon(
          UIcons.solidRounded.plus,
          size: 16,
        ),
      ),
      bottomNavigationBar: RBottomNavigation(),
    );
  }

  void showCalendar() {
    Get.dialog(
      Dialog(
        child: Container(
          height: 400,
          padding: EdgeInsets.all(20),
          child: SfDateRangePicker(
            showActionButtons: true,
            selectionMode: DateRangePickerSelectionMode.range,
            monthViewSettings: DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
            onCancel: () => Get.back(),
            onSubmit: (p0) {
              if (p0 != null) {
                if ((p0 as PickerDateRange).endDate != null) {
                  controller.pickerDate(p0.startDate!, p0.endDate!);
                  Get.back();
                } else {
                  Get.snackbar("Error", "Mohon untuk mengisi tanggal akhir");
                }
              } else {
                Get.snackbar("Error", "Mohon untuk mengisi tanggal awal dan akhir");
              }
            },
          ),
        ),
      ),
    );
  }
}

class RDropdownSearch extends StatelessWidget {
  const RDropdownSearch({
    super.key,
    required this.listData,
    required this.controller,
  });

  final List listData;
  final ReportController controller;

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
        selectedItem: listData[0],
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
          controller.filterByCategory.value = value;
          controller.update();
        },
        items: listData,
      ),
    );
  }
}

class ReportListTile extends StatelessWidget {
  const ReportListTile({
    super.key,
    required this.reportData,
    required this.formattedDate,
    required this.formattedHour,
  });

  final Map<String, dynamic> reportData;
  final String formattedDate;
  final String formattedHour;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Material(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(19),
          side: BorderSide(
            style: BorderStyle.solid,
            color: borderColor,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(19),
          onTap: () => Get.toNamed(Routes.REPORT_DETAIL, arguments: reportData),
          child: IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RText(
                    text: "${reportData['subject']}",
                    textStyle: interSemiBold,
                    fontSize: 12.0,
                    maxLine: 2,
                    textAlign: TextAlign.start,
                    isOverflow: true,
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      RText(
                        text: "${formattedDate}",
                        textStyle: interRegular,
                        color: whiteColor.withAlpha(180),
                        fontSize: 10,
                        maxLine: 1,
                      ),
                      RText(
                        text: " - ${formattedHour} WIB",
                        textStyle: interBold,
                        color: greenColor,
                        fontSize: 10,
                        maxLine: 1,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      RText(
                        text: "Created By : ",
                        textStyle: interRegular,
                        color: whiteColor.withAlpha(180),
                        fontSize: 10,
                        maxLine: 1,
                      ),
                      RText(
                        text: "${reportData['createdBy']}",
                        color: whiteColor.withAlpha(180),
                        textStyle: interBold,
                        fontSize: 10,
                        maxLine: 1,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  FittedBox(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: borderColor,
                          ),
                          child: Center(
                            child: RText(
                              text: "${reportData['category']}",
                              textStyle: interSemiBold,
                              fontSize: 10.0,
                              isOverflow: true,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        IntrinsicHeight(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: borderColor,
                            ),
                            child: Center(
                              child: RText(
                                text: "${reportData['type']}",
                                textStyle: interSemiBold,
                                fontSize: 10.0,
                                isOverflow: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
