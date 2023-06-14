import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class DispensationController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamDispensationData() async* {
    yield* await firestore
        .collection('dispensation_data')
        .where('userUid', isEqualTo: auth.currentUser!.uid)
        .orderBy('createdDate', descending: true)
        .snapshots();
  }
}
