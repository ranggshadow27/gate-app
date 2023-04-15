import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AdminViewUsersController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> getAllUser() async {
    return await firestore.collection('users').get();
  }
}
