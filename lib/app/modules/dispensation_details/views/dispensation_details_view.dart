import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/appbar.dart';
import 'package:gate/app/components/widgets/text_widget.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../components/widgets/loading_widget.dart';
import '../controllers/dispensation_details_controller.dart';

class DispensationDetailsView extends GetView<DispensationDetailsController> {
  final Map<String, dynamic> data = Get.arguments;

  @override
  Widget build(BuildContext context) {
    String dateF = DateFormat("EEEE, dd-MM-yyyy").format(DateTime.parse(data['createdDate']));

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            RAppBar(onPressed: () => Get.back(), title: "Dispensation Details"),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RText(
                    text: "Subject.",
                    textStyle: interRegular,
                    fontSize: 12.0,
                  ),
                  RText(
                    text: "${data['subject']}",
                    textStyle: interMedium,
                    fontSize: 16.0,
                  ),
                  SizedBox(height: 20),
                  RText(
                    text: "Type.",
                    textStyle: interRegular,
                    fontSize: 12.0,
                  ),
                  RText(
                    text: "${data['type']}",
                    textStyle: interMedium,
                    fontSize: 16.0,
                  ),
                  SizedBox(height: 20),
                  RText(
                    text: "Description.",
                    textStyle: interRegular,
                    fontSize: 12.0,
                  ),
                  RText(
                    text: "${data['description']}",
                    textStyle: interMedium,
                    fontSize: 16.0,
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 20),
                  RText(
                    text: "Created Date.",
                    textStyle: interRegular,
                    fontSize: 12.0,
                  ),
                  RText(
                    text: "${dateF}",
                    textStyle: interMedium,
                    fontSize: 16.0,
                  ),
                  SizedBox(height: 20),
                  RText(
                    text: "By.",
                    textStyle: interRegular,
                    fontSize: 12.0,
                  ),
                  RText(
                    text: "${data['createdBy']}",
                    textStyle: interMedium,
                    fontSize: 16.0,
                  ),
                  SizedBox(height: 20),
                  data['images'] != null
                      ? buildImageWidget("${data['images']}", context)
                      : RText(
                          text: "No Image.",
                          textStyle: interMedium,
                          color: redColor,
                        ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

Widget buildImageWidget(String imageUrl, BuildContext context) {
  return FutureBuilder(
    future: precacheImage(NetworkImage(imageUrl), context),
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return buildLoadingWidget(); // Tampilkan loading widget saat sedang memuat
      }

      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(imageUrl),
      ); //
    },
  );
}

Widget buildLoadingWidget() {
  return Center(
    child: Column(
      children: [
        RLoading(),
        SizedBox(height: 10),
        RText(
          text: "Loading Image..",
          textStyle: interRegular,
        ),
      ],
    ),
  );
}
