import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

import '../controllers/reset_default_password_controller.dart';

class ResetDefaultPasswordView extends GetView<ResetDefaultPasswordController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ResetDefaultPasswordView'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(25),
        children: [
          TextField(
            controller: controller.newPassC,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "New Password",
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: controller.confirmNewPassC,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Confirm Password",
            ),
          ),
          SizedBox(height: 20),
          Obx(
            () => ElevatedButton(
              onPressed: () {
                if (controller.isLoading.isFalse) {
                  controller.changePassword();
                }
              },
              child: Text(
                controller.isLoading.isFalse ? "Change Password" : "Loading ..",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
