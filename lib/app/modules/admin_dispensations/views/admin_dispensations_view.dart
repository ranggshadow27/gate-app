import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/appbar.dart';
import 'package:gate/app/components/widgets/text_widget.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uicons/uicons.dart';

import '../../../components/widgets/custom_icon.dart';
import '../../../routes/app_pages.dart';
import '../controllers/admin_dispensations_controller.dart';

class AdminDispensationsView extends GetView<AdminDispensationsController> {
  const AdminDispensationsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            RAppBar(onPressed: () => Get.back(), title: "Dispensation Data"),
            SizedBox(height: 10),
            FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: controller.getDispensationData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data?.docs.length == 0) {
                  return Center(
                    child: RText(
                      text: "No Dispensation Data Found.",
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
                    Map<String, dynamic> dispensationData = snapshot.data!.docs[index].data();

                    String dateF = DateFormat("EEEE, dd MMMM yyyy")
                        .format(DateTime.parse(dispensationData['createdDate']));

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
                            arguments: dispensationData,
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
                                    RText(
                                        text: dispensationData['subject'], textStyle: interRegular),
                                    SizedBox(height: 4),
                                    RText(
                                      fontSize: 12.0,
                                      textStyle: interMedium,
                                      color: whiteColor.withOpacity(.8),
                                      text: dispensationData['createdBy'].toString().toUpperCase(),
                                    ),
                                  ],
                                ),
                                Spacer(),
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
            ),
          ],
        ),
      ),
    );
  }
}
