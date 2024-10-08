import 'package:drighna_ed_tech/models/cbse_exam_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/cbse_exam_result_card.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CbseExaminationResultsScreen extends StatefulWidget {
  const CbseExaminationResultsScreen({super.key});

  @override
  _CbseExaminationResultsScreenState createState() =>
      _CbseExaminationResultsScreenState();
}

class _CbseExaminationResultsScreenState
    extends State<CbseExaminationResultsScreen> {
  late Future<List<CbseExamModel>> futureExamResults;

  @override
  void initState() {
    super.initState();
    futureExamResults = fetchExamResults();
  }

  Future<List<CbseExamModel>> fetchExamResults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString("apiUrl") ?? "";
    String url = apiUrl + Constants.cbseexamresultUrl;
    String studentSessionId =
        prefs.getString(Constants.student_session_id) ?? "";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Client-Service": Constants.clientService,
        "Auth-Key": Constants.authKey,
        "Content-Type": Constants.contentType,
        'User-ID': prefs.getString(Constants.userId) ?? "",
        'Authorization': prefs.getString("accessToken") ?? "",
      },
      body: jsonEncode({
        'student_session_id': studentSessionId,
      }),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['exams'];
      return jsonResponse.map((data) => CbseExamModel.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load exam results');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleText: 'CBSE Exam Results'),
      body: FutureBuilder<List<CbseExamModel>>(
        future: futureExamResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: PencilLoaderProgressBar());
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data available"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return CBSEExamResultCard(cbseExam: snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }
}
