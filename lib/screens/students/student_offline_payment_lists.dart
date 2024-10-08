import 'dart:convert';
import 'dart:io';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/utils/date_format_converter.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/file_viewer.dart';
import 'package:drighna_ed_tech/widgets/image_viewer.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentOfflinePaymentList extends StatefulWidget {
  const StudentOfflinePaymentList({super.key});

  @override
  _StudentOfflinePaymentListState createState() =>
      _StudentOfflinePaymentListState();
}

class _StudentOfflinePaymentListState extends State<StudentOfflinePaymentList> {
  List<Map<String, dynamic>> paymentData = [];
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String apiUrl = prefs.getString(Constants.apiUrl) ?? "";
    String clientService = Constants.clientService;
    String authKey = Constants.authKey;
    final String userId = prefs.getString(Constants.userId) ?? "";
    final String accessToken = prefs.getString("accessToken") ?? "";
    final String studentId = prefs.getString(Constants.studentId) ?? "";

    final url = '$apiUrl${Constants.getOfflineBankPayments}';
    final headers = {
      'Client-Service': clientService,
      'Auth-Key': authKey,
      'Content-Type': 'application/json',
      'User-ID': userId,
      'Authorization': accessToken,
    };

    final body = jsonEncode({'student_id': studentId});

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          paymentData = List<Map<String, dynamic>>.from(data['result_array']);
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          errorMessage = 'Error loading data';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isError = true;
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  Future<void> downloadFile(
      String url, String filename, BuildContext context) async {
    try {
      await FileDownloader.downloadFile(
        url: url,
        name: filename,
        onProgress: (name, progress) {
          setState(() {
            isLoading = true;
          });
        },
        onDownloadCompleted: (path) {
          setState(() {
            isLoading = false;
          });
          _showSnackBar("File downloaded to $path", context);
          _viewFile(url);
        },
        onDownloadError: (error) {
          setState(() {
            isLoading = false;
          });
          _showSnackBar("Error downloading file: $error", context);
        },
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar("Error: $e", context);
    }
  }

  void _showSnackBar(String message, context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String formatDate(String date) {
    if (date.isEmpty) {
      return 'No Date';
    } else {
      DateTime dateTime = DateFormat("yyyy-MM-dd").parse(date);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  Future<void> _viewFile(String url) async {
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var documentDirectory = await getApplicationDocumentsDirectory();
        String fileName = url.split('/').last;
        File file = File('${documentDirectory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        if (fileName.endsWith('.pdf') || fileName.endsWith('.txt')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FileViewer(filePath: file.path),
            ),
          );
        } else if (fileName.endsWith('.jpg') ||
            fileName.endsWith('.png') ||
            fileName.endsWith('.jpeg')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewer(filePath: file.path),
            ),
          );
        } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FileViewer(filePath: file.path),
            ),
          );
        } else {
          _launchURL(url);
        }
      } else {
        _showSnackBar("Failed to download file", context);
      }
    } catch (e) {
      _showSnackBar('Error: $e', context);
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showSnackBar('Could not launch $url', context);
    }
  }

  Widget buildFeeCard(Map<String, dynamic> payment) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Request ID: ${payment['id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                Row(
                  children: [
                    if (payment['attachment'] != null &&
                        payment['attachment'].isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.black),
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String urlStr =
                              prefs.getString(Constants.imagesUrl) ?? '';
                          urlStr += "uploads/offline_payments/" +
                              payment['attachment'].toString();

                          downloadFile(urlStr, payment['attachment'], context);
                        },
                      ),
                    Text(
                      payment['is_active'] == "1"
                          ? 'Approved'
                          : payment['is_active'] == "0"
                              ? 'Pending'
                              : 'Disapproved',
                      style: TextStyle(
                        color: payment['is_active'] == "1"
                            ? Colors.green
                            : payment['is_active'] == "0"
                                ? Colors.orange
                                : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 5.0),
            Text(
                'Payment Date: ${DateUtilities.formatStringDate(payment['payment_date'])}'),
            Text(
                'Submit Date: ${DateUtilities.formatDateTimeString(payment['submit_date'])}'),
            Text('Amount: ${payment['amount']}'),
            Text(
                'Approved/Rejected: ${DateUtilities.formatDateTimeString(payment['approve_date'] ?? "")}'),
            Text('Payment Id: ${payment['invoice_id']}'),
            if (payment['student_fees_master_id'] != null &&
                payment['student_fees_master_id'].isNotEmpty)
              Text('Fee Group: ${payment['fee_group_name']}'),
            if (payment['fee_groups_feetype_id'] != null &&
                payment['fee_groups_feetype_id'].isNotEmpty)
              Text('Fee Code: ${payment['code']}'),
            if (payment['student_transport_fee_id'] != null &&
                payment['student_transport_fee_id'].isNotEmpty)
              Text('Transport Fees Month: ${payment['month']}'),
            if (payment['pickup_point'] != null &&
                payment['pickup_point'].isNotEmpty)
              Text(
                  "Route Pickup Point: ${payment['pickup_point']} (${payment['route_title']})"),
            Text('Payment From: ${payment['bank_account_transferred']}'),
            Text('Reference: ${payment['reference']}'),
            Text('Payment Mode: ${payment['bank_from']}'),
            Text('Comments: ${payment['reply']}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          titleText: AppLocalizations.of(context)!.offline_payment),
      body: isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : isError
              ? Center(child: Text('Error: $errorMessage'))
              : RefreshIndicator(
                  onRefresh: loadData,
                  child: paymentData.isEmpty
                      ? const Center(child: Text('No data available'))
                      : ListView.builder(
                          itemCount: paymentData.length,
                          itemBuilder: (context, index) {
                            final payment = paymentData[index];
                            return buildFeeCard(payment);
                          },
                        ),
                ),
    );
  }
}
