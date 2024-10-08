import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drighna_ed_tech/models/lesson_plan_models.dart';
import 'package:drighna_ed_tech/models/syllabus_subject_model.dart';
import 'package:drighna_ed_tech/screens/students/lesson_plan_details.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/utils/date_format_converter.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentSyllabusTimetableLessonPlan extends StatefulWidget {
  const StudentSyllabusTimetableLessonPlan({super.key});

  @override
  _StudentSyllabusTimetableLessonPlanState createState() =>
      _StudentSyllabusTimetableLessonPlanState();
}

class _StudentSyllabusTimetableLessonPlanState
    extends State<StudentSyllabusTimetableLessonPlan> {
  List<LessonModel> lessons = [];
  List<SyllabusSubject> subjects = [];

  List subjectidList = [];
  List idList = [];

  late String startDate;
  late String endDate;

  @override
  void initState() {
    super.initState();

    initializeDates();
    fetchTimetable();

    // loadData();
    // fetchLessons();
  }

  void initializeDates() {
    DateTime now = DateTime.now();
    int currentDayOfWeek =
        now.weekday; // Dart's DateTime class uses 1 for Monday and 7 for Sunday

    DateTime startOfWeek = now.subtract(Duration(
        days: currentDayOfWeek - 1)); // Adjust based on your week start day
    DateTime endOfWeek =
        now.add(Duration(days: DateTime.daysPerWeek - currentDayOfWeek));

    // Formatting to 'yyyy-MM-dd', which is commonly used in APIs
    startDate =
        "${startOfWeek.year.toString()}-${startOfWeek.month.toString().padLeft(2, '0')}-${startOfWeek.day.toString().padLeft(2, '0')}";
    endDate =
        "${endOfWeek.year.toString()}-${endOfWeek.month.toString().padLeft(2, '0')}-${endOfWeek.day.toString().padLeft(2, '0')}";
  }

  void getPreviousWeek() {
    DateTime startDateTime = DateFormat('yyyy-MM-dd').parse(startDate);
    DateTime endDateTime = DateFormat('yyyy-MM-dd').parse(endDate);

    setState(() {
      startDate = DateFormat('yyyy-MM-dd')
          .format(startDateTime.subtract(const Duration(days: 7)));
      endDate = DateFormat('yyyy-MM-dd')
          .format(endDateTime.subtract(const Duration(days: 7)));
    });

    // Fetch the timetable for the new date range
    fetchTimetable();
  }

  void getNextWeek() {
    DateTime startDateTime = DateFormat('yyyy-MM-dd').parse(startDate);
    DateTime endDateTime = DateFormat('yyyy-MM-dd').parse(endDate);

    setState(() {
      startDate = DateFormat('yyyy-MM-dd')
          .format(startDateTime.add(const Duration(days: 7)));
      endDate = DateFormat('yyyy-MM-dd')
          .format(endDateTime.add(const Duration(days: 7)));
    });

    // Fetch the timetable for the new date range
    fetchTimetable();
  }

  Future<void> loadData() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String studentId = prefs.getString('studentId') ?? '';

      Map<String, dynamic> params = {
        "student_id": studentId,
      };
      await getSubjectData(params);
    } else {
      // No internet connection
      print('No internet connection');
    }
  }

  Future<void> getSubjectData(params) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';

    var url = Uri.parse('$apiUrl${Constants.getsyllabussubjectsUrl}');

    var response = await http.post(url,
        headers: {
          "Client-Service": Constants.clientService,
          "Auth-Key": Constants.authKey,
          "Content-Type": "application/json",
          'User-ID': prefs.getString('userId') ?? '',
          'Authorization': prefs.getString('accessToken') ?? '',
        },
        body: json.encode(params));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var subjectsData = data['subjects'] as List;
      setState(() {
        // isLoading = false;

        subjects =
            subjectsData.map((json) => SyllabusSubject.fromJson(json)).toList();

        for (int i = 0; i < subjects.length; i++) {
          idList.add(subjects[i].id);
          subjectidList.add(subjects[i].subjectGroupSubjectId);
        }

        fetchLessons();
      });
    } else {
      setState(() {
        // isLoading = false;
      });
      // Handle error
    }
  }

  fetchLessons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String url = apiUrl + Constants.getSubjectsLessonsUrl;

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': Constants.contentType,
        'Client-Service': Constants.clientService,
        'Auth-Key': Constants.authKey,
        'User-ID': prefs.getString(Constants.userId) ?? "",
        'Authorization': prefs.getString("accessToken") ?? "",
      },
      body: json.encode({
        "subject_group_subject_id": subjectidList[0],
        "subject_group_class_sections_id": idList[0],
        // Add other parameters if needed
      }),
    );

    if (response.statusCode == 200) {
      var decodedData = json.decode(response.body);

      fetchTimetable();
      // Assuming the decoded data is a list of lesson JSON objects
      List<dynamic> lessonsJsonList = decodedData is List ? decodedData : [];

      setState(() {
        lessons =
            lessonsJsonList.map((json) => LessonModel.fromJson(json)).toList();
      });
    } else {
      // Handle error
      print("Failed to load lessons");
    }
  }

  Future<Map<String, dynamic>> fetchTimetable() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString("apiUrl") ?? "";
    String studentId = prefs.getString("studentId") ?? "";
    String url = apiUrl + Constants.getlessonplanUrl;

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': Constants.contentType,
        'Client-Service': Constants.clientService,
        'Auth-Key': Constants.authKey,
        'User-ID': prefs.getString(Constants.userId) ?? "",
        'Authorization': prefs.getString("accessToken") ?? "",
      },
      body: jsonEncode(<String, String>{
        'student_id': studentId,
        'date_from': startDate,
        'date_to': endDate,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load timetable');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchTimetable(),
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: PencilLoaderProgressBar());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!['timetable'] == null) {
          return const Center(child: Text("No timetable data available"));
        } else {
          var timetable = snapshot.data!['timetable'];
          return Scaffold(
              appBar: CustomAppBar(
                titleText: AppLocalizations.of(context)!.lesson_plan,
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_left,
                            size: 50,
                          ),
                          onPressed: () {
                            // Logic to go to previous week
                            getPreviousWeek();
                          },
                        ),
                        Text(
                          '${DateUtilities.formatStringDate(startDate)} - ${DateUtilities.formatStringDate(endDate)}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_right,
                            size: 50,
                          ),
                          onPressed: () {
                            // Logic to go to next week
                            getNextWeek();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: timetable.keys.length,
                      itemBuilder: (context, index) {
                        String day = timetable.keys.elementAt(index);

                        List<dynamic> lessons = timetable[day];

                        return ExpansionTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(day),
                              Text(lessons.isNotEmpty
                                  ? DateFormat('dd/MM/yyyy').format(
                                      DateTime.parse(lessons[0]['date']))
                                  : 'No Lesson Plan'),
                            ],
                          ),
                          children: lessons.map<Widget>((lesson) {
                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            LessonPlanDetailsPage(
                                              subjectId:
                                                  lesson['subject_syllabus_id'],
                                              className: lesson['class'],
                                              subject: lesson['name'],
                                              Section: lesson['section'],
                                            )));
                              },
                              title: Text(lesson['name']),
                              subtitle: Text(
                                  "${lesson['time_from']} - ${lesson['time_to']}"),
                              trailing: const Icon(Icons.book),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ));
        }
      },
    );
  }
}
