import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/dispensation_details_controller.dart';

class DispensationDetailsView extends GetView<DispensationDetailsController> {
  final Map<String, dynamic> data = Get.arguments;
  @override
  Widget build(BuildContext context) {
    String dateF = DateFormat("EEEE, dd-MM-yyyy")
        .format(DateTime.parse(data['createdDate']));
    return Scaffold(
      appBar: AppBar(
        title: Text('DispensationDetailsView'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          buildText("Subject:"),
          buildText("${data['subject']}"),
          SizedBox(height: 10),
          Text("Type:"),
          Text("${data['type']}"),
          SizedBox(height: 10),
          buildText("Description:"),
          buildText("${data['description']}"),
          SizedBox(height: 10),
          Text("Created Date:"),
          Text("${dateF}, \nby: ${data['createdBy']}"),
          SizedBox(height: 20),
          data['images'] != null
              ? buildImageWidget("${data['images']}", context)
              : Text(
                  "Tidak ada gambar",
                ),
        ],
      ),
    );
  }
}

Widget buildText(String text) {
  return Text(text);
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

      return Image.network(imageUrl); //
    },
  );
}

Widget buildLoadingWidget() {
  return Center(
    child: Column(
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 10),
        Text("Loading Images.."),
      ],
    ),
  );
}
