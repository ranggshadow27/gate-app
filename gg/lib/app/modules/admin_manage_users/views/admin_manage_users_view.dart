import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/admin_manage_users_controller.dart';

class AdminManageUsersView extends GetView<AdminManageUsersController> {
  Map<String, dynamic> userData = Get.arguments;

  @override
  Widget build(BuildContext context) {
    String defaultAvatar =
        "https://ui-avatars.com/api/?name=${userData['fullname']}";

    return Scaffold(
      appBar: AppBar(
        title: Text('AdminManageUsersView'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(35),
        children: [
          Column(
            children: [
              ClipOval(
                child: Container(
                  width: 100,
                  height: 100,
                  child: Image.network(
                    userData['avatar'] != null
                        ? "${userData['avatar']}"
                        : defaultAvatar,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text("UID : ${userData['uid']}"),
              Text("Name : ${userData['fullname']}"),
              Text("Grade : ${userData['grade']}"),
              Text("Role : ${userData['role']}"),
              Divider(),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(Get.width, 20),
                ),
                onPressed: () => Get.toNamed(Routes.ADMIN_USER_PRESENCE_HISTORY,
                    arguments: userData['uid']),
                child: Icon(Icons.timelapse_rounded),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(Get.width, 20),
                ),
                onPressed: () => Get.toNamed(Routes.ADMIN_USER_SALARY,
                    arguments: userData['uid']),
                child: Icon(Icons.payment),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(Get.width, 20),
                ),
                onPressed: () async {
                  await controller.deleteUser(userData['uid']);
                },
                child: Icon(Icons.person_off),
              ),
            ],
          )
        ],
      ),
    );
  }
}
