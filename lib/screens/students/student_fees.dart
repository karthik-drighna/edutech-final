import 'package:drighna_ed_tech/screens/students/payment_webview.dart';
import 'package:drighna_ed_tech/screens/students/student_offline_payment.dart';
import 'package:drighna_ed_tech/screens/students/student_offline_payment_lists.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/utils/date_format_converter.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentFees extends StatefulWidget {
  const StudentFees({super.key});

  @override
  _StudentFeesState createState() => _StudentFeesState();
}

class _StudentFeesState extends State<StudentFees> {
  bool isLoading = false;
  Map<String, dynamic>? feesData;
  String loginType = "student";

  @override
  void initState() {
    super.initState();
    loadFeesData();
  }

  Future<void> loadFeesData() async {
    setState(() {
      isLoading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String apiUrl = prefs.getString('apiUrl') ?? '';
    final String studentId = prefs.getString('studentId') ?? '';
    loginType = prefs.getString(Constants.loginType) ?? 'student';

    final response = await http.post(
      Uri.parse('$apiUrl${Constants.getFeesUrl}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Client-Service': Constants.clientService,
        'Auth-Key': Constants.authKey,
        'User-ID': prefs.getString('userId') ?? '',
        'Authorization': prefs.getString('accessToken') ?? '',
      },
      body: jsonEncode({
        'student_id': studentId,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        feesData = json.decode(response.body);

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load fees data'),
        ),
      );
    }
  }

  void showPaymentDialog(BuildContext context, String feesSessionId,
      String feesTypeId, String feesId, paymenttype, transfeesId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Payment Mode'),
          content: const Text('Please choose your payment mode:'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Handle online payment
                print("Online Payment selected");

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentWebView(
                      feesId: feesId,
                      feesTypeId: feesTypeId,
                      paymentType: paymenttype,
                      transFeesIdList: transfeesId,
                    ),
                  ),
                );

                if (result == true) {
                  // Refresh the fees data
                  await loadFeesData();
                }
              },
              child: const Text('Online Payment'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OfflinePaymentScreen(
                      feesSessionId: feesSessionId,
                      feesTypeId: feesTypeId,
                      feesId: feesId,
                      paymenttype: paymenttype,
                      transfeesId: transfeesId,
                    ),
                  ),
                );
                // Handle offline payment
                print("Offline Payment selected");
              },
              child: Text('Offline Payment'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.student_fees,
      ),
      body: isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : feesData != null
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        buildGrandTotal(),
                        ...buildFeesDetailsList(feesData!),
                        buildTransportFeesSection(feesData!)
                      ],
                    ),
                  ),
                )
              : const Center(
                  child: Text('No fees data available.'),
                ),
    );
  }

  Widget buildGrandTotal() {
    var grandFee = feesData?['grand_fee'];
    if (grandFee == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentOfflinePaymentList(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Background color
                foregroundColor: Colors.white, // Text color
              ),
              child: Text(AppLocalizations.of(context)!.offline_payment),
            )
          ],
        ),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.grand_total,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildDetailColumn('Amount', grandFee['amount']),
                    buildDetailColumn('Discount', grandFee['amount_discount']),
                    buildDetailColumn('Fine', grandFee['amount_fine']),
                    buildDetailColumn('Paid', grandFee['amount_paid']),
                    buildDetailColumn('Balance', grandFee['amount_remaining']),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '\₹${grandFee['fee_fine'].toString()}',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> buildFeesDetailsList(Map<String, dynamic> feesData) {
    List<Widget> feeDetailsWidgets = [];

    if (feesData.containsKey('student_due_fee')) {
      List<dynamic> studentDueFeeList =
          feesData['student_due_fee'] as List<dynamic>;

      for (var feeData in studentDueFeeList) {
        Map<String, dynamic> feeMap = feeData as Map<String, dynamic>;
        List<Widget> feesWidgets = [];

        if (feeMap.containsKey('fees')) {
          List<dynamic> feesList = feeMap['fees'] as List<dynamic>;

          for (var feeDetailData in feesList) {
            Map<String, dynamic> feeDetailMap =
                feeDetailData as Map<String, dynamic>;
            String feeName = feeDetailMap['name'] ?? 'Unknown Fee';
            double feeAmount =
                double.tryParse(feeDetailMap['amount'].toString()) ?? 0.0;
            double fineAmount =
                double.tryParse(feeDetailMap['fees_fine_amount'].toString()) ??
                    0.0;
            feesWidgets.add(Card(
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feeName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Fees Code: ${feeDetailMap['code']}'),
                        feeDetailMap['status'].toString() == "paid"
                            ? Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.green, // Background color
                                  border: Border.all(
                                      color: Colors.orange), // Border color
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Border radius
                                ),
                                child: Text(
                                  feeDetailMap['status']
                                          .toString()
                                          .toUpperCase() +
                                      " ✓",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : loginType == "parent"
                                ? TextButton(
                                    onPressed: () {
                                      showPaymentDialog(
                                          context,
                                          feeDetailMap["student_session_id"]
                                              .toString(),
                                          feeDetailMap["fee_groups_feetype_id"]
                                              .toString(),
                                          feeDetailMap["id"].toString(),
                                          "fees",
                                          "");
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.orange, // Background color
                                        border: Border.all(
                                            color: Colors.red), // Border color
                                        borderRadius: BorderRadius.circular(
                                            8.0), // Border radius
                                      ),
                                      child: const Text(
                                        "₹ Pay",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.red, // Background color
                                      border: Border.all(
                                          color: Colors.red), // Border color
                                      borderRadius: BorderRadius.circular(
                                          8.0), // Border radius
                                    ),
                                    child: const Text(
                                      "UNPAID",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  )
                      ],
                    ),
                    Row(
                      children: [
                        Text('Amount: \₹${feeAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                    Text(
                      'Due Date: ${DateUtilities.formatStringDate(feeDetailMap['due_date'].toString())}',
                    ),
                    Text('Fine: \₹${fineAmount.toStringAsFixed(2)}'),
                    Text(
                        'Discount: \₹${feeDetailMap['total_amount_discount']}'),
                    Text('Paid Amt: \₹${feeDetailMap['total_amount_paid']}'),
                    Text(
                        'Balance Amt: \₹${feeDetailMap['total_amount_remaining']}'),
                  ],
                ),
              ),
            ));
          }
        }

        feeDetailsWidgets.add(
          ExpansionTile(
            title: Text(feeMap['name'] ?? 'Unknown Fee Group'),
            children: feesWidgets,
          ),
        );
      }
    }

    return feeDetailsWidgets;
  }

  Widget buildTransportFeesSection(Map<String, dynamic> feesData) {
    if (!feesData.containsKey('transport_fees')) return const SizedBox.shrink();

    List<dynamic> transportFeesList =
        feesData['transport_fees'] as List<dynamic>;
    List<Widget> transportFeesWidgets = [];

    for (var feeData in transportFeesList) {
      Map<String, dynamic> feeMap = feeData as Map<String, dynamic>;
      transportFeesWidgets.add(Card(
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Month: ${feeMap['month']}'),
                  feeMap['status'].toString() == "paid"
                      ? Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.green, // Background color
                            border: Border.all(
                                color: Colors.orange), // Border color
                            borderRadius:
                                BorderRadius.circular(8.0), // Border radius
                          ),
                          child: Text(
                            feeMap['status'].toString() + " ✓",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      : loginType == "parent"
                          ? TextButton(
                              onPressed: () {
                                // print(feeMap["id"]);
                                // print(feeMap["feetype_id"]);
                                // print(feeMap["payment_id"]);
                                // print(feeMap["transport_feemaster_id"]);
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) =>
                                //         StudentOnlineCoursePayment(
                                //       feesId: feeMap["id"].toString(),
                                //       feesTypeId:
                                //           feeMap["feetype_id"].toString(),
                                //       paymentType:
                                //           feeMap["payment_id"].toString(),
                                //       transFeesId:
                                //           feeMap["transport_feemaster_id"]
                                //               .toString(),
                                //       amount: feeMap['fees'],
                                //       name: feeMap['code'].toString(),
                                //       description: '',
                                //     ),
                                //   ),
                                // );

                                showPaymentDialog(
                                    context,
                                    feeMap["student_session_id"].toString(),
                                    "",
                                    "",
                                    "transport_fees",
                                    feeMap["id"].toString());
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.orange, // Background color
                                  border: Border.all(
                                      color: Colors.red), // Border color
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Border radius
                                ),
                                child: const Text(
                                  "₹ Pay",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.red, // Background color
                                border: Border.all(
                                    color: Colors.red), // Border color
                                borderRadius:
                                    BorderRadius.circular(8.0), // Border radius
                              ),
                              child: const Text(
                                "UNPAID",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            )
                ],
              ),
              Text('Fees Code: ${feeMap['month']}'),
              Text(
                  'Due Date: ${DateUtilities.formatStringDate(feeMap['due_date'])}'),
              Row(
                children: [
                  Text('Amount: \₹${feeMap['fees']}'),
                ],
              ),
              Text('Fine: \₹${feeMap['fine_amount'] ?? "0"}'),
              Text('Discount: \₹${feeMap['total_amount_discount']}'),
              Text('Paid Amount: \₹${feeMap['total_amount_paid']}'),
              Text('Balance Amount: \₹${feeMap['total_amount_remaining']}'),
            ],
          ),
        ),
      ));
    }

    return ExpansionTile(
      title: Text(AppLocalizations.of(context)!.transport_fees),
      children: transportFeesWidgets,
    );
  }

  Widget buildDetailColumn(String title, dynamic value) {
    String displayValue = (value == null) ? 'N/A' : '\₹$value';
    return Column(
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          displayValue,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
