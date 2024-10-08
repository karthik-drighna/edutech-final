import 'dart:convert';
import 'package:drighna_ed_tech/models/exam_results_reportcard_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class StudentReportCardScreen extends StatefulWidget {
  final String examGroupId;

  const StudentReportCardScreen({super.key, required this.examGroupId});

  @override
  _StudentReportCardScreenState createState() =>
      _StudentReportCardScreenState();
}

class _StudentReportCardScreenState extends State<StudentReportCardScreen> {
  late Future<ReportCardData> reportCardData;

  @override
  void initState() {
    super.initState();
    reportCardData = fetchReportCardData();
  }

  Future<ReportCardData> fetchReportCardData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String userId = prefs.getString('userId') ?? '';
    String studentId = prefs.getString('studentId') ?? '';
    String accessToken = prefs.getString('accessToken') ?? '';
    var url = Uri.parse('$apiUrl${Constants.getExamResultUrl}');

    var response = await http.post(
      url,
      headers: <String, String>{
        "Client-Service": Constants.clientService,
        "Auth-Key": Constants.authKey,
        "Content-Type": "application/json",
        "User-ID": userId,
        "Authorization": accessToken,
      },
      body: jsonEncode({
        "student_id": studentId,
        "exam_group_class_batch_exam_id": widget.examGroupId,
      }),
    );

    if (response.statusCode == 200) {
      return ReportCardData.fromJson(json.decode(response.body)['exam']);
    } else {
      throw Exception('Failed to load results');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Exam Results',
      ),
      body: FutureBuilder<ReportCardData>(
        future: reportCardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: PencilLoaderProgressBar());
          } else if (snapshot.hasError) {
            return const Center(child: Text("No data available"));
            //Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            return buildReportCard(snapshot.data!);
          }
        },
      ),
    );
  }

  Widget buildReportCard(ReportCardData data) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(3),
                  3: FlexColumnWidth(2),
                  4: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    children: [
                      _buildTableHeader('Subject'),
                      _buildTableHeader('Min Marks'),
                      _buildTableHeader('Marks Obtained'),
                      _buildTableHeader('Result'),
                      _buildTableHeader('Note'),
                    ],
                  ),
                  ...data.subjectResults.map((subjectResult) {
                    return TableRow(
                      children: [
                        _buildTableCell(
                            '${subjectResult.name} (${subjectResult.code})'),
                        _buildTableCell(subjectResult.minMarks),
                        _buildTableCell(
                            '${subjectResult.getMarks} / ${subjectResult.maxMarks}'),
                        _buildTableCell(
                          subjectResult.getMarks <
                                  double.parse(subjectResult.minMarks)
                              ? 'Fail'
                              : 'Pass',
                          color: subjectResult.getMarks <
                                  double.parse(subjectResult.minMarks)
                              ? Colors.red
                              : Colors.green,
                        ),
                        _buildTableCell(subjectResult.note),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Table(
            border: TableBorder.all(),
            children: [
              TableRow(
                children: [
                  _buildResultDetail('Grand Total',
                      '${data.grandTotal} / ${data.totalMaxMarks}'),
                  _buildResultDetail(
                      'Percentage', '${data.percentage.toStringAsFixed(2)}%'),
                ],
              ),
              if (data.resultStatus.toUpperCase() != 'FAIL')
                TableRow(
                  children: [
                    _buildResultDetail('Division', data.division),
                    const SizedBox.shrink(), // Placeholder for alignment
                  ],
                ),
              TableRow(
                children: [
                  _buildResultDetail('Result', data.resultStatus.toUpperCase()),
                  const SizedBox.shrink(), // Placeholder for alignment
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        value,
        style: TextStyle(fontSize: 14, color: color ?? Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildResultDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
