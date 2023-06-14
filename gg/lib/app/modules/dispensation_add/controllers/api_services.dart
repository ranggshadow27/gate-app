import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fs;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ApiService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  fs.FirebaseStorage _storage = fs.FirebaseStorage.instance;

  Future<String> getCurrentUserUid() async {
    return await _auth.currentUser!.uid;
  }

  getCurrentUser() async {
    String uid = await getCurrentUserUid();

    var getData = await _firestore.collection('users').doc(uid).get();
    Map<String, dynamic>? data = getData.data();

    return data!['fullname'];
  }

  String getDateId(String date) {
    DateTime getDate = DateTime.parse(date);
    String dateId = DateFormat("yyyy-MM-dd").format(getDate);

    return dateId;
  }

  submitDispensation({
    required String type,
    required String subject,
    required String description,
    required String dateTime,
    XFile? imageFile,
  }) async {
    String uid = await getCurrentUserUid();
    // String dateId = getDateId(dateTime);
    String userName = await getCurrentUser();

    Map<String, dynamic> inputData = {
      'userUid': uid,
      'createdBy': userName,
      'type': type,
      'subject': subject,
      'description': description,
      'createdDate': dateTime,
    };

    if (imageFile != null) {
      await submitImage(imageFile, uid, dateTime, userName, inputData);
    }
    await _firestore.collection('dispensation_data').doc().set(inputData);
  }

  submitImage(
      XFile image, String uid, String date, String userName, inputData) async {
    String dateId = getDateId(date);

    fs.Reference ref = _storage
        .ref('user_dispensation/$uid/$dateId/${userName}_${image.name}');

    await ref.putFile(File(image.path));
    String getImageUrl = await ref.getDownloadURL();

    inputData.addAll({'images': getImageUrl});
  }
}
