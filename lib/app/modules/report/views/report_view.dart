import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/controllers/page_setup_controller.dart';

import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../routes/app_pages.dart';
import '../controllers/report_controller.dart';

class ReportView extends GetView<ReportController> {
  final pageController = Get.find<PageSetupController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Operational Report'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            width: double.infinity,
            child: Row(
              children: [
                SizedBox(
                    width: Get.width * .5,
                    child: FutureBuilder(
                      future: controller.getCategory(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Memuat data");
                        }

                        Map<String, dynamic> categoryData =
                            snapshot.data!.data()!;

                        List listData = ["Show All"];
                        listData.addAll(categoryData['category']);

                        print(listData);

                        return DropdownSearch(
                          selectedItem: null,
                          popupProps: PopupProps.menu(),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              hintText: "Select Category",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          onChanged: (value) {
                            controller.filterByCategory.value = value;
                            controller.update();
                          },
                          items: listData,
                        );
                      },
                    )),
                Spacer(),
                Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(Get.width * .15, Get.width * .15),
                    ),
                    onPressed: () {
                      controller.isDescending.toggle();
                      controller.update();
                      print(controller.isDescending);
                    },
                    child: Icon(
                      controller.isDescending.isTrue
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                    ),
                  ),
                ),
                SizedBox(width: 5),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(Get.width * .15, Get.width * .15),
                  ),
                  onPressed: () {
                    Get.dialog(
                      Dialog(
                        child: Container(
                          height: 400,
                          padding: EdgeInsets.all(20),
                          child: SfDateRangePicker(
                            showActionButtons: true,
                            selectionMode: DateRangePickerSelectionMode.range,
                            monthViewSettings: DateRangePickerMonthViewSettings(
                                firstDayOfWeek: 1),
                            onCancel: () => Get.back(),
                            onSubmit: (p0) {
                              if (p0 != null) {
                                if ((p0 as PickerDateRange).endDate != null) {
                                  controller.pickerDate(
                                      p0.startDate!, p0.endDate!);
                                  Get.back();
                                } else {
                                  Get.snackbar("Error",
                                      "Mohon untuk mengisi tanggal akhir");
                                }
                              } else {
                                Get.snackbar("Error",
                                    "Mohon untuk mengisi tanggal awal dan akhir");
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  child: Icon(Icons.calendar_month),
                ),
              ],
            ),
          ),
          Container(
            width: Get.width,
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.filterByCategory.isEmpty ||
                              controller.filterByCategory.value == "Show All"
                          ? "Sort by : Category (${controller.filterByCategory.value})"
                          : "Sort by : Category (${controller.filterByCategory.value})",
                    ),
                    Text(
                      controller.isDescending.isTrue
                          ? "Descending"
                          : "Ascending",
                    ),
                  ],
                )),
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
                      child: Text("Tidak ada data ditemukan"),
                    );
                  }

                  print("Ini datanya -----> ${snapshot.data!}");

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> reportData =
                          snapshot.data!.docs[index].data();

                      return ListTile(
                        onTap: () => Get.toNamed(
                          Routes.REPORT_DETAIL,
                          arguments: reportData,
                        ),
                        title: Text(
                          "${reportData['subject']}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(Icons.chevron_right_rounded),
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.REPORT_ADD),
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: Obx(
        () => BottomBarCreative(
          items: [
            TabItem(
              icon: Icons.home,
            ),
            TabItem(
              icon: Icons.history,
            ),
            TabItem(
              icon: pageController.isLoading.isFalse
                  ? Icons.favorite_border
                  : Icons.waving_hand,
            ),
            TabItem(
              icon: Icons.file_copy,
            ),
            TabItem(
              icon: Icons.account_box,
            ),
          ],
          iconSize: 30,
          backgroundColor: Colors.green.withOpacity(0.21),
          color: Colors.red,
          colorSelected: Colors.white,
          indexSelected: pageController.initialPage.value,
          // isFloating: true,
          highlightStyle: const HighlightStyle(
            sizeLarge: true,
            background: Colors.red,
            elevation: 3,
            isHexagon: true,
          ),
          onTap: (int index) => pageController.visitPage(index),
        ),
      ),
    );
  }
}
