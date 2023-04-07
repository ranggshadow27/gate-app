import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/controllers/page_setup_controller.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  final pageController = Get.find<PageSetupController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomeView'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(35),
        children: [
          Column(
            children: [
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: controller.getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData) {
                    return Center(
                      child: Text("Tidak ada data ditemukan"),
                    );
                  }

                  Map<String, dynamic> userData = snapshot.data!.data()!;

                  String defaultAvatar =
                      "https://ui-avatars.com/api/?name=${userData['fullname']}";

                  return Column(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: Image.network(
                            userData['avatar'] != null
                                ? '${userData['avatar']}'
                                : defaultAvatar,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '${userData["fullname"]}',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        'Email: ${userData["email"]}',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        'Jabatan: ${userData["grade"]}',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        userData['address'] != null
                            ? 'Posisi: ${userData["address"]}'
                            : 'Posisi : Belum ada Lokasi',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 40),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: () => Get.toNamed(Routes.ADD_USER),
                          child: Icon(Icons.add),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: () => Get.toNamed(Routes.USER_PROFILE),
                          child: Icon(Icons.person),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 40),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: controller.getUserTodayPresence(),
                  builder: (context, snapshotTodayPresence) {
                    if (snapshotTodayPresence.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    Map<String, dynamic>? getTodayData =
                        snapshotTodayPresence.data?.data();

                    return Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color.fromARGB(255, 226, 226, 226),
                          ),
                          width: MediaQuery.of(context).size.width * .38,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Masuk"),
                              Text(getTodayData?['masuk'] == null
                                  ? "-"
                                  : DateFormat("hh:mm a").format(DateTime.parse(
                                      getTodayData!['masuk']['datetime']))),
                            ],
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color.fromARGB(255, 226, 226, 226),
                          ),
                          width: MediaQuery.of(context).size.width * .38,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Pulang"),
                              Text(getTodayData?['pulang'] == null
                                  ? "-"
                                  : DateFormat("hh:mm a").format(DateTime.parse(
                                      getTodayData!['pulang']['datetime']))),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
              SizedBox(height: 40),
              TextButton(
                onPressed: () => Get.toNamed(
                  Routes.PRESENCE_HISTORY_DETAILS,
                ),
                child: Text("Last Presence."),
              ),
              SizedBox(height: 20),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: controller.getUserHistoryPresence(),
                  builder: (context, snapshotHistory) {
                    if (snapshotHistory.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: Text("Memuat data.."));
                    }

                    if (snapshotHistory.data?.docs.length == 0 ||
                        snapshotHistory.data == null) {
                      return Center(child: Text("Belum ada History absensi"));
                    }

                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshotHistory.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> getHistoryData =
                            snapshotHistory.data!.docs[index].data();

                        String formattedDate = DateFormat("dd, MMMM yyyy")
                            .format(DateTime.parse(getHistoryData['date']));

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Material(
                            borderRadius: BorderRadius.circular(20),
                            color: Color.fromARGB(255, 242, 242, 242),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => Get.toNamed(
                                Routes.PRESENCE_DETAILS,
                                arguments: getHistoryData,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  vertical: 30,
                                  horizontal: 30,
                                ),
                                child: Column(
                                  children: [
                                    Text("$formattedDate"),
                                    SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Masuk"),
                                            SizedBox(height: 4),
                                            PresenceText(
                                              getHistoryData: getHistoryData,
                                              presence: 'masuk',
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text("Pulang"),
                                            SizedBox(height: 4),
                                            PresenceText(
                                              getHistoryData: getHistoryData,
                                              presence: 'pulang',
                                            ),
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
                  }),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => BottomBarCreative(
          items: [
            TabItem(
              icon: Icons.home,
            ),
            TabItem(
              icon: pageController.isLoading.isFalse
                  ? Icons.favorite_border
                  : Icons.waving_hand,
            ),
            TabItem(
              icon: Icons.account_box,
            ),
          ],
          iconSize: 30,

          backgroundColor: Colors.green.withOpacity(0.21),
          color: Colors.red,
          colorSelected: Colors.white,
          indexSelected: pageController.initialPage.value,
          // isFloating: true,
          highlightStyle: const HighlightStyle(
            sizeLarge: true,
            background: Colors.red,
            elevation: 3,
            isHexagon: true,
          ),
          onTap: (int index) => pageController.visitPage(index),
        ),
      ),
    );
  }
}

class PresenceText extends StatelessWidget {
  const PresenceText({
    Key? key,
    required this.getHistoryData,
    required this.presence,
  }) : super(key: key);

  final Map<String, dynamic> getHistoryData;
  final String presence;

  @override
  Widget build(BuildContext context) {
    return Text(
      getHistoryData[presence]?['datetime'] == "" ||
              getHistoryData[presence]?['datetime'] == null
          ? "-"
          : DateFormat("hh:mm a")
              .format(DateTime.parse(getHistoryData[presence]!['datetime'])),
    );
  }
}
