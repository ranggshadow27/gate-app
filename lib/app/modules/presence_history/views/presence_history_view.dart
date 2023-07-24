import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:uicons/uicons.dart';

import '../../../components/colors.dart';
import '../../../components/fonts.dart';
import '../../../components/widgets/bottom_navigation.dart';
import '../../../components/widgets/custom_icon.dart';
import '../../../components/widgets/loading_widget.dart';
import '../../../components/widgets/text_widget.dart';
import '../../../routes/app_pages.dart';
import '../controllers/presence_history_controller.dart';

class PresenceHistoryDetailsView extends GetView<PresenceHistoryController> {
  final dataController = Get.put(DataController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: Get.width,
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RDropdownSearch(
                      controller: controller,
                      items: ["Presence", "Overtime"],
                      onChanged: (value) {
                        print(value);
                        controller.filterOption = value;

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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: greenColor,
                      fixedSize: Size(Get.width * .15, Get.width * .15),
                    ),
                    onPressed: () {
                      Get.dialog(
                        Dialog(
                          child: DatePickerDialog(controller: controller),
                        ),
                      );
                    },
                    child: RIcon(icon: UIcons.regularRounded.calendar),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 7,
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  GetBuilder<PresenceHistoryController>(
                    builder: (c) => FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      future: controller.getUserPresenceHistory(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            height: Get.height * .7,
                            child: Center(child: RLoading()),
                          );
                        }
                        print("Snapshot -> ${snapshot.data?.docs}");

                        if (snapshot.data == null || snapshot.data?.docs.length == 0) {
                          return Center(
                            child: RText(
                              text: "No Presence History Found.",
                              textStyle: interMedium,
                              color: redColor,
                            ),
                          );
                        }

                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> userHistoryData =
                                snapshot.data!.docs[index].data();

                            String dateFormat = DateFormat("EEEE, dd MMMM yyyy")
                                .format(DateTime.parse(userHistoryData["date"]));

                            String presenceIn = DateFormat("hh:mm a")
                                .format(DateTime.parse(userHistoryData["masuk"]["datetime"]));

                            return PresenceHistoryTile(
                              userHistoryData: userHistoryData,
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
        onPressed: () {
          buildPrintDialog();
        },
        backgroundColor: greenColor,
        child: RIcon(icon: UIcons.regularRounded.print),
      ),
      bottomNavigationBar: RBottomNavigation(),
    );
  }

  void buildPrintDialog() {
    Get.dialog(
      Dialog(
        child: Container(
          padding: EdgeInsets.all(20),
          height: 400,
          child: SfDateRangePicker(
            monthViewSettings: DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
            selectionMode: DateRangePickerSelectionMode.range,
            showActionButtons: true,
            onCancel: () => Get.back(),
            onSubmit: (dateObject) async {
              if (dateObject != null) {
                if ((dateObject as PickerDateRange).endDate != null) {
                  controller.pickDate(dateObject.startDate!, dateObject.endDate!);
                  await dataController.fetchData();
                  controller.createPDF(
                    dataPresence: dataController.dataPresence,
                    dataUser: dataController.dataUser,
                    dataOvertime: dataController.dataOvertime,
                  );
                }
              }
              // Get.back();
            },
          ),
        ),
      ),
    );
  }
}

class PresenceHistoryTile extends StatelessWidget {
  const PresenceHistoryTile({
    super.key,
    required this.userHistoryData,
    required this.dateFormat,
    required this.presenceIn,
  });

  final Map<String, dynamic> userHistoryData;
  final String dateFormat;
  final String presenceIn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: borderColor,
          ),
        ),
        color: bgColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Get.toNamed(
            Routes.PRESENCE_DETAILS,
            arguments: userHistoryData,
          ),
          child: Container(
            width: Get.width,
            padding: EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RText(
                      text: "${dateFormat}",
                      textStyle: interSemiBold,
                      fontSize: 12.0,
                    ),
                    SizedBox(height: 2),
                    RText(
                      text: userHistoryData['masuk']['device'].toString().toUpperCase(),
                      textStyle: interRegular,
                      color: whiteColor.withOpacity(.6),
                      fontSize: 10.0,
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: borderColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              RIcon(
                                icon: UIcons.regularRounded.arrow_small_up,
                                color: greenColor,
                              ),
                              RText(
                                text: presenceIn,
                                textStyle: interSemiBold,
                                fontSize: 10.0,
                              ),
                              SizedBox(width: 4),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        if (userHistoryData['pulang'] != null)
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: borderColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                RIcon(
                                  icon: UIcons.regularRounded.arrow_small_down,
                                  color: redColor,
                                ),
                                RText(
                                  text:
                                      "${DateFormat("hh:mm a").format(DateTime.parse(userHistoryData["pulang"]["datetime"]))}",
                                  textStyle: interSemiBold,
                                  fontSize: 10.0,
                                ),
                                SizedBox(width: 4),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                RIcon(
                  icon: UIcons.solidRounded.angle_right,
                  size: 12,
                ),
                SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RDropdownSearch extends StatelessWidget {
  const RDropdownSearch({
    super.key,
    required this.controller,
    required this.items,
    required this.onChanged,
  });

  final PresenceHistoryController controller;
  final List<String> items;
  final Function(dynamic) onChanged;

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
        onChanged: onChanged,
      ),
    );
  }
}

class DatePickerDialog extends StatelessWidget {
  const DatePickerDialog({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final PresenceHistoryController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      height: 400,
      child: SfDateRangePicker(
        monthViewSettings: DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
        selectionMode: DateRangePickerSelectionMode.range,
        showActionButtons: true,
        onCancel: () => Get.back(),
        onSubmit: (dateObject) {
          if (dateObject != null) {
            if ((dateObject as PickerDateRange).endDate != null) {
              controller.pickDate(dateObject.startDate!, dateObject.endDate!);
            }
          }
          Get.back();
        },
      ),
    );
  }
}
