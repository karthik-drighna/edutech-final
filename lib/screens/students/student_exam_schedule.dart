import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/exam_subject_card.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StudentExamSchedule extends StatefulWidget {
  final String examGroupId;

  const StudentExamSchedule({super.key, required this.examGroupId});

  @override
  _StudentExamScheduleState createState() => _StudentExamScheduleState();
}

class _StudentExamScheduleState extends State<StudentExamSchedule> {
  bool isLoading = true;
  List<dynamic> subjectList = [];

  @override
  void initState() {
    super.initState();
    getDataFromApi();
  }

  Future<void> getDataFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    final apiUrl = prefs.getString("apiUrl") ?? "";
    String userId = prefs.getString('userId') ?? '';
    String accessToken = prefs.getString('accessToken') ?? '';

    String url = '$apiUrl${Constants.getExamScheduleDetailsUrl}';
    Map<String, String> headers = {
      "Client-Service":
          Constants.clientService, // Replace with your Client-Service
      "Auth-Key": Constants.authKey, // Replace with your Auth-Key
      "Content-Type": "application/json",
      "User-ID": userId,
      "Authorization": accessToken,
    };

    var body = json.encode({
      "exam_group_class_batch_exam_id": widget.examGroupId,
    });

    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        isLoading = false;
        subjectList = data['exam_subjects'];
      });
    } else {
      setState(() {
        isLoading = false;
        // Handle error
        print('Failed to load exam schedule');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          titleText: 'Exam Schedule',
        ),
        body: isLoading
            ? const Center(child: PencilLoaderProgressBar())
            : subjectList.isNotEmpty
                ? ListView.builder(
                    itemCount: subjectList.length,
                    itemBuilder: (context, index) {
                      var subject = subjectList[index];
                      return ExamSubjectCard(
                        subjectName: subject['subject_name'],
                        subjectCode: subject['subject_code'].toString(),
                        date: subject['date_from'],
                        roomNumber: subject['room_no'].toString(),
                        startTime: subject['time_from'],
                        duration: subject['duration'].toString(),
                        maxMarks: subject['max_marks'].toString(),
                        minMarks: subject['min_marks'].toString(),
                        creditHours: subject['credit_hours'].toString(),
                      );
                    },
                  )
                : const Center(
                    child: Text("No Data available"),
                  ));
  }
}
