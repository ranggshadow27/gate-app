import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../controllers/payroll_controller.dart';

class PayrollView extends GetView<PayrollController> {
  final controller = Get.put(PayrollController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PayrollView'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SizedBox(height: 30),
          Center(child: Text("Please select a Date:")),
          SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              onPressed: () {
                Get.dialog(
                  Dialog(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      height: 400,
                      child: SfDateRangePicker(
                        selectionMode: DateRangePickerSelectionMode.range,
                        monthViewSettings: DateRangePickerMonthViewSettings(
                          firstDayOfWeek: 1,
                        ),
                        showActionButtons: true,
                        onCancel: () => Get.back(),
                        onSubmit: (date) async {
                          if (date != null) {
                            if ((date as PickerDateRange).endDate != null) {
                              controller.datePicker(
                                getStartDate: date.startDate!,
                                getEndDate: date.endDate!,
                              );
                              await controller.getUserPayroll();
                            } else {
                              Get.snackbar(
                                  "Error", "Mohon pilih tanggal akhir");
                            }
                          } else {
                            Get.snackbar("Error", "Mohon pilih tanggal mulai");
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
              child: Icon(Icons.date_range_rounded),
            ),
          ),
          SizedBox(height: 10),
          Divider(),
          Obx(
            () {
              if (controller.dataPresence.isEmpty) {
                return Center(child: Text("Tidak ada data yang dapat dimuat."));
              }

              Map<String, dynamic> userSalary = controller.userSalary!;

              int totalWangMakan =
                  userSalary['daily'] * controller.dataPresence.length;

              int totalLembur = (206000 * controller.dataOvertime.length);

              int totalPotongan = userSalary['bpjs'] + userSalary['bpjsk'];

              int takeHomePay = userSalary['main'] +
                  userSalary['allowance'] +
                  totalWangMakan +
                  totalLembur -
                  totalPotongan;

              return Column(
                children: [
                  Text("Gaji pokok : ${userSalary['main']}"),
                  Text(
                      "Wang makan : ${userSalary['daily']} x ${controller.dataPresence.length} hari = ${totalWangMakan}"),
                  Text("Tunjangan : ${userSalary['allowance']}"),
                  Text(
                      "Lemburan : Rp. 206.000 x ${controller.dataOvertime.length} hari = ${totalLembur}"),
                  Divider(),
                  Text("Potongan BPJS : ${userSalary['bpjs']}"),
                  Text(
                      "Potongan BPJS Ketenagakerjaan : ${userSalary['bpjsk']}"),
                  Divider(),
                  Text("Take Home Pay : Rp. ${takeHomePay}"),
                  SizedBox(height: 20),
                  Text(
                      "data absenmu berjumlah = ${controller.dataPresence.length}"),
                  SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.dataPresence.length,
                    itemBuilder: (context, index) => Center(
                      child: Text(
                          "Hari ke ${index + 1} = ${controller.dataPresence[index]['date']}"),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
