import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserProfileController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  RxBool showSalaryInfo = false.obs;

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserData() async* {
    String uid = auth.currentUser!.uid;

    yield* firestore.collection('users').doc(uid).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getSalaryData() async {
    String uid = auth.currentUser!.uid;

    return await firestore.collection('salary').doc(uid).get();
  }
}
