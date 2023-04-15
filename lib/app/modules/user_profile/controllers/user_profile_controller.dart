import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserProfileController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  RxBool showSalaryInfo = false.obs;

  Map<String, dynamic>? salaryData;

  void onInit() {
    super.onInit();
    getSalaryData();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserData() async* {
    String uid = auth.currentUser!.uid;

    yield* firestore.collection('users').doc(uid).snapshots();
  }

  Future<Map<String, dynamic>> getSalaryData() async {
    String uid = auth.currentUser!.uid;

    DocumentSnapshot<Map<String, dynamic>> salaryInfo =
        await firestore.collection('salary').doc(uid).get();

    return salaryData = salaryInfo.data()!;
  }
}
