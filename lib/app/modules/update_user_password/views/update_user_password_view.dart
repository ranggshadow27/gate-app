import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/update_user_password_controller.dart';

class UpdateUserPasswordView extends GetView<UpdateUserPasswordController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UpdateUserPasswordView'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(25),
        children: [
          TextField(
            controller: controller.oldPassC,
            decoration: InputDecoration(
              labelText: 'Old Password',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: controller.newPassC,
            decoration: InputDecoration(
              labelText: 'New Password',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: controller.confirmPassC,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          Obx(
            () => ElevatedButton(
              onPressed: () async {
                if (controller.isLoading.isFalse) {
                  await controller.updatePassword();
                }
              },
              child: Text(
                controller.isLoading.isFalse ? "Update Password." : "Loading..",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
