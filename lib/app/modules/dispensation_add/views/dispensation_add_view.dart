import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'package:get/get.dart';

import '../controllers/dispensation_add_controller.dart';

class DispensationAddView extends GetView<DispensationAddController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DispensationAddView'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(25),
        children: [
          DropdownSearch(
            items: ["Sakit", "Izin"],
            popupProps: PopupProps.menu(fit: FlexFit.loose),
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: "Please Select Dispensation Type"),
            ),
            onChanged: (value) {
              controller.dispensationType = value;
              print(controller.dispensationType);
            },
          ),
          SizedBox(height: 20),
          TextField(
            controller: controller.subjectC,
            decoration: InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: controller.descC,
            maxLines: null,
            textAlign: TextAlign.justify,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => controller.getImage(),
            child: Text("Pick a file"),
          ),
          SizedBox(height: 20),
          GetBuilder<DispensationAddController>(
            builder: (controller) {
              if (controller.image != null) {
                return Image.file(
                  File(controller.image!.path),
                  fit: BoxFit.cover,
                );
              }

              return SizedBox();
            },
          ),
          SizedBox(height: 20),
          Obx(
            () => ElevatedButton(
              onPressed: () {
                controller.submitDispensation();
              },
              child: Text(
                controller.isLoading.isFalse ? "Register User." : "Loading..",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
