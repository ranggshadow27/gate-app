import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/icon_data.dart';
import 'package:gate/app/components/widgets/bottom_navigation.dart';
import 'package:gate/app/components/widgets/button.dart';
import 'package:gate/app/components/widgets/custom_icon.dart';
import 'package:gate/app/components/widgets/svgicon.dart';
import 'package:gate/app/components/widgets/text_widget.dart';
import 'package:gate/app/controllers/page_setup_controller.dart';
import 'package:gate/app/routes/app_pages.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uicons/uicons.dart';

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
                    InkWell(
                      onTap: () => Get.toNamed(Routes.UPDATE_USER_PROFILE, arguments: userData),
                      child: ClipOval(
                        child: Container(
                          height: 100,
                          width: 100,
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
                    ),
                    SizedBox(height: 40),
                    RText(text: "Account Info.", textStyle: interSemiBold),
                    SizedBox(height: 10),
                    Container(
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
                            icon: UIcons.solidRounded.user,
                          ),
                          SizedBox(height: 18),
                          buildAccountInfo(
                            title: "Email :",
                            userData: userData["email"],
                            icon: UIcons.solidRounded.envelope,
                          ),
                          SizedBox(height: 18),
                          buildAccountInfo(
                            title: "NIP :",
                            userData: userData["nip"],
                            icon: UIcons.solidRounded.address_book,
                          ),
                          SizedBox(height: 18),
                          buildAccountInfo(
                            title: "Grade :",
                            userData: userData["grade"],
                            icon: UIcons.solidRounded.chart_tree,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    FutureBuilder(
                      future: controller.getSalaryData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        Map<String, dynamic> salaryData = snapshot.data!.data()!;
                        return TextButton(
                          onPressed: () async {
                            await controller.getSalaryData();
                            controller.showSalaryInfo.toggle();
                            _showBottomSheet(context, salaryData);
                          },
                          child: RText(
                            text: "Show Salary Info",
                            textStyle: interSemiBold,
                            isUnderlined: true,
                            color: greenColor,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: Get.width,
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          buildAccountSettings(
                            title: "Presence History",
                            icon: UIcons.solidRounded.time_quarter_to,
                            onTap: () {
                              pageController.visitPage(1);
                            },
                            isFirst: true,
                          ),
                          buildAccountSettings(
                            title: "Update Password",
                            icon: UIcons.solidRounded.refresh,
                            onTap: () => Get.toNamed(Routes.UPDATE_USER_PASSWORD),
                          ),
                          buildAccountSettings(
                            title: "Update Profile",
                            icon: UIcons.solidRounded.user_time,
                            onTap: () => Get.toNamed(
                              Routes.UPDATE_USER_PROFILE,
                              arguments: userData,
                            ),
                          ),
                          buildAccountSettings(
                            title: "Payroll",
                            icon: UIcons.solidRounded.receipt,
                            onTap: () => Get.toNamed(Routes.PAYROLL),
                          ),
                          buildAccountSettings(
                            title: "Dispensation",
                            icon: UIcons.solidRounded.doctor,
                            onTap: () => Get.toNamed(Routes.DISPENSATION),
                          ),
                          buildAccountSettings(
                            title: "Operational Report",
                            icon: UIcons.solidRounded.document,
                            onTap: () {
                              pageController.visitPage(3);
                            },
                            isLast: true,
                          ),
                        ],
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
      bottomNavigationBar: RBottomNavigation(),
    );
  }

  Widget buildAccountInfo(
      {required String userData, required String title, required IconData icon}) {
    return Row(
      children: [
        RIcon(icon: icon),
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
    required IconData icon,
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
                  RIcon(icon: icon),
                  SizedBox(width: 16),
                  RText(text: title, textStyle: interRegular),
                  Spacer(),
                  RIcon(icon: UIcons.regularRounded.angle_small_right),
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

  void _showBottomSheet(BuildContext context, Map<String, dynamic> salaryData) {
    NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 2);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 60),
          color: bgColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  RIcon(icon: UIcons.solidRounded.caret_right),
                  RText(
                    text: "Main Salary : ${currencyFormat.format(salaryData['main'])}",
                    textStyle: interRegular,
                  )
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  RIcon(icon: UIcons.solidRounded.caret_right),
                  RText(
                    text: "Allowance : ${currencyFormat.format(salaryData['allowance'])}",
                    textStyle: interRegular,
                  )
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  RIcon(icon: UIcons.solidRounded.caret_right),
                  RText(
                    text: "Daily : ${currencyFormat.format(salaryData['daily'])}",
                    textStyle: interRegular,
                  )
                ],
              ),
              SizedBox(height: 10),
              Divider(color: whiteColor),
              SizedBox(height: 10),
              Row(
                children: [
                  RIcon(icon: UIcons.solidRounded.caret_right),
                  RText(
                    text: "BPJS : ${currencyFormat.format(salaryData['bpjs'])}",
                    textStyle: interRegular,
                  )
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  RIcon(icon: UIcons.solidRounded.caret_right),
                  RText(
                    text: "BPJS K : ${currencyFormat.format(salaryData['bpjsk'])}",
                    textStyle: interRegular,
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
