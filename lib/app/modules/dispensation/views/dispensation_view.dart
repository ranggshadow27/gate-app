import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/appbar.dart';
import 'package:gate/app/components/widgets/custom_icon.dart';
import 'package:gate/app/routes/app_pages.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uicons/uicons.dart';

import '../../../components/widgets/text_widget.dart';
import '../controllers/dispensation_controller.dart';

class DispensationView extends GetView<DispensationController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: RAppBar(onPressed: () => Get.back(), title: "Dispensation"),
            ),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: controller.streamDispensationData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data?.docs.length == 0) {
                  return Center(
                    child: RText(
                      text: "Dispensation data not found.",
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
                        DateFormat("dd-MM-yyyy").format(DateTime.parse(data['createdDate']));

                    return ListTile(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: borderColor,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 2),
                      tileColor: darkColor,
                      title: RText(
                        text: "${data['subject']}",
                        textStyle: interMedium,
                        textAlign: TextAlign.start,
                      ),
                      subtitle: RText(
                        text: dateF,
                        textStyle: interRegular,
                        textAlign: TextAlign.start,
                        color: whiteColor.withOpacity(.6),
                      ),
                      trailing: RIcon(
                        icon: UIcons.boldRounded.angle_right,
                        size: 12,
                      ),
                      onTap: () => Get.toNamed(
                        Routes.DISPENSATION_DETAILS,
                        arguments: data,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: greenColor,
        onPressed: () => Get.toNamed(Routes.DISPENSATION_ADD),
        child: RIcon(icon: UIcons.regularRounded.plus),
      ),
    );
  }
}
