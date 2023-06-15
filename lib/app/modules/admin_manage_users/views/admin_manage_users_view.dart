import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/appbar.dart';
import 'package:gate/app/components/widgets/button.dart';
import 'package:gate/app/components/widgets/custom_icon.dart';
import 'package:gate/app/components/widgets/text_widget.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uicons/uicons.dart';

import '../../../routes/app_pages.dart';
import '../controllers/admin_manage_users_controller.dart';

class AdminManageUsersView extends GetView<AdminManageUsersController> {
  Map<String, dynamic> userData = Get.arguments;

  @override
  Widget build(BuildContext context) {
    String defaultAvatar = "https://ui-avatars.com/api/?name=${userData['fullname']}";

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            RAppBar(onPressed: () => Get.back(), title: "Admin User View"),
            SizedBox(height: 20),
            Column(
              children: [
                ClipOval(
                  child: Container(
                    width: 100,
                    height: 100,
                    color: borderColor,
                    child: Image.network(
                      userData['avatar'] != null ? "${userData['avatar']}" : defaultAvatar,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            RText(text: "User Info.", textStyle: interSemiBold),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: borderColor,
              ),
              child: Column(
                children: [
                  RUserInfoTile(
                    data: userData['uid'],
                    title: 'UID :',
                    icon: UIcons.solidRounded.key,
                  ),
                  SizedBox(height: 14),
                  RUserInfoTile(
                    data: userData['fullname'],
                    title: 'Name :',
                    icon: UIcons.solidRounded.user,
                  ),
                  SizedBox(height: 14),
                  RUserInfoTile(
                    data: userData['email'],
                    title: 'Email:',
                    icon: UIcons.solidRounded.envelope,
                  ),
                  SizedBox(height: 14),
                  RUserInfoTile(
                    data: userData['grade'],
                    title: 'Grade:',
                    icon: UIcons.solidRounded.users,
                  ),
                  SizedBox(height: 14),
                  RUserInfoTile(
                    data: userData['role'],
                    title: 'Role:',
                    icon: UIcons.solidRounded.chart_tree,
                  ),
                  SizedBox(height: 14),
                  RUserInfoTile(
                    data: DateFormat("dd, MMMM yyyy").format(DateTime.parse(userData['createdAt'])),
                    title: 'Created Date:',
                    icon: UIcons.solidRounded.time_add,
                  ),
                ],
              ),
            ),
            if (userData['role'] == "user") SizedBox(height: 10),
            if (userData['role'] == "user")
              Column(
                children: [
                  SizedBox(height: 20),
                  RButton(
                    color: greenColor,
                    text: "Presence History",
                    callback: () => Get.toNamed(
                      Routes.ADMIN_USER_PRESENCE_HISTORY,
                      arguments: userData,
                    ),
                  ),
                  SizedBox(height: 10),
                  RButton(
                    color: greenColor,
                    text: "Salary Info",
                    callback: () =>
                        Get.toNamed(Routes.ADMIN_USER_SALARY, arguments: userData['uid']),
                  ),
                  SizedBox(height: 10),
                  RButton(
                    color: redColor,
                    text: "Delete User",
                    callback: () async {
                      await controller.deleteUser(userData['uid']);
                    },
                  ),
                ],
              ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class RUserInfoTile extends StatelessWidget {
  const RUserInfoTile({
    super.key,
    required this.data,
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;
  final String data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RIcon(icon: icon),
        SizedBox(width: 16),
        SizedBox(
          width: Get.width * .65,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RText(text: title, textStyle: interSemiBold),
              RText(
                text: data,
                textStyle: interRegular,
                maxLine: 1,
                isOverflow: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
