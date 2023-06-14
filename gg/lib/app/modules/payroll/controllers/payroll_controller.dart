import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class PayrollController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? startDate;
  String endDate = DateTime.now().toIso8601String();

  Map<String, dynamic>? userSalary;
  var dataPresence = [].obs;
  var dataOvertime = [].obs;

  void datePicker({
    required DateTime getStartDate,
    required DateTime getEndDate,
  }) {
    startDate = getStartDate.toIso8601String();
    endDate = getEndDate
        .add(Duration(hours: 23, minutes: 59, seconds: 59))
        .toIso8601String();
  }

  Future<Map<String, dynamic>?> getUserSalary() async {
    String uid = auth.currentUser!.uid;

    Map<String, dynamic>? userSalary;

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
    Get.snackbar('Gas', "datanya ada --------> ${dataPresence.length}");
  }

  Future<void> getUserPayroll() async {
    userSalary = await getUserSalary();
    await getUserPresence();
  }
}
