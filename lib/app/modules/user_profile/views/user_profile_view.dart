import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/controllers/page_setup_controller.dart';
import 'package:gate/app/routes/app_pages.dart';

import 'package:get/get.dart';

import '../controllers/user_profile_controller.dart';

class UserProfileView extends GetView<UserProfileController> {
  final pageController = Get.find<PageSetupController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UserProfileView'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(25),
        children: [
          StreamBuilder(
            stream: controller.getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData) {
                return Center(
                  child: Text("Tidak ada data yang ditemukan"),
                );
              }

              Map<String, dynamic> userData = snapshot.data!.data()!;

              String defaultAvatar =
                  "https://ui-avatars.com/api/?name=${userData['fullname']}";

              return Column(
                children: [
                  ClipOval(
                    child: Container(
                      height: 100,
                      width: 100,
                      child: Image.network(
                        userData['avatar'] != null
                            ? userData['avatar'] != ""
                                ? userData['avatar']
                                : userData['avatar']
                            : defaultAvatar,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text("User."),
                  Text("${userData["fullname"]}"),
                  SizedBox(height: 10),
                  Text("Email."),
                  Text("${userData["email"]}"),
                  SizedBox(height: 20),
                  FutureBuilder(
                    future: controller.getSalaryData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      Map<String, dynamic> salaryData = snapshot.data!.data()!;
                      return Obx(
                        () {
                          return Column(
                            children: [
                              controller.showSalaryInfo.isTrue
                                  ? SizedBox(
                                      child: Column(
                                        children: [
                                          Divider(),
                                          Text("Gapok : ${salaryData['main']}"),
                                          Text("UM : ${salaryData['daily']}"),
                                          Text(
                                              "Tunjangan : ${salaryData['allowance']}"),
                                        ],
                                      ),
                                    )
                                  : SizedBox(),
                              TextButton(
                                onPressed: () async {
                                  await controller.getSalaryData();
                                  controller.showSalaryInfo.toggle();
                                },
                                child: Text(
                                  controller.showSalaryInfo.isFalse
                                      ? "Show Salary Info"
                                      : "Hide Salary Info",
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => Get.toNamed(
                      Routes.UPDATE_USER_PROFILE,
                      arguments: userData,
                    ),
                    child: Text("Update Profile"),
                  ),
                  ElevatedButton(
                    onPressed: () => Get.toNamed(Routes.UPDATE_USER_PASSWORD),
                    child: Text("Update Password"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Get.offAllNamed(Routes.LOGIN);
                    },
                    child: Text("Logout"),
                  ),
                ],
              );
            },
          )
        ],
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
