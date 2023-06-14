import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/routes/app_pages.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/admin_home_controller.dart';

class AdminHomeView extends GetView<AdminHomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AdminHomeView'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(35),
            child: Column(
              children: [
                buildStreamAdmin(controller.getAdminData()),
                Divider(),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(Get.width, 20),
                  ),
                  onPressed: () => Get.toNamed(Routes.ADD_USER),
                  child: Icon(Icons.add),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(Get.width, 20),
                  ),
                  onPressed: () => Get.toNamed(Routes.ADMIN_VIEW_USERS),
                  child: Icon(Icons.group_rounded),
                ),
                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("User Dispensation :"),
                ),
              ],
            ),
          ),
          buildStreamDispensation(controller.streamDispensation()),
          SizedBox(height: 35),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FirebaseAuth.instance.signOut();
          Get.offAllNamed(Routes.LOGIN);
        },
      ),
    );
  }
}

Widget buildStreamAdmin(
    Stream<DocumentSnapshot<Map<String, dynamic>>>? stream) {
  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: stream,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: Text("Memuat ada akun"),
        );
      }
      if (!snapshot.hasData) {
        return Center(
          child: Text("Tidak ada data"),
        );
      }

      Map<String, dynamic>? adminData = snapshot.data!.data();

      return Column(
        children: [
          ClipOval(
            child: Container(
              width: 100,
              height: 100,
              child: Image.network(
                "${adminData?['avatar']}",
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 20),
          Text("Name : ${adminData?['fullname']}"),
          Text("Grade : ${adminData?['grade']}"),
          Text("Role : ${adminData?['role']}"),
        ],
      );
    },
  );
}

Widget buildStreamDispensation(
    Stream<QuerySnapshot<Map<String, dynamic>>>? stream) {
  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: stream,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: Text("Memuat ada akun"),
        );
      }
      if (!snapshot.hasData || snapshot.data?.docs.length == 0) {
        return Center(
          child: Text("Tidak ada data"),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> data = snapshot.data!.docs[index].data();

          String dateF = DateFormat("dd-MM-yyyy")
              .format(DateTime.parse(data['createdDate']));

          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 50, vertical: 6),
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
  );
}
