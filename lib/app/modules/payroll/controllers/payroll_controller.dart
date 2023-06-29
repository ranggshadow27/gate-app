import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gate/app/components/widgets/custom_snackbar.dart';
import 'package:get/get.dart';

class PayrollController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? startDate;
  String endDate = DateTime.now().toIso8601String();

  Map<String, dynamic>? userInfo;
  Map<String, dynamic>? userSalary;
  var dataPresence = [].obs;
  var dataOvertime = [].obs;

  void datePicker({
    required DateTime getStartDate,
    required DateTime getEndDate,
  }) {
    startDate = getStartDate.toIso8601String();
    endDate = getEndDate.add(Duration(hours: 23, minutes: 59, seconds: 59)).toIso8601String();
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    String uid = auth.currentUser!.uid;

    userInfo = await firestore.collection('users').doc(uid).get().then((value) => value.data());

    print(userInfo);
    return userInfo;
  }

  Future<Map<String, dynamic>?> getUserSalary() async {
    String uid = auth.currentUser!.uid;

    DocumentSnapshot<Map<String, dynamic>> snapshotSalary =
        await firestore.collection('salary').doc(uid).get();

    userSalary = snapshotSalary.data();

    return userSalary;
  }

  Future<void> getUserPresence() async {
    String uid = auth.currentUser!.uid;

    QuerySnapshot<Map<String, dynamic>> snapshotPresence = await firestore
        .collection('users')
        .doc(uid)
        .collection('presence')
        .where("date", isGreaterThan: startDate)
        .where("date", isLessThan: endDate)
        .orderBy("date", descending: true)
        .get();

    QuerySnapshot<Map<String, dynamic>> snapshotOvertime = await firestore
        .collection('users')
        .doc(uid)
        .collection('overtime')
        .where("date", isGreaterThan: startDate)
        .where("date", isLessThan: endDate)
        .orderBy("date", descending: true)
        .get();

    dataPresence.value = snapshotPresence.docs.map((e) => e.data()).toList();
    dataOvertime.value = snapshotOvertime.docs.map((e) => e.data()).toList();

    Get.back();
    Get.showSnackbar(
      buildSnackSuccess("Data generated successfully, Here is your possible salary"),
    );
  }

  Future<void> getUserPayroll() async {
    userSalary = await getUserSalary();
    userInfo = await getUserInfo();
    await getUserPresence();
  }
}
