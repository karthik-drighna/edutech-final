import 'dart:convert';
import 'package:drighna_ed_tech/models/syllabus_subject_Lesson_Topic_model.dart';
import 'package:drighna_ed_tech/models/syllabus_subject_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class StudentSyllabusLesson extends StatefulWidget {
  final SyllabusSubject subject;

  const StudentSyllabusLesson({super.key, required this.subject});

  @override
  _StudentSyllabusLessonState createState() => _StudentSyllabusLessonState();
}

class _StudentSyllabusLessonState extends State<StudentSyllabusLesson> {
  List<SyllabusSubjectModel> lessons = [];
  String subjectId = "";
  String sectionId = "";

  @override
  void initState() {
    super.initState();
    fetchLessons();
  }

  void requestStoragePermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      print("Storage permission granted");
    } else {
      print("Storage permission denied");
    }
  }

  void fetchLessons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    subjectId = widget.subject.subjectGroupSubjectId.toString();
    sectionId = widget.subject.id.toString();

    String url = apiUrl + Constants.getSubjectsLessonsUrl;
    Map<String, String> headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": "application/json; charset=utf-8",
      "User-ID": prefs.getString('userId') ?? '',
      "Authorization": prefs.getString('accessToken') ?? '',
    };
    var params = {
      "subject_group_subject_id": subjectId,
      "subject_group_class_sections_id": sectionId,
    };

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(params),
      );
      if (response.statusCode == 200) {
        setState(() {
          var jsonData = json.decode(response.body) as List;
          lessons = jsonData
              .map((lessonJson) => SyllabusSubjectModel.fromJson(lessonJson))
              .toList();
        });
      } else {
        // Handle server errors
        print('Server error: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle connectivity errors
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleText: "Lesson Topic"),
      body: lessons.isNotEmpty
          ? ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                var lesson = lessons[index];
                // Calculation of the percentage of completion
                double completionPercentage = lesson.total != 0
                    ? (lesson.totalComplete / lesson.total) * 100
                    : 0;
                return Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      "${index + 1}. ${lesson.name}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "${completionPercentage.toStringAsFixed(2)}% Completed",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    children:
                        lessons[index].topics.asMap().entries.map((entry) {
                      int topicIndex = entry.key;
                      TopicModelForLessonTopic topic = entry.value;
                      return ListTile(
                        title: Text(
                          "${index + 1}.${topicIndex + 1} ${topic.name}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: Text(
                          topic.status == 1 ? 'Complete' : 'Incomplete',
                          style: TextStyle(
                            color:
                                topic.status == 1 ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            )
          : const Center(child: Text("No Data Found")),
    );
  }
}
