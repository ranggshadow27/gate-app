import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as f;

import 'package:get/get.dart';
import 'package:image_downloader/image_downloader.dart';

import '../../../components/widgets/custom_snackbar.dart';

class ReportDetailController extends GetxController {
  final Map<String, dynamic> reportData = Get.arguments;

  final String reportID = Get.arguments['reportID'];
  RxBool isLoading = false.obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  f.FirebaseStorage storage = f.FirebaseStorage.instance;

  void deleteReport() async {
    try {
      print(reportID);
      final f.Reference storageRef = storage.ref('report_images/$reportID');
      final f.ListResult refDatas = await storageRef.listAll();

      //delete firestorereport
      await firestore.collection('operational_report').doc(reportID).delete();

      //delete firebase storage report images;
      for (f.Reference ref in refDatas.items) {
        await ref.delete();
      }
      // await storage.ref('report_images/$reportID').delete();

      Get.back();
      Get.back();
      Get.showSnackbar(buildSnackSuccess("Report ID : $reportID deleted successfully"));
    } catch (e) {
      Get.showSnackbar(buildSnackError("Failed to delete report. \nerr: $e"));
    }
  }

  downloadImage(String imgURL, String imgName) async {
    try {
      isLoading.value = true;
      await ImageDownloader.downloadImage(
        imgURL,
        destination: AndroidDestinationType.directoryPictures..subDirectory('gateApp/$imgName'),
      );

      Get.back();
      Get.showSnackbar(buildSnackSuccess("$imgName downloaded"));
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}
