import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../routes/app_pages.dart';
import '../controllers/admin_user_presence_history_controller.dart';

class AdminUserPresenceHistoryView
    extends GetView<AdminUserPresenceHistoryController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AdminUserPresenceHistoryView'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => Get.dialog(
                          RCalendarDialog(
                            controller: controller,
                            onSubmit: (dateObject) async {
                              if (dateObject != null) {
                                if ((dateObject as PickerDateRange).endDate !=
                                    null) {
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
                        child: Icon(Icons.date_range_outlined),
                      ),
                      ElevatedButton(
                        onPressed: () => Get.dialog(
                          RCalendarDialog(
                            controller: controller,
                            onSubmit: (dateObject) async {
                              if (dateObject != null) {
                                if ((dateObject as PickerDateRange).endDate !=
                                    null) {
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
                  SizedBox(height: 10),
                  DropdownSearch<String>(
                    popupProps: PopupProps.menu(
                      showSelectedItems: true,
                      fit: FlexFit.loose,
                    ),
                    items: ["Normal Presence", "Overtime"],
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Filter",
                      ),
                    ),
                    onChanged: (value) async {
                      controller.filterOption = value!;

                      controller.update();
                    },
                    selectedItem: "Normal Presence",
                  ),
                  SizedBox(height: 10),
                  DropdownSearch<String>(
                    popupProps: PopupProps.menu(
                      showSelectedItems: true,
                      fit: FlexFit.loose,
                    ),
                    items: ["Ascending", "Descending"],
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Filter",
                      ),
                    ),
                    onChanged: (value) async {
                      if (value == "Descending") {
                        controller.filterType = false;
                      } else {
                        controller.filterType = true;
                      }

                      controller.update();
                    },
                    selectedItem: "Ascending",
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: ListView(
              children: [
                GetBuilder<AdminUserPresenceHistoryController>(
                  builder: (c) =>
                      FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    future: controller.getUserPresenceHistory(
                      'Normal Presence',
                      true,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: Text("Memuat data .."));
                      }
                      if (snapshot.data?.docs.length == 0) {
                        return Center(
                            child: Text("Data absensi tidak ditemukan."));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> userData =
                              snapshot.data!.docs[index].data();

                          return ListTile(
                            trailing: Icon(Icons.arrow_forward),
                            title: Text(
                              controller.dateFormat(
                                userData['date'],
                              ),
                            ),
                            onTap: () => Get.toNamed(
                              Routes.PRESENCE_DETAILS,
                              arguments: userData,
                            ),
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
        height: Get.height * .4,
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
