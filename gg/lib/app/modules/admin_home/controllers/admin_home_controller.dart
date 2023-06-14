import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AdminHomeController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> getAdminData() async* {
    String uid = auth.currentUser!.uid;

    yield* firestore.collection('users').doc(uid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamDispensation() async* {
    yield* firestore
        .collection('dispensation_data')
        .orderBy('createdDate', descending: true)
        .limit(10)
        .snapshots();
  }
}
