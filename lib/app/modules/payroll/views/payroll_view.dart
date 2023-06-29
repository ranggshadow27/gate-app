import 'package:flutter/material.dart';
import 'package:gate/app/components/colors.dart';
import 'package:gate/app/components/fonts.dart';
import 'package:gate/app/components/widgets/appbar.dart';
import 'package:gate/app/components/widgets/custom_icon.dart';
import 'package:gate/app/components/widgets/custom_snackbar.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:uicons/uicons.dart';

import '../../../components/widgets/text_widget.dart';
import '../controllers/payroll_controller.dart';

class PayrollView extends GetView<PayrollController> {
  final controller = Get.put(PayrollController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            RAppBar(onPressed: () => Get.back(), title: "Payroll"),
            SizedBox(height: 10),
            Center(
              child: RText(
                text: "Please select a Date:",
                textStyle: interMedium,
              ),
            ),
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
                                Get.showSnackbar(buildSnackError("Please pick the last date"));
                              }
                            } else {
                              Get.showSnackbar(buildSnackError("Please pick the start date"));
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
                child: RIcon(icon: UIcons.regularRounded.calendar),
                style: ElevatedButton.styleFrom(backgroundColor: greenColor),
              ),
            ),
            SizedBox(height: 10),
            Divider(),
            Obx(
              () {
                if (controller.dataPresence.isEmpty) {
                  return Center(
                    child: RText(
                      text: "No Data.",
                      textStyle: interMedium,
                    ),
                  );
                }

                var lembur = 206000;

                Map<String, dynamic> userInfo = controller.userInfo!;
                Map<String, dynamic> userSalary = controller.userSalary!;

                String formatCurr(int number) {
                  var formatcurr =
                      NumberFormat.currency(locale: 'id_ID', symbol: "Rp. ").format(number);

                  return formatcurr;
                }

                String totalWangMakan =
                    formatCurr(userSalary['daily'] * controller.dataPresence.length);

                print(userInfo['fullname']);

                int totalLembur = (lembur * controller.dataOvertime.length);

                int totalPotongan = userSalary['bpjs'] + userSalary['bpjsk'];

                String takeHomePay = formatCurr(userSalary['main'] +
                    userSalary['allowance'] +
                    (userSalary['daily'] * controller.dataPresence.length) +
                    totalLembur -
                    totalPotongan);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: RText(text: "Salary Info.", textStyle: interMedium)),
                    SizedBox(height: 10),
                    buildTextData(
                      userInfo,
                      "User.",
                      "${userInfo['nip']}. ${userInfo['fullname']}",
                    ),
                    SizedBox(height: 10),
                    buildTextData(
                      userSalary,
                      "Main Salary.",
                      formatCurr(userSalary['main']),
                    ),
                    SizedBox(height: 10),
                    buildTextData(
                      userSalary,
                      "Allowance.",
                      formatCurr(userSalary['allowance']),
                    ),
                    SizedBox(height: 10),
                    buildTextData(
                      userSalary,
                      "Daily Salary.",
                      formatCurr(userSalary['daily']),
                    ),
                    SizedBox(height: 10),
                    buildTextData(
                        userSalary, "Presence Total.", "${controller.dataPresence.length} Day(s)"),
                    SizedBox(height: 10),
                    buildTextData(
                      userSalary,
                      "Daily Salary Total.",
                      totalWangMakan,
                    ),
                    Divider(color: whiteColor),
                    Center(child: RText(text: "Overtime Info.", textStyle: interMedium)),
                    SizedBox(height: 20),
                    buildTextData(
                      userSalary,
                      "Overtime Total.",
                      controller.dataOvertime.length == 0
                          ? "-"
                          : "${controller.dataOvertime.length} Day(s)",
                    ),
                    SizedBox(height: 10),
                    buildTextData(
                      userSalary,
                      "Overtime Salary.",
                      controller.dataOvertime.length == 0 ? "-" : formatCurr(totalLembur),
                    ),
                    Divider(color: whiteColor),
                    buildTextData(
                      userSalary,
                      "BPJS.",
                      formatCurr(userSalary['bpjs']),
                    ),
                    SizedBox(height: 10),
                    buildTextData(
                        userSalary, "BPJS Ketenagakerjaan.", formatCurr(userSalary['bpjsk'])),
                    Divider(color: whiteColor),
                    SizedBox(height: 10),
                    Center(child: RText(text: "Take Home Pay.", textStyle: interMedium)),
                    Center(
                      child: RText(
                        text: takeHomePay,
                        textStyle: interMedium,
                        fontSize: 32,
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(color: whiteColor),
                    SizedBox(height: 20),
                    Center(child: RText(text: "Presence History.", textStyle: interMedium)),
                    SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: controller.dataPresence.length,
                      itemBuilder: (context, index) {
                        dateFormat(String data) {
                          String dateFormat =
                              DateFormat("EE, dd-MMM-yyyy ").format(DateTime.parse(data));

                          return dateFormat;
                        }

                        timeFormat(String data) {
                          String dateFormat = DateFormat("HH:mm a").format(DateTime.parse(data));

                          return dateFormat;
                        }

                        String? masuk = controller.dataPresence[index]['masuk']['datetime'];
                        String? pulang = controller.dataPresence[index]['pulang']?['datetime'];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                RText(
                                  text: "-> ${dateFormat(masuk!)} ",
                                  textStyle: interRegular,
                                ),
                                Spacer(),
                                RText(
                                  text: "${timeFormat(masuk)} ",
                                  textStyle: interRegular,
                                ),
                                SizedBox(width: 15),
                                RText(
                                  text:
                                      "${controller.dataPresence[index]['pulang'] != null ? timeFormat(pulang!) : "-"}",
                                  textStyle: interRegular,
                                ),
                              ],
                            ),
                            Divider(color: whiteColor.withOpacity(.4)),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 6),
                    RText(
                        text: "-> Total : ${controller.dataPresence.length} Day(s)",
                        textStyle: interMedium),
                    SizedBox(height: 40),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextData(Map<String, dynamic> userSalary, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RText(
          text: title,
          textStyle: interRegular,
        ),
        RText(
          text: value,
          textStyle: interMedium,
          fontSize: 16.0,
        ),
      ],
    );
  }
}
