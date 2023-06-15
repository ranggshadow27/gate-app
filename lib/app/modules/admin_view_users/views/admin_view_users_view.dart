import 'package:cached_network_image/cached_network_image.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/widgets/appbar.dart';

import 'package:get/get.dart';

import '../../../components/widgets/text_widget.dart';
import '../../../routes/app_pages.dart';
import '../controllers/admin_view_users_controller.dart';

class AdminViewUsersView extends GetView<AdminViewUsersController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            RAppBar(onPressed: () => Get.back(), title: "Select User"),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GetBuilder<AdminViewUsersController>(
                  builder: (c) => FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    future: controller.getAllUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (!snapshot.hasData) {
                        return Center(
                          child: RText(
                            text: "No User Found.",
                            textStyle: interMedium,
                            color: redColor,
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> userData = snapshot.data!.docs[index].data();
                          String defaultAvatar =
                              "https://ui-avatars.com/api/?name=${userData['fullname']}";
                          return buildRListTile(context, userData, defaultAvatar);
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildRListTile(BuildContext context, Map<String, dynamic> userData, String defaultAvatar) {
  return Padding(
    padding: EdgeInsets.only(bottom: 16),
    child: Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(90),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: () => Get.toNamed(
          Routes.ADMIN_MANAGE_USERS,
          arguments: userData,
        ),
        borderRadius: BorderRadius.circular(90),
        child: Container(
          padding: EdgeInsets.all(20),
          width: Get.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      height: 60,
                      width: 60,
                      color: borderColor,
                      child: userData['avatar'] != null
                          ? CachedNetworkImage(
                              imageUrl: userData['avatar'],
                              placeholder: (context, url) => Image.network(
                                defaultAvatar,
                                fit: BoxFit.cover,
                              ),
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              defaultAvatar,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(width: 14),
                  SizedBox(
                    width: Get.width * .5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RText(
                          maxLine: 1,
                          isOverflow: true,
                          textStyle: interSemiBold,
                          text: "${userData['fullname']}",
                        ),
                        RText(
                          maxLine: 1,
                          isOverflow: true,
                          textStyle: interRegular,
                          text: "${userData['grade']}",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
