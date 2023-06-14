import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/icon_data.dart';
import 'package:gate/app/components/widgets/button.dart';
import 'package:gate/app/components/widgets/svgicon.dart';
import 'package:gate/app/components/widgets/text_widget.dart';
import 'package:gate/app/controllers/page_setup_controller.dart';
import 'package:gate/app/routes/app_pages.dart';

import 'package:get/get.dart';

import '../controllers/user_profile_controller.dart';

class UserProfileView extends GetView<UserProfileController> {
  final pageController = Get.find<PageSetupController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
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

                String defaultAvatar = "https://ui-avatars.com/api/?name=${userData['fullname']}";

                return Column(
                  children: [
                    ClipOval(
                      child: Container(
                        height: 100,
                        width: 100,
                        color: borderColor,
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
                    SizedBox(height: 40),
                    RText(text: "Account Info.", textStyle: interSemiBold),
                    SizedBox(height: 10),
                    IntrinsicHeight(
                      child: Container(
                        width: Get.width,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            buildAccountInfo(
                              title: "Name :",
                              userData: userData["fullname"],
                              svgData: RSvgData.userSolid,
                            ),
                            SizedBox(height: 18),
                            buildAccountInfo(
                              title: "Email :",
                              userData: userData["email"],
                              svgData: RSvgData.envelope,
                            ),
                            SizedBox(height: 18),
                            buildAccountInfo(
                              title: "NIP :",
                              userData: userData["nip"],
                              svgData: RSvgData.userSolid,
                            ),
                            SizedBox(height: 18),
                            buildAccountInfo(
                              title: "Grade :",
                              userData: userData["grade"],
                              svgData: RSvgData.documentSolid,
                            ),
                          ],
                        ),
                      ),
                    ),
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
                                            Text("Tunjangan : ${salaryData['allowance']}"),
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
                    SizedBox(height: 20),
                    IntrinsicHeight(
                      child: Container(
                        width: Get.width,
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            buildAccountSettings(
                              title: "Presence History",
                              icon: RSvgData.add,
                              onTap: () {},
                              isFirst: true,
                            ),
                            buildAccountSettings(
                              title: "Update Password",
                              icon: RSvgData.add,
                              onTap: () => Get.toNamed(Routes.UPDATE_USER_PASSWORD),
                            ),
                            buildAccountSettings(
                              title: "Operational Report",
                              icon: RSvgData.add,
                              onTap: () {},
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    RButton(
                      width: Get.width,
                      color: redColor,
                      text: "Sign Out",
                      callback: () async {
                        await FirebaseAuth.instance.signOut();
                        Get.offAllNamed(Routes.LOGIN);
                      },
                    ),
                  ],
                );
              },
            )
          ],
        ),
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
              icon: pageController.isLoading.isFalse ? Icons.favorite_border : Icons.waving_hand,
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
          ),
          onTap: (int index) => pageController.visitPage(index),
        ),
      ),
    );
  }

  Widget buildAccountInfo(
      {required String userData, required String title, required String svgData}) {
    return Row(
      children: [
        SvgIcon(svgData: svgData),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RText(text: title, textStyle: interSemiBold, fontSize: 10.0),
            RText(
              text: userData,
              textStyle: interRegular,
              fontSize: 12.0,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildAccountSettings({
    required VoidCallback onTap,
    required String title,
    required String icon,
    bool isLast = false,
    bool isFirst = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(isLast == false ? 0 : 16),
            top: Radius.circular(isFirst == false ? 0 : 16)),
        onTap: onTap,
        child: Container(
          child: Column(
            children: [
              isFirst == true ? SizedBox(height: 8) : SizedBox(),
              SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(width: 16),
                  SvgIcon(svgData: icon),
                  SizedBox(width: 16),
                  RText(text: title, textStyle: interRegular),
                  Spacer(),
                  SvgIcon(svgData: RSvgData.history),
                  SizedBox(width: 16),
                ],
              ),
              Divider(
                color: isLast == false ? whiteColor : Colors.transparent,
                indent: 50,
              ),
              isLast == true ? SizedBox(height: 4) : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
