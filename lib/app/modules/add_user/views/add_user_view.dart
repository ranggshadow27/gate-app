import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/add_user_controller.dart';

class AddUserView extends GetView<AddUserController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AddUserView'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(25),
        children: [
          TextField(
            controller: controller.emailC,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: controller.nipC,
            decoration: InputDecoration(
              labelText: 'NIP',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: controller.fullnameC,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: controller.gradeC,
            decoration: InputDecoration(
              labelText: 'Grade',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          Divider(),
          SizedBox(height: 20),
          TextField(
            controller: controller.mainSalaryC,
            decoration: InputDecoration(
              labelText: 'Main Salary',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: controller.dailySalaryC,
            decoration: InputDecoration(
              labelText: 'Daily Salary',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: controller.allowanceSalaryC,
            decoration: InputDecoration(
              labelText: 'Allowance',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: controller.bpjsC,
            decoration: InputDecoration(
              labelText: 'BPJS',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: controller.bpjskC,
            decoration: InputDecoration(
              labelText: 'BPJS TK',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (controller.isLoading.isFalse) {
                controller.addUser();
              }
            },
            child: Text(
              controller.isLoading.isFalse ? "Register User." : "Loading..",
            ),
          ),
        ],
      ),
    );
  }
}
