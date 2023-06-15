import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/custom_icon.dart';
import 'package:gate/app/routes/app_pages.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uicons/uicons.dart';

import '../../../components/colors.dart';
import '../../../components/widgets/text_widget.dart';
import '../controllers/admin_home_controller.dart';

class AdminHomeView extends GetView<AdminHomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildStreamAdmin(controller.getAdminData()),
                  Divider(),
                  SizedBox(height: 20),
                  RText(text: "User Menu.", textStyle: interSemiBold),
                  SizedBox(height: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.all(16),
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => Get.toNamed(Routes.ADD_USER),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RIcon(icon: UIcons.regularRounded.plus_small, color: greenColor),
                        SizedBox(width: 10),
                        RText(text: "Add User", textStyle: interRegular, color: greenColor),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.all(16),
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => Get.toNamed(Routes.ADMIN_VIEW_USERS),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RIcon(icon: UIcons.solidRounded.users, color: greenColor),
                        SizedBox(width: 10),
                        RText(text: "Manage Users", textStyle: interRegular, color: greenColor),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RText(text: "Latest Dispensations.", textStyle: interSemiBold),
                      TextButton(
                        onPressed: () => Get.toNamed(Routes.ADMIN_DISPENSATIONS),
                        child: RText(
                          text: "More. ->",
                          textStyle: interSemiBold,
                          color: greenColor,
                          isUnderlined: true,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            buildStreamDispensation(controller.streamDispensation(), controller),
            SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FirebaseAuth.instance.signOut();
          Get.offAllNamed(Routes.LOGIN);
        },
        backgroundColor: redColor,
        child: RIcon(icon: UIcons.regularRounded.sign_out_alt),
      ),
    );
  }
}

Widget buildStreamAdmin(Stream<DocumentSnapshot<Map<String, dynamic>>>? stream) {
  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: stream,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData) {
        return Center(
          child: RText(
            text: "No data found.",
            textStyle: interMedium,
            color: redColor,
          ),
        );
      }

      Map<String, dynamic>? adminData = snapshot.data!.data();
      String defaultAvatar = "https://ui-avatars.com/api/?name=${adminData!['fullname']}";

      return Column(
        children: [
          ClipOval(
            child: Container(
              width: 80,
              height: 80,
              color: borderColor,
              child: adminData['avatar'] != null
                  ? CachedNetworkImage(
                      imageUrl: adminData['avatar'],
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
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RText(text: "Welcome. ", textStyle: interRegular),
              RText(text: adminData['fullname'], textStyle: interSemiBold),
            ],
          ),
          RText(text: adminData['role'], textStyle: interMedium),
          SizedBox(height: 8),
        ],
      );
    },
  );
}

Widget buildStreamDispensation(
    Stream<QuerySnapshot<Map<String, dynamic>>>? stream, AdminHomeController controller) {
  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: stream,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data?.docs.length == 0) {
        return Center(
          child: RText(
            text: "No data found.",
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
          Map<String, dynamic> data = snapshot.data!.docs[index].data();

          String dateF =
              DateFormat("EEEE, dd MMMM yyyy").format(DateTime.parse(data['createdDate']));

          // String getDate = "15-06-2023";
          String getDate = DateFormat("dd-MM-yyyy").format(DateTime.parse(data['createdDate']));
          String? today = controller.todayDate;

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Material(
              color: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: borderColor),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => Get.toNamed(
                  Routes.DISPENSATION_DETAILS,
                  arguments: data,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RText(
                            text: dateF,
                            fontSize: 12.0,
                            textStyle: interRegular,
                          ),
                          SizedBox(height: 4),
                          RText(text: data['subject'], textStyle: interRegular),
                          SizedBox(height: 4),
                          RText(
                            fontSize: 12.0,
                            textStyle: interMedium,
                            color: whiteColor.withOpacity(.8),
                            text: data['createdBy'].toString().toUpperCase(),
                          ),
                        ],
                      ),
                      Spacer(),
                      if (getDate == today)
                        RText(
                          text: "New!   ",
                          textStyle: interMedium,
                          color: greenColor,
                        ),
                      RIcon(icon: UIcons.boldRounded.arrow_small_right)
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
