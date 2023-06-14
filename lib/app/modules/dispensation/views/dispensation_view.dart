import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/routes/app_pages.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/dispensation_controller.dart';

class DispensationView extends GetView<DispensationController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DispensationView'),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            ListView(
              children: [
                Container(
                  padding: EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("This is your Dispensation Data : "),
                    ],
                  ),
                ),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: controller.streamDispensationData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: Text("Sedang memuat data.."));
                    }

                    if (!snapshot.hasData || snapshot.data?.docs == null) {
                      return Center(
                          child: Text("Data dispensasi tidak ditemukan"));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data =
                            snapshot.data!.docs[index].data();

                        String dateF = DateFormat("dd-MM-yyyy")
                            .format(DateTime.parse(data['createdDate']));

                        return ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 6),
                          title: Text("${data['subject']}"),
                          subtitle: Text(dateF),
                          trailing: Icon(Icons.chevron_right),
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
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(Routes.DISPENSATION_ADD),
                child: Text("Add New Dispensation"),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(double.infinity, 60),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.DISPENSATION_ADD),
        child: Icon(Icons.add),
      ),
    );
  }
}
