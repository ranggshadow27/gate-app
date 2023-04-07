import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/presence_details_controller.dart';

class PresenceDetailsView extends GetView<PresenceDetailsController> {
  Map<String, dynamic> getUserHistory = Get.arguments;

  @override
  Widget build(BuildContext context) {
    String date = DateFormat('EEEE, dd MMMM yyyy')
        .format(DateTime.parse(getUserHistory['date']));

    String presenceIn = DateFormat('HH:mm:ss a')
        .format(DateTime.parse(getUserHistory['masuk']['datetime']));

    return Scaffold(
        appBar: AppBar(
          title: Text('PresenceDetailsView'),
          centerTitle: true,
        ),
        body: ListView(
          padding: EdgeInsets.all(35),
          children: [
            Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey[200],
              ),
              child: Column(
                children: [
                  Text("${date}"),
                  Divider(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(""),
                      Text(""),
                      Text("Masuk: ${presenceIn}"),
                      Text(
                        "${getUserHistory['masuk']['address']}",
                        textAlign: TextAlign.center,
                      ),
                      Text("Lat: ${getUserHistory['masuk']['latitude']}"),
                      Text("Long: ${getUserHistory['masuk']['longitude']}"),
                      Text(
                        getUserHistory['masuk']['inArea'] == true
                            ? "Didalam Area"
                            : "Diluar Area",
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(""),
                      Text(""),
                      Text(
                        getUserHistory['pulang'] != null
                            ? "Pulang: ${DateFormat('hh:mm:ss a').format(DateTime.parse(getUserHistory['pulang']['datetime']))}"
                            : "-",
                      ),
                      Text(
                        getUserHistory['pulang'] != null
                            ? "${getUserHistory['masuk']['address']}"
                            : "-",
                        textAlign: TextAlign.center,
                      ),
                      Text(getUserHistory['pulang'] != null
                          ? "Lat: ${getUserHistory['masuk']['latitude']}"
                          : "-"),
                      Text(getUserHistory['pulang'] != null
                          ? "Long: ${getUserHistory['masuk']['longitude']}"
                          : "-"),
                      Text(
                        getUserHistory['pulang'] != null
                            ? getUserHistory['pulang']['datetime'] == true
                                ? "Didalam Area"
                                : "Diluar Area"
                            : "-",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
