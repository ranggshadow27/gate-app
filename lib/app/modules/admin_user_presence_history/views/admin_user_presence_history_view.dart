import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/widgets/text_widget.dart';
import 'package:gate/app/modules/presence_history/views/presence_history_view.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:uicons/uicons.dart';

import '../../../components/fonts.dart';
import '../../../components/widgets/custom_icon.dart';
import '../../../routes/app_pages.dart';
import '../controllers/admin_user_presence_history_controller.dart';

class AdminUserPresenceHistoryView extends GetView<AdminUserPresenceHistoryController> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> getUserUID = Get.arguments;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: Get.width,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  RText(text: "${getUserUID['fullname']} Presence History", textStyle: interMedium),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: RDropdownButton(
                          controller: controller,
                          items: ["Presence", "Overtime"],
                          onChanged: (value) async {
                            controller.filterOption = value!;

                            controller.update();
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
                            controller.filterType.toggle();
                            controller.update();
                          },
                          child: RIcon(
                            size: 24,
                            icon: controller.filterType.isTrue
                                ? UIcons.regularRounded.arrow_small_down
                                : UIcons.regularRounded.arrow_small_up,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: greenColor,
                          fixedSize: Size(Get.width * .15, Get.width * .15),
                        ),
                        onPressed: () => Get.dialog(
                          RCalendarDialog(
                            controller: controller,
                            onSubmit: (dateObject) async {
                              if (dateObject != null) {
                                if ((dateObject as PickerDateRange).endDate != null) {
                                  await controller.getDate(
                                    getStartDate: dateObject.startDate,
                                    getEndDate: dateObject.endDate!,
                                  );

                                  Get.back();
                                }
                              }
                            },
                          ),
                        ),
                        child: Icon(Icons.date_range_outlined),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 7,
              child: ListView(
                children: [
                  GetBuilder<AdminUserPresenceHistoryController>(
                    builder: (c) => FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      future: controller.getUserPresenceHistory(
                        'Normal Presence',
                        true,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.data?.docs.length == 0) {
                          return Center(
                            child: RText(
                              text: "No Presence History Found.",
                              textStyle: interMedium,
                              color: redColor,
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> userData = snapshot.data!.docs[index].data();
                            String dateFormat = DateFormat("EEEE, dd MMMM yyyy")
                                .format(DateTime.parse(userData["date"]));

                            String presenceIn = DateFormat("hh:mm a")
                                .format(DateTime.parse(userData["masuk"]["datetime"]));

                            return PresenceHistoryTile(
                              userHistoryData: userData,
                              dateFormat: dateFormat,
                              presenceIn: presenceIn,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: greenColor,
        child: RIcon(icon: UIcons.regularRounded.print),
        onPressed: () => Get.dialog(
          RCalendarDialog(
            controller: controller,
            onSubmit: (dateObject) async {
              if (dateObject != null) {
                if ((dateObject as PickerDateRange).endDate != null) {
                  await controller.getDate(
                    getStartDate: dateObject.startDate,
                    getEndDate: dateObject.endDate!,
                  );

                  Get.back();

                  controller.createPDF();
                }
              }
            },
          ),
        ),
      ),
    );
  }
}

class RDropdownButton extends StatelessWidget {
  const RDropdownButton({
    super.key,
    required this.controller,
    required this.items,
    required this.onChanged,
  });

  final AdminUserPresenceHistoryController controller;
  final List<String> items;
  final Function(String?) onChanged;

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
      child: DropdownSearch<String>(
        items: items,
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
        onChanged: onChanged,
        selectedItem: items[0],
      ),
    );
  }
}

class RCalendarDialog extends StatelessWidget {
  const RCalendarDialog({
    Key? key,
    required this.controller,
    required this.onSubmit,
  }) : super(key: key);

  final AdminUserPresenceHistoryController controller;

  final Function(Object?)? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(20),
        height: 400,
        child: SfDateRangePicker(
          selectionMode: DateRangePickerSelectionMode.range,
          showActionButtons: true,
          monthViewSettings: DateRangePickerMonthViewSettings(
            firstDayOfWeek: 1,
          ),
          onCancel: () => Get.back(),
          onSubmit: onSubmit,
        ),
      ),
    );
  }
}
