import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/report_detail_controller.dart';

class ReportDetailView extends GetView<ReportDetailController> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> reportData = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text('ReportDetailView'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Row(
            children: [
              OutlinedButton(
                onPressed: () {
                  print(controller.reportID);
                  Get.defaultDialog(
                    title: "Confirm",
                    middleText: "Hapus data report ${reportData['reportID']}?",
                    actions: [
                      OutlinedButton(
                        onPressed: () => Get.back(),
                        child: Text("Back"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.deleteReport();
                        },
                        child: Text("Delete"),
                      ),
                    ],
                  );
                },
                child: Text("Delete"),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () => Get.offNamed(
                  Routes.REPORT_UPDATE,
                  arguments: reportData,
                ),
                child: Text("Update"),
              ),
            ],
          ),
          Divider(),
          Text("Incident ID : "),
          Text("${reportData['reportID']}"),
          Divider(),
          SizedBox(height: 6),
          Text("Subject : "),
          Text("${reportData['subject']}"),
          SizedBox(height: 6),
          Text("Type : "),
          Text("${reportData['type']}"),
          SizedBox(height: 6),
          Text("Category : "),
          Text("${reportData['category']}"),
          SizedBox(height: 6),
          SizedBox(height: 6),
          Divider(),
          SizedBox(height: 6),
          Text("${reportData['description']}"),
          SizedBox(height: 6),
          Divider(),
          Text("Images : "),
          reportData['images'] != null
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: reportData['images'].length,
                  itemBuilder: (context, index) {
                    final String imageName =
                        reportData['images'][index]['name'];
                    final String imageUrl = reportData['images'][index]['url'];

                    return Column(
                      children: [
                        SizedBox(
                          width: Get.width,
                          height: 200,
                          child: Image.network(
                            reportData['images'][index]['url'],
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: Get.width * .7,
                              child: Obx(
                                () => InkWell(
                                  onTap: () {
                                    if (controller.isLoading.isFalse) {
                                      Get.dialog(
                                        Dialog(
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CircularProgressIndicator(),
                                                SizedBox(height: 10),
                                                Text(
                                                  "Downloading $imageName ..",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                      controller.downloadImage(
                                          imageUrl, imageName);
                                    } else {
                                      SizedBox();
                                    }
                                  },
                                  child: Text(
                                    "${reportData['images'][index]['name']}",
                                    overflow: controller.isLoading.isTrue
                                        ? TextOverflow.ellipsis
                                        : TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                      ],
                    );
                  },
                )
              : Text("-"),
          // Text("Length : ${reportData['images'].length}"),
          Text("created at : ${reportData['createdAt']}"),
          Text("created by : ${reportData['createdBy']}"),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
