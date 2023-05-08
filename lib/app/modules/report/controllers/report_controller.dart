import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ReportController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  TextEditingController searchTextC = TextEditingController();

  RxString filterByCategory = "".obs;
  RxBool isDescending = true.obs;

  String? startDate;
  String endDate = DateTime.now()
      .add(Duration(hours: 23, minutes: 59, seconds: 59))
      .toIso8601String();

  Stream<QuerySnapshot<Map<String, dynamic>>> getReportDatas() async* {
    if (startDate == null) {
      if (filterByCategory.isEmpty || filterByCategory == "Show All") {
        yield* await firestore
            .collection('operational_report')
            .where('createdAt', isLessThan: endDate)
            .orderBy('createdAt', descending: isDescending.value)
            .snapshots();
      } else {
        yield* await firestore
            .collection('operational_report')
            .where('createdAt', isLessThan: endDate)
            .where('category', isEqualTo: filterByCategory.value)
            .orderBy('createdAt', descending: isDescending.value)
            .snapshots();
      }
    } else {
      if (filterByCategory.isEmpty || filterByCategory == "Show All") {
        yield* await firestore
            .collection('operational_report')
            .where('createdAt', isGreaterThan: startDate)
            .where('createdAt', isLessThan: endDate)
            .orderBy('createdAt', descending: isDescending.value)
            .snapshots();
      } else {
        yield* await firestore
            .collection('operational_report')
            .where('createdAt', isGreaterThan: startDate)
            .where('createdAt', isLessThan: endDate)
            .where('category', isEqualTo: filterByCategory.value)
            .orderBy('createdAt', descending: isDescending.value)
            .snapshots();
      }
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCategory() async {
    return await firestore.collection('report_category').doc('category').get();
  }

  void pickerDate(DateTime pickStartDate, DateTime pickEndDate) {
    startDate = pickStartDate.toIso8601String();
    endDate = pickEndDate
        .add(Duration(hours: 23, minutes: 59, seconds: 59))
        .toIso8601String();

    print(startDate);
    print(endDate);

    update();
  }
}
