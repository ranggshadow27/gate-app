import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/modules/report_add/controllers/report_add_controller.dart';

import 'package:get/get.dart';

import '../controllers/report_update_controller.dart';

class ReportUpdateView extends GetView<ReportUpdateController> {
  final addImageC = Get.put(ReportAddController());

  final Map<String, dynamic> reportData = Get.arguments;

  @override
  Widget build(BuildContext context) {
    controller.subjectC.text = reportData['subject'];
    controller.descriptionC.text = reportData['description'];

    return Scaffold(
      appBar: AppBar(
        title: Text('ReportUpdateView'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            children: [
              TextField(
                controller: controller.subjectC,
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
                    labelText: "Type",
                  ),
                ),
                popupProps: PopupProps.menu(
                  fit: FlexFit.loose,
                ),
                items: ["Switch Uplink", "Hardware", "Software", "Network", "Maintenance"],
                selectedItem: reportData['type'],
                onChanged: (value) {
                  controller.reportType = value;
                  print(controller.reportType);
                },
              ),
              SizedBox(height: 10),
              DropdownSearch<String>(
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Category",
                  ),
                ),
                popupProps: PopupProps.menu(
                  fit: FlexFit.loose,
                  showSelectedItems: false,
                ),
                items: [
                  "Heavy Rain",
                  "Traffic Drop",
                  "Preventive Maintenance",
                  "Urgent Maintenance",
                ],
                selectedItem: reportData['category'],
                onChanged: (value) {
                  controller.reportCategory = value;
                  print(controller.reportCategory);
                },
              ),
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

                      return Column(
                        children: [
                          SizedBox(
                            width: Get.width,
                            height: controller.isUpdate.isFalse ? 200 : 200,
                            child: Image.network(
                              imageUrl,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  controller.deleteImage(imageName, imageUrl);
                                },
                                child: Text("Delete"),
                              ),
                            ],
                          ),
                          Divider(),
                        ],
                      );
                    },
                  );
                },
              ),
              OutlinedButton(
                onPressed: () {
                  addImageC.getImage();
                },
                child: Text("Upload Images"),
              ),
              GetBuilder<ReportAddController>(
                builder: (c) => ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: addImageC.imgs.isNotEmpty ? addImageC.imgs.length : 0,
                  itemBuilder: (context, index) {
                    if (addImageC.imgs.isEmpty) {
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
                                  File(addImageC.imgs[index].path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(addImageC.imgs[index].name),
                              SizedBox(height: 6),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  fixedSize: Size(Get.width, 30),
                                ),
                                onPressed: () {
                                  if (addImageC.imgs.isNotEmpty) {
                                    addImageC.imgs.removeAt(index);
                                    addImageC.update();
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
              ElevatedButton(
                onPressed: () async {
                  await controller.updateReport();
                },
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
