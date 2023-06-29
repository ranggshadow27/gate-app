import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/appbar.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../components/widgets/text_widget.dart';
import '../controllers/presence_details_controller.dart';

class PresenceDetailsView extends GetView<PresenceDetailsController> {
  Map<String, dynamic> getUserHistory = Get.arguments;

  @override
  Widget build(BuildContext context) {
    String date = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.parse(getUserHistory['date']));

    return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: [
              RAppBar(onPressed: () => Get.back(), title: "Presence Details"),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  color: bgColor,
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    RText(
                      text: date,
                      textStyle: interRegular,
                    ),
                    Divider(color: borderColor),
                    SizedBox(height: 10),
                    PresenceDetailBox(
                      getUserHistory: getUserHistory,
                      boxColor: greenColor,
                      middleText: "Presence In.",
                      title: "Presence In",
                      presenceType: 'masuk',
                    ),
                    if (getUserHistory['pulang'] != null) Divider(color: borderColor),
                    if (getUserHistory['pulang'] != null)
                      PresenceDetailBox(
                        getUserHistory: getUserHistory,
                        boxColor: redColor,
                        middleText: "Presence Out.",
                        title: "Presence Out",
                        presenceType: 'pulang',
                      ),
                    // Column(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Text(""),
                    //     Text(""),
                    //     Text(
                    //       getUserHistory['pulang'] != null
                    //           ? "Pulang: ${DateFormat('hh:mm:ss a').format(DateTime.parse(getUserHistory['pulang']['datetime']))}"
                    //           : "-",
                    //     ),
                    //     Text(
                    //       getUserHistory['pulang'] != null
                    //           ? "${getUserHistory['masuk']['address']}"
                    //           : "-",
                    //       textAlign: TextAlign.center,
                    //     ),
                    //     Text(getUserHistory['pulang'] != null
                    //         ? "Lat: ${getUserHistory['masuk']['latitude']}"
                    //         : "-"),
                    //     Text(getUserHistory['pulang'] != null
                    //         ? "Long: ${getUserHistory['masuk']['longitude']}"
                    //         : "-"),
                    //     Text(
                    //       getUserHistory['pulang'] != null
                    //           ? getUserHistory['pulang']['inArea'] == true
                    //               ? "Didalam Area"
                    //               : "Diluar Area"
                    //           : "-",
                    //     ),
                    //     getUserHistory['pulang']['image'] != null
                    //         ? ClipRRect(
                    //             borderRadius: BorderRadius.circular(20),
                    //             child: SizedBox(
                    //               width: double.infinity,
                    //               child: Image.network(
                    //                 getUserHistory['pulang']['image'],
                    //                 fit: BoxFit.cover,
                    //               ),
                    //             ),
                    //           )
                    //         : SizedBox(),
                    //   ],
                    // ),
                  ],
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ));
  }
}

class PresenceDetailBox extends StatelessWidget {
  const PresenceDetailBox({
    super.key,
    required this.getUserHistory,
    required this.boxColor,
    required this.middleText,
    required this.presenceType,
    required this.title,
  });

  final Map<String, dynamic> getUserHistory;
  final String title;
  final String middleText;
  final String presenceType;
  final Color boxColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: RText(
              text: title,
              textStyle: interSemiBold,
              fontSize: 10.0,
            ),
          ),
        ),
        SizedBox(height: 20),
        Row(
          children: [
            RText(text: middleText, textStyle: interRegular),
            Spacer(),
            RText(
              text:
                  "${DateFormat('hh:mm a').format(DateTime.parse(getUserHistory[presenceType]['datetime']))}",
              textStyle: interSemiBold,
              fontSize: 12.0,
            ),
          ],
        ),
        SizedBox(height: 14),
        Row(
          children: [
            RText(text: "Device.", textStyle: interRegular),
            Spacer(),
            RText(
              text: getUserHistory[presenceType]['device'] != null
                  ? getUserHistory[presenceType]['device']
                  : "NO DEVICE",
              textStyle: interSemiBold,
              fontSize: 12.0,
            ),
            // RText(
            //   text: getUserHistory[presenceType]['inArea'] ? "In Area" : "Out of Area.",
            //   textStyle: interSemiBold,
            //   color: getUserHistory[presenceType]['inArea'] ? greenColor : redColor,
            // ),
          ],
        ),
        SizedBox(height: 14),
        SizedBox(
          width: Get.width,
          child: RText(
            text: "Location.",
            textStyle: interRegular,
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(
          width: Get.width,
          child: RText(
            text: getUserHistory[presenceType]['address'],
            textStyle: interSemiBold,
            textAlign: TextAlign.start,
            fontSize: 12.0,
          ),
        ),
        SizedBox(height: 14),
        SizedBox(
          width: Get.width,
          child: RText(
            text: "Photo.",
            textStyle: interRegular,
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(height: 6),
        getUserHistory[presenceType]['image'] != null
            ? InkWell(
                highlightColor: redColor,
                onTap: () => Get.dialog(
                  Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IntrinsicHeight(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: getUserHistory[presenceType]['image'],
                          progressIndicatorBuilder: (context, url, progress) {
                            return Center(
                              child: CircularProgressIndicator(
                                value: progress.progress,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    width: Get.width,
                    height: Get.height * .3,
                    imageUrl: getUserHistory[presenceType]['image'],
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, progress) {
                      return Center(
                        child: CircularProgressIndicator(
                          value: progress.progress,
                        ),
                      );
                    },
                    errorWidget: (context, url, error) => RText(
                      text: "Failed to Load Image.",
                      textStyle: interMedium,
                      color: redColor,
                    ),
                  ),
                ),
              )
            : RText(
                text: "No Photo Found.",
                textStyle: interMedium,
                color: redColor,
              ),
      ],
    );
  }
}
