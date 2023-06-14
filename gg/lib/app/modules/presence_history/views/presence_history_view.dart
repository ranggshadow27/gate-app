import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../routes/app_pages.dart';
import '../controllers/presence_history_controller.dart';

class PresenceHistoryDetailsView extends GetView<PresenceHistoryController> {
  final dataController = Get.put(DataController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PresenceHistoryDetailsView'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.dialog(Dialog(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        height: 400,
                        child: SfDateRangePicker(
                          monthViewSettings: DateRangePickerMonthViewSettings(
                              firstDayOfWeek: 1),
                          selectionMode: DateRangePickerSelectionMode.range,
                          showActionButtons: true,
                          onCancel: () => Get.back(),
                          onSubmit: (dateObject) async {
                            if (dateObject != null) {
                              if ((dateObject as PickerDateRange).endDate !=
                                  null) {
                                controller.pickDate(
                                    dateObject.startDate!, dateObject.endDate!);
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
                    ));
                  },
                  child: Icon(Icons.filter_1_outlined),
                ),
                DropdownSearch(
                  items: ["Presence", "Overtime"],
                  popupProps: PopupProps.menu(
                    fit: FlexFit.loose,
                  ),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Filter",
                    ),
                  ),
                  selectedItem: "Presence",
                  onChanged: (value) {
                    print(value);
                    controller.filterOption = value;

                    controller.update();
                  },
                ),
                SizedBox(height: 20),
                DropdownSearch(
                  items: ["Ascending", "Descending"],
                  popupProps: PopupProps.menu(
                    fit: FlexFit.loose,
                  ),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Filter",
                    ),
                  ),
                  selectedItem: "Descending",
                  onChanged: (value) {
                    if (value == "Descending") {
                      controller.isDescending = true;
                    } else {
                      controller.isDescending = false;
                    }

                    controller.update();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            flex: 7,
            child: ListView(
              padding: EdgeInsets.all(30),
              children: [
                GetBuilder<PresenceHistoryController>(
                  builder: (c) =>
                      FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    future: controller.getUserPresenceHistory(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      print("Snapshot -> ${snapshot.data?.docs}");

                      if (snapshot.data == null ||
                          snapshot.data?.docs.length == 0) {
                        return Center(
                          child: Text("Tidak ada data absensi"),
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

                          String presenceIn = DateFormat("HH:mm:ss a").format(
                              DateTime.parse(
                                  userHistoryData["masuk"]["datetime"]));

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Material(
                              borderRadius: BorderRadius.circular(20),
                              color: Color.fromARGB(255, 230, 111, 111),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => Get.toNamed(
                                  Routes.PRESENCE_DETAILS,
                                  arguments: userHistoryData,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 30,
                                    horizontal: 30,
                                  ),
                                  child: Column(
                                    children: [
                                      Text("${dateFormat}"),
                                      SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Masuk"),
                                              SizedBox(height: 4),
                                              Text(presenceIn),
                                            ],
                                          ),
                                          Spacer(),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text("Pulang"),
                                              SizedBox(height: 4),
                                              Text(
                                                userHistoryData['pulang'] !=
                                                        null
                                                    ? "${DateFormat("HH:mm:ss a").format(DateTime.parse(userHistoryData["pulang"]["datetime"]))}"
                                                    : "-",
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.dialog(
            Dialog(
              child: DatePickerDialog(controller: controller),
            ),
          );
        },
        child: Icon(
          Icons.filter,
        ),
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
