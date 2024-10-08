import 'package:drighna_ed_tech/screens/students/student_online_exam_questions.dart';
import 'package:drighna_ed_tech/screens/students/student_online_exam_result.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/Student_OnlineExamList_card.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StudentOnlineExam extends StatefulWidget {
  const StudentOnlineExam({super.key});

  @override
  _StudentOnlineExamState createState() => _StudentOnlineExamState();
}

class _StudentOnlineExamState extends State<StudentOnlineExam>
    with SingleTickerProviderStateMixin {
  List<dynamic> examList = [];
  String status = "";
  TabController? _tabController;
  bool isParent = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    fetchDataFromApi();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    return "${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void checkExamTiming(BuildContext context, dynamic exam) {
    DateTime now = DateTime.now();
    DateFormat sdf =
        DateFormat('yyyy-MM-dd HH:mm:ss'); // Adjust format to match your needs

    String? startTimeStr = exam['exam_from'];
    String? endTimeStr = exam['exam_to'];

    if (startTimeStr == null || endTimeStr == null) {
      showSnackbar(context, "Exam start or end time is not defined.");
      return;
    }

    try {
      DateTime startTime = sdf.parse(startTimeStr);
      DateTime endTime = sdf.parse(endTimeStr);

      if (now.isAfter(startTime) && now.isBefore(endTime)) {
        Duration diff = endTime.difference(now);
        String formattedTime = formatDuration(diff);
        String examDuration = exam['duration'];

        if (formattedTime.compareTo(examDuration) < 0) {
          navigateToExam(context, exam, formattedTime);
        } else {
          navigateToExam(context, exam, examDuration);
        }
      } else if (now.isAtSameMomentAs(startTime) || now.isBefore(endTime)) {
        Duration diff = endTime.difference(now);
        String formattedTime = formatDuration(diff);

        navigateToExam(context, exam, formattedTime);
      } else {
        showSnackbar(context,
            "You have reached total attempts or the exam date has passed, please contact the administrator.");
      }
    } catch (e) {
      showSnackbar(context, "Error parsing dates: ${e.toString()}");
    }
  }

  void navigateToExam(BuildContext context, dynamic exam, String duration) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentOnlineExamQuestionsNew(
          onlineExamId: exam['id'],
          duration: duration,
          onlineExamStudentId: exam['onlineexam_student_id'],
        ),
      ),
    ).then((_) {
      // This block runs when you pop back to this screen
      // Refresh your data here

      setState(() {
        fetchDataFromApi();
      });
    });
  }

  void _handleTabSelection() {
    if (_tabController!.indexIsChanging) {
      setState(() {
        status = _tabController!.index == 0 ? 'pending' : 'closed';
      });
      fetchDataFromApi();
    }
  }

  fetchDataFromApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString("apiUrl") ?? "";
    String url = apiUrl + Constants.getOnlineExamUrl;

    String studentId = prefs.getString(Constants.studentId) ?? "";

    var response = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': Constants.contentType,
          'Client-Service': Constants.clientService,
          'Auth-Key': Constants.authKey,
          'User-ID': prefs.getString(Constants.userId) ?? "",
          'Authorization': prefs.getString("accessToken") ?? "",
        },
        body: json.encode({
          'student_id': studentId,
          'exam_type': status,
        }));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      setState(() {
        examList = data['onlineexam'];
      });
    } else {
      // Handle error
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isParent = prefs.getString('role') == "parent";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Online Examination',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          labelStyle: const TextStyle(fontSize: 18),
          unselectedLabelStyle: const TextStyle(fontSize: 15),
          tabs: const [
            Tab(
              text: 'Upcoming Exams',
            ),
            Tab(text: 'Closed Exams'),
          ],
          indicatorColor:
              const Color.fromARGB(0, 13, 7, 7), // Hide the indicator
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          examList.isNotEmpty
              ? RefreshIndicator(
                  onRefresh: () async {
                    await fetchDataFromApi(); // Make sure this function returns a Future
                  },
                  child: ListView.builder(
                    itemCount: examList.length,
                    itemBuilder: (context, index) {
                      return examList.isNotEmpty
                          ? ExamListCard(
                              examData: examList[index],
                              status: status,
                              isParent: isParent,
                              onStartPressed: () {
                                if (examList[index]['attempt'].toString() ==
                                    examList[index]['counter'].toString()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'You have reached the maximum attempts'),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                } else {
                                  checkExamTiming(context, examList[index]);
                                }
                              },
                              onViewResultPressed: () {
                                if (examList[index]['publish_result'] == "1" ||
                                    (examList[index]['is_quiz'] == "1" &&
                                        examList[index]['is_attempted'] ==
                                            "1")) {
                                  print("Navigating to view");
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              StudentOnlineExamResult(
                                                  examId: examList[index]['id'],
                                                  onlineExamStudentId: examList[
                                                          index][
                                                      'onlineexam_student_id'])));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Viewing results is not allowed or the exam is not yet submitted'),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                            )
                          : const Center(child: Text("No Data Found"));
                    },
                  ),
                )
              : const Center(child: Text("No Upcoming Exams")),
        ],
      ),
    );
  }

  Widget _buildExamList(String filterStatus) {
    return examList.isNotEmpty
        ? ListView.builder(
            itemCount: examList.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: status == 'pending' ? Colors.red : Colors.white,
                  border: Border.all(
                      color: status == 'closed'
                          ? Colors.green
                          : Colors.transparent),
                ),
                child: Text(
                  examList[index],
                  style: TextStyle(
                      color: status == 'pending' ? Colors.white : Colors.black),
                ),
              );
            },
          )
        : const Center(
            child: PencilLoaderProgressBar(),
          );
  }
}
