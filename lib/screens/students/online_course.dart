import 'package:drighna_ed_tech/models/course_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/course_card.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StudentOnlineCourse extends StatefulWidget {
  const StudentOnlineCourse({super.key});

  @override
  _StudentOnlineCourseState createState() => _StudentOnlineCourseState();
}

class _StudentOnlineCourseState extends State<StudentOnlineCourse> {
  List<CourseModel> courses = [];
  String imgUrl = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<void> loadCourses() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString(Constants.apiUrl) ?? '';
    String studentId = prefs.getString(Constants.studentId) ?? '';
    imgUrl = prefs.getString(Constants.imagesUrl) ?? '';

    var url = Uri.parse('$apiUrl${Constants.courselistUrl}');

    var response = await http.post(url,
        headers: {
          'Content-Type': Constants.contentType,
          'Client-Service': Constants.clientService,
          'Auth-Key': Constants.authKey,
          'User-ID': prefs.getString(Constants.userId) ?? "",
          'Authorization': prefs.getString("accessToken") ?? "",
        },
        body: jsonEncode({"student_id": studentId}));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      // Fetch and wait for all CourseModels to be created from JSON
      List<Future<CourseModel>> courseFutures = (data["course_list"] as List)
          .map((x) => CourseModel.fromJson(x))
          .toList();

      // Wait for all futures to complete
      List<CourseModel> courseList = await Future.wait(courseFutures);

      setState(() {
        courses = courseList;
      });
    } else {
      // Handle error
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Courses",
      ),
      body: RefreshIndicator(
        onRefresh: loadCourses,
        child: isLoading
            ? const Center(child: PencilLoaderProgressBar())
            : courses.isEmpty
                ? const Center(
                    child: Text("No course has been added"),
                  )
                : ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      var course = courses[index];
                      return CourseCard(course: course, imgUrl: imgUrl);
                    },
                  ),
      ),
    );
  }
}
