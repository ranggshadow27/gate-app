import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/admin_view_users_controller.dart';

class AdminViewUsersView extends GetView<AdminViewUsersController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AdminViewUsersView'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(30),
        children: [
          Column(
            children: [
              GetBuilder<AdminViewUsersController>(
                builder: (c) =>
                    FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: controller.getAllUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData) {
                      return Center(
                        child: Text("Tidak ada /t datanya coy"),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> usersData =
                            snapshot.data!.docs[index].data();

                        String defaultAvatar =
                            "https://ui-avatars.com/api/?name=${usersData['fullname']}";

                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Material(
                            color: Colors.amber[200],
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              onTap: () => Get.toNamed(
                                Routes.ADMIN_MANAGE_USERS,
                                arguments: usersData,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: EdgeInsets.all(20),
                                width: Get.width,
                                height: Get.height * 0.2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        ClipOval(
                                          child: Container(
                                            height: 40,
                                            width: 40,
                                            child: Image.network(
                                              usersData['avatar'] != null
                                                  ? "${usersData['avatar']}"
                                                  : defaultAvatar,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Thisis /t Text"),
                                            Text(
                                              "${usersData['fullname']}",
                                            ),
                                            Text(
                                                "Grade : ${usersData['grade']}"),
                                            // Text("Grade : ${usersData['uid']}"),
                                          ],
                                        ),
                                      ],
                                    ),
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
