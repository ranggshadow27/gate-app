import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/button.dart';
import 'package:gate/app/components/widgets/custom_icon.dart';
import 'package:gate/app/components/widgets/custom_snackbar.dart';
import 'package:gate/app/components/widgets/snackbar_logic.dart';
import 'package:gate/app/components/widgets/textfield.dart';
import 'package:gate/app/controllers/page_setup_controller.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uicons/uicons.dart';

import '../../../components/widgets/bottom_navigation.dart';
import '../../../components/widgets/loading_widget.dart';
import '../../../components/widgets/text_widget.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  final pageController = Get.find<PageSetupController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            Column(
              children: [
                SizedBox(height: 20),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: controller.getUserData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: RLoading(),
                      );
                    }

                    if (!snapshot.hasData) {
                      return Center(
                        child: Text("Tidak ada data ditemukan"),
                      );
                    }

                    Map<String, dynamic> userData = snapshot.data!.data()!;

                    String defaultAvatar =
                        "https://ui-avatars.com/api/?name=${userData['fullname']}";

                    return Column(
                      children: [
                        ClipOval(
                          child: Container(
                            height: 80,
                            width: 80,
                            color: borderColor,
                            child: Image.network(
                              userData['avatar'] != null ? '${userData['avatar']}' : defaultAvatar,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RText(
                              text: 'Welcome.',
                              textStyle: interRegular,
                            ),
                            RText(
                              text: '${userData["fullname"]}',
                              textStyle: interBold,
                            ),
                          ],
                        ),
                        RText(
                          text: '${userData["email"]}',
                          textStyle: interRegular,
                          fontSize: 12.0,
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RIcon(icon: UIcons.solidRounded.marker),
                            SizedBox(width: 10),
                            RText(
                              text: 'Latest Location.',
                              textStyle: interSemiBold,
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Container(
                          width: Get.width * .8,
                          child: RText(
                            text: userData['address'] != null ? '${userData["address"]}' : '-',
                            textStyle: interRegular,
                            fontSize: 12.0,
                          ),
                        ),
                        SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            HomeIconBox(
                              title: "Payroll",
                              icon: UIcons.regularRounded.receipt,
                              onTap: () => Get.toNamed(Routes.PAYROLL),
                            ),
                            HomeIconBox(
                              title: "Dispensation",
                              icon: UIcons.regularRounded.doctor,
                              onTap: () => Get.toNamed(Routes.DISPENSATION),
                            ),
                            HomeIconBox(
                              title: "Overtime",
                              icon: UIcons.regularRounded.time_quarter_past,
                              onTap: () => Get.dialog(
                                ROvertimeDialog(pageController: pageController),
                              ),
                            ),
                            HomeIconBox(
                              title: "Report",
                              icon: UIcons.regularRounded.document,
                              onTap: () => pageController.visitPage(3),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RIcon(icon: UIcons.solidRounded.time_oclock),
                    SizedBox(width: 10),
                    RText(
                      text: 'Live Presence.',
                      textStyle: interSemiBold,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Obx(
                  () => RText(
                    text: '${controller.realTimeDate.value}',
                    textStyle: interRegular,
                  ),
                ),
                Obx(
                  () => RText(
                    text: '${controller.realTimeHour.value}',
                    textStyle: interMedium,
                    color: greenColor,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 20),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: controller.getUserTodayPresence(),
                  builder: (context, snapshotTodayPresence) {
                    if (snapshotTodayPresence.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: RLoading(),
                      );
                    }

                    Map<String, dynamic>? getTodayData = snapshotTodayPresence.data?.data();

                    return Row(
                      children: [
                        RPresenceBoard(
                          getTodayData: getTodayData,
                          color: greenColor,
                          presenceType: 'masuk',
                          title: "In",
                        ),
                        Spacer(),
                        RPresenceBoard(
                          getTodayData: getTodayData,
                          color: redColor,
                          presenceType: 'pulang',
                          title: "Out",
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () => pageController.visitPage(1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RIcon(icon: UIcons.solidRounded.time_half_past),
                      SizedBox(width: 10),
                      RText(
                        text: "Last Presence.",
                        textStyle: interSemiBold,
                        isUnderlined: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: controller.getUserHistoryPresence(),
                  builder: (context, snapshotHistory) {
                    if (snapshotHistory.connectionState == ConnectionState.waiting) {
                      return Center(child: RLoading());
                    }

                    if (snapshotHistory.data?.docs.length == 0 || snapshotHistory.data == null) {
                      return Center(
                        child: RText(
                          text: "Presence data not found.",
                          textStyle: interMedium,
                          color: redColor,
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshotHistory.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> getHistoryData =
                            snapshotHistory.data!.docs[index].data();

                        String formattedDate = DateFormat("EEEE, dd MMMM yyyy")
                            .format(DateTime.parse(getHistoryData['date']));

                        return RLastPresenceBoard(
                          getHistoryData: getHistoryData,
                          formattedDate: formattedDate,
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: RBottomNavigation(),
    );
  }
}

class RLastPresenceBoard extends StatelessWidget {
  const RLastPresenceBoard({
    super.key,
    required this.getHistoryData,
    required this.formattedDate,
  });

  final Map<String, dynamic> getHistoryData;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(18),
        color: darkColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Get.toNamed(
            Routes.PRESENCE_DETAILS,
            arguments: getHistoryData,
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            child: Column(
              children: [
                RText(
                  text: "$formattedDate",
                  textStyle: interRegular,
                  fontSize: 12.0,
                ),
                SizedBox(height: 4),
                RText(
                  text: getHistoryData['masuk']['device'] != null
                      ? getHistoryData['masuk']['device'].toString().toUpperCase()
                      : "NO DEVICE",
                  textStyle: interRegular,
                  fontSize: 10.0,
                  color: whiteColor.withOpacity(.6),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RText(
                          text: "Presence In",
                          textStyle: interRegular,
                          color: greenColor,
                          fontSize: 10.0,
                        ),
                        PresenceText(
                          getHistoryData: getHistoryData,
                          presence: 'masuk',
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RText(
                          text: "Presence Out",
                          textStyle: interRegular,
                          color: redColor,
                          fontSize: 10.0,
                        ),
                        PresenceText(
                          getHistoryData: getHistoryData,
                          presence: 'pulang',
                        ),
                      ],
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
}

class RPresenceBoard extends StatelessWidget {
  const RPresenceBoard({
    super.key,
    required this.getTodayData,
    required this.color,
    required this.presenceType,
    required this.title,
  });

  final Map<String, dynamic>? getTodayData;
  final String presenceType;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: bgColor,
        border: Border.all(color: borderColor),
      ),
      width: MediaQuery.of(context).size.width * .4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RText(
                text: "Presence ",
                textStyle: interRegular,
                fontSize: 12.0,
              ),
              RText(
                text: title,
                textStyle: interMedium,
                color: color,
                fontSize: 12.0,
              ),
            ],
          ),
          Divider(color: borderColor),
          RText(
            text: getTodayData?[presenceType] == null
                ? "-"
                : DateFormat("hh.mm a")
                    .format(DateTime.parse(getTodayData![presenceType]['datetime'])),
            textStyle: interRegular,
            fontSize: 20.0,
          ),
        ],
      ),
    );
  }
}

class HomeIconBox extends StatelessWidget {
  const HomeIconBox({
    super.key,
    required this.title,
    required this.onTap,
    required this.icon,
  });

  final String title;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: Size(64, 64),
            backgroundColor: borderColor,
            side: BorderSide(color: borderColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          onPressed: onTap,
          child: RIcon(
            icon: icon,
            color: whiteColor.withOpacity(.6),
          ),
        ),
        SizedBox(height: 8),
        RText(
          text: title,
          textStyle: interMedium,
          fontSize: 12.0,
        ),
      ],
    );
  }
}

class ROvertimeDialog extends StatelessWidget {
  const ROvertimeDialog({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  final PageSetupController pageController;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: darkColor,
      child: IntrinsicHeight(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RText(
                text: "Overtime Description",
                textStyle: interSemiBold,
                fontSize: 16.0,
              ),
              SizedBox(height: 20),
              RTextField(
                hintText: "Please Type Overtime Description",
                controller: pageController.overtimeTextC,
              ),
              SizedBox(height: 20),
              Obx(
                () {
                  return RButton(
                    color: greenColor,
                    text: pageController.isLoading.isFalse ? "Submit Form" : "Loading ..",
                    callback: () {
                      if (pageController.isLoading.isFalse) {
                        if (pageController.overtimeTextC.text.isEmpty) {
                          limitSnackbar(buildSnackError("Please input the required field."));
                        } else {
                          Get.dialog(
                            Dialog(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              child: Center(
                                child: RLoading(),
                              ),
                            ),
                          );
                          pageController.pickImage(presenceType: "overtime");
                        }
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PresenceText extends StatelessWidget {
  const PresenceText({
    Key? key,
    required this.getHistoryData,
    required this.presence,
  }) : super(key: key);

  final Map<String, dynamic> getHistoryData;
  final String presence;

  @override
  Widget build(BuildContext context) {
    return RText(
      textStyle: interRegular,
      fontSize: 16.0,
      text: getHistoryData[presence]?['datetime'] == "" ||
              getHistoryData[presence]?['datetime'] == null
          ? "-"
          : DateFormat("hh.mm a").format(DateTime.parse(getHistoryData[presence]!['datetime'])),
    );
  }
}
