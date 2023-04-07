import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/update_user_profile_controller.dart';

class UpdateUserProfileView extends GetView<UpdateUserProfileController> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> userData = Get.arguments;

    controller.emailC.text = userData['email'];
    controller.gradeC.text = userData['grade'];
    controller.nipC.text = userData['nip'];
    controller.fullnameC.text = userData['fullname'];

    return Scaffold(
      appBar: AppBar(
        title: Text('UpdateUserProfileView'),
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
          Text("Avatar"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetBuilder<UpdateUserProfileController>(
                builder: (controller) {
                  if (controller.image != null) {
                    return ClipOval(
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Image.file(
                          File(controller.image!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } else {
                    if (userData['avatar'] != null) {
                      return Row(
                        children: [
                          ClipOval(
                            child: SizedBox(
                              height: 100,
                              width: 100,
                              child: Image.network(
                                userData['avatar'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Obx(
                            () => TextButton(
                              onPressed: () {
                                controller.deleteAvatar();
                              },
                              child: controller.isAvatarDelete.isFalse
                                  ? Text("X")
                                  : SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(),
                                    ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Text("Tidak ada avatar");
                    }
                  }
                },
              ),
              TextButton(
                onPressed: () {
                  controller.getImage();
                },
                child: Text("Choose file"),
              ),
            ],
          ),
          SizedBox(height: 20),
          Obx(
            () => ElevatedButton(
              onPressed: () async {
                if (controller.isLoading.isFalse) {
                  await controller.updateProfile();
                }
              },
              child: Text(
                controller.isLoading.isFalse ? "Update Profile." : "Loading..",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
