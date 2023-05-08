import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gate/app/controllers/page_setup_controller.dart';

import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Permission.storage.request();

  Map<String, dynamic>? userRole = await userCheck();
  final pageController = Get.put(PageSetupController(), permanent: true);

  runApp(
    StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        User? userLogin = snapshot.data;

        print(userLogin);
        return GetMaterialApp(
          title: "Gate App",
          initialRoute: userLogin != null
              ? (userRole?['role']) == "administrator"
                  ? Routes.ADMIN_HOME
                  : Routes.HOME
              : Routes.LOGIN,
          getPages: AppPages.routes,
        );
      },
    ),
  );
}

Future userCheck() async {
  String? uid;

  if (FirebaseAuth.instance.currentUser == null) {
    uid = null;
  } else {
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  DocumentSnapshot<Map<String, dynamic>> getUserRole =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

  return getUserRole.data();
}
