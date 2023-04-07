import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

import '../../../routes/app_pages.dart';

class AddUserController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  TextEditingController emailC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  TextEditingController gradeC = TextEditingController();
  TextEditingController fullnameC = TextEditingController();
  TextEditingController adminPassC = TextEditingController();

  RxBool isLoading = false.obs;

  Future<void> tryAddUser() async {
    if (adminPassC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        String adminEmail = auth.currentUser!.email!;

        UserCredential userCredentialAdmin =
            await auth.signInWithEmailAndPassword(
          email: adminEmail,
          password: adminPassC.text,
        );

        UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
          email: emailC.text,
          password: 'Pass@isip123',
        );

        if (userCredential.user != null) {
          String uid = userCredential.user!.uid;

          await firestore.collection('users').doc(uid).set(
            {
              "nip": nipC.text,
              "fullname": fullnameC.text,
              "email": emailC.text,
              "grade": gradeC.text,
              "createdAt": DateTime.now().toIso8601String(),
              // "role" : gradeC.text,
            },
          );
          print("Lagi logout");
          await auth.signOut();

          print("Lagi Login");
          UserCredential userCredentialAdmin =
              await auth.signInWithEmailAndPassword(
            email: adminEmail,
            password: adminPassC.text,
          );
          print("${userCredentialAdmin.user!.email}");

          Get.offAllNamed(Routes.HOME);
          Get.snackbar("Berhasil", "User berhasil ditambahkan");
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Get.snackbar(
            'Terjadi Kesalahan',
            "Password yang dimasukan terlalu lemah",
          );
        } else if (e.code == 'email-already-in-use') {
          Get.snackbar(
            'Terjadi Kesalahan',
            "Gagal menambahkan user, Email sudah digunakan",
          );
        } else if (e.code == 'wrong-password') {
          Get.snackbar('Terjadi Kesalahan', "Password salah.");
        }
      } catch (e) {
        Get.snackbar('Terjadi Kesalahan', "Gagal menambahkan user, err:${e}");
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar("Error", "Mohon isi password terlebih dahulu");
    }
  }

  void addUser() async {
    if (emailC.text.isNotEmpty &&
        nipC.text.isNotEmpty &&
        gradeC.text.isNotEmpty &&
        fullnameC.text.isNotEmpty) {
      Get.defaultDialog(
        title: "Verifikasi Admin",
        content: Column(
          children: [
            Text("Silahkan input password Admin"),
            TextField(
              controller: adminPassC,
              obscureText: true,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: "Password Admin"),
            ),
          ],
        ),
        actions: [
          Obx(
            () => ElevatedButton(
              onPressed: () async {
                if (isLoading.isFalse) {
                  await tryAddUser();
                }
              },
              child: Text(isLoading.isFalse ? "Add User" : "Loading.."),
            ),
          ),
        ],
      );
    } else {
      Get.snackbar("Terjadi Kesalahan", "Mohon isi semua field!");
    }
  }
}
