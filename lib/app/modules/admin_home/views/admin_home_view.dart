import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/routes/app_pages.dart';

import 'package:get/get.dart';

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
        padding: EdgeInsets.all(35),
        children: [
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: controller.getAdminData(),
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
                  Divider(),
                  SizedBox(height: 30),
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
                ],
              );
            },
          )
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
