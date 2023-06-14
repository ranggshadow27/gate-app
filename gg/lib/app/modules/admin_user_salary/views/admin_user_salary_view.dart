import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/admin_user_salary_controller.dart';

class AdminUserSalaryView extends GetView<AdminUserSalaryController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AdminUserSalaryView'),
        centerTitle: true,
      ),
      body: Obx(
        () {
          var getData = controller.map;
          controller.mainSalaryC.text = getData['main'] == null
              ? "Mengambil data .."
              : getData['main'].toString();
          controller.dailySalaryC.text = getData['daily'] == null
              ? "Mengambil data .."
              : getData['daily'].toString();
          controller.allowanceSalaryC.text = getData['allowance'] == null
              ? "Mengambil data .."
              : getData['allowance'].toString();
          controller.bpjsC.text = getData['bpjs'] == null
              ? "Mengambil data .."
              : getData['bpjs'].toString();
          controller.bpjskC.text = getData['bpjsk'] == null
              ? "Mengambil data .."
              : getData['bpjsk'].toString();

          return ListView(
            padding: EdgeInsets.all(20),
            children: [
              TextField(
                keyboardType: TextInputType.number,
                controller: controller.mainSalaryC,
                decoration: InputDecoration(
                  hintText: "Gaji Pokok",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                controller: controller.dailySalaryC,
                decoration: InputDecoration(
                  hintText: "Uang Makan",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                controller: controller.allowanceSalaryC,
                decoration: InputDecoration(
                  hintText: "Tunjangan",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                controller: controller.bpjsC,
                decoration: InputDecoration(
                  hintText: "BPJS",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                controller: controller.bpjskC,
                decoration: InputDecoration(
                  hintText: "BPJS K",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  controller.updateUserSalary();
                },
                child: Text(
                  controller.isLoading.isFalse ? "Update" : "Loading ..",
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
