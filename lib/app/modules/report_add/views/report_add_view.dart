import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/report_add_controller.dart';

class ReportAddView extends GetView<ReportAddController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ReportAddView'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: controller.subjectC,
            decoration: InputDecoration(
              hintText: "Name",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          RDropdownMenu(
            isEnabled: true,
            controller: controller,
            dataType: 'type',
            title: 'Type',
          ),
          SizedBox(height: 10),
          RDropdownMenu(
            isEnabled: true,
            controller: controller,
            dataType: "category",
            title: "Category",
          ),
          SizedBox(height: 10),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  fixedSize: Size(Get.width * .42, 40),
                ),
                onPressed: () {
                  Get.dialog(
                    Dialog(
                      child: IntrinsicHeight(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text("Manage Report Category/Type"),
                              SizedBox(height: 20),
                              TextField(
                                controller: controller.newTypeC,
                                decoration: InputDecoration(
                                  hintText: "Name",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 10),
                              DropdownSearch(
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Please Select Type/Category",
                                  ),
                                ),
                                popupProps: PopupProps.menu(
                                  fit: FlexFit.loose,
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
                              SizedBox(height: 20),
                              Obx(
                                () => ElevatedButton(
                                  onPressed: () {
                                    controller.submitNewCategory();
                                  },
                                  child: Text(
                                    controller.isLoading.isFalse
                                        ? "Submit"
                                        : "Loading ..",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: Text("Add Category/Type"),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  fixedSize: Size(Get.width * .42, 40),
                ),
                onPressed: () {
                  Get.dialog(
                    Dialog(
                      child: IntrinsicHeight(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text("Manage Report Category/Type"),
                              SizedBox(height: 20),
                              DropdownSearch(
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Please Select Type/Category",
                                  ),
                                ),
                                popupProps: PopupProps.menu(
                                  fit: FlexFit.loose,
                                ),
                                items: [
                                  "Type",
                                  "Category",
                                ],
                                onChanged: (value) {
                                  if (value == "Category") {
                                    controller.selectedReport.value =
                                        "category";
                                  } else {
                                    controller.selectedReport.value = "type";
                                  }
                                },
                              ),
                              SizedBox(height: 10),
                              Obx(
                                () => RDropdownMenu(
                                  controller: controller,
                                  dataType: controller.selectedReport.value ==
                                          "category"
                                      ? "category"
                                      : "type",
                                  title: controller.selectedReport.value ==
                                          "category"
                                      ? "Please select Category"
                                      : "Please select Type",
                                  isEnabled:
                                      controller.selectedReport.value.isNotEmpty
                                          ? true
                                          : false,
                                ),
                              ),
                              SizedBox(height: 20),
                              Obx(
                                () => ElevatedButton(
                                  onPressed: () {
                                    controller.updateCategory(
                                        controller.selectedReport.value);
                                  },
                                  child: Text(
                                    controller.isLoading.isFalse
                                        ? "Delete"
                                        : "Loading ..",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: Text("Delete Category/Type"),
              ),
            ],
          ),
          Divider(),
          SizedBox(height: 10),
          TextField(
            controller: controller.descriptionC,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: "Description",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              controller.getImage();
            },
            child: Text("Upload Images"),
          ),
          GetBuilder<ReportAddController>(
            builder: (c) => ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount:
                  controller.imgs.isNotEmpty ? controller.imgs.length : 0,
              itemBuilder: (context, index) {
                if (controller.imgs.isEmpty) {
                  return SizedBox();
                } else {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: Get.width,
                            height: 180,
                            child: Image.file(
                              File(controller.imgs[index].path),
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(controller.imgs[index].name),
                          SizedBox(height: 6),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              fixedSize: Size(Get.width, 30),
                            ),
                            onPressed: () {
                              if (controller.imgs.isNotEmpty) {
                                controller.imgs.removeAt(index);
                                controller.update();
                              }
                            },
                            child: Text("Delete"),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          SizedBox(height: 20),
          Obx(
            () => ElevatedButton(
              onPressed: () {
                controller.submitReport();
              },
              child: Text(
                controller.isLoading.isFalse ? "Submit" : "Loading ..",
              ),
            ),
          ),
        ],
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
        return DropdownSearch(
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: title,
            ),
          ),
          popupProps: PopupProps.menu(
            fit: FlexFit.loose,
          ),
          enabled: isEnabled,
          items: getReport == null ? ["No Data Found"] : getReport,
          onChanged: (value) {
            controller.getCategory(value, dataType);
            // print(onChanged);
          },
        );
      },
    );
  }
}
