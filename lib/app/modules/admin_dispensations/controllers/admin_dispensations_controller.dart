import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminDispensationsController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> getDispensationData() async {
    return await firestore.collection('dispensation_data').get();
  }
}
