import 'package:drighna_ed_tech/models/course_start_lesson_videoplay_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/course_video_sections_widget.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StudentStartLesson extends StatefulWidget {
  final String courseId;

  const StudentStartLesson({super.key, required this.courseId});

  @override
  _StudentStartLessonState createState() => _StudentStartLessonState();
}

class _StudentStartLessonState extends State<StudentStartLesson> {
  bool isLoading = true;
  late List<Section> sections = []; // Initialize with actual data

  String imgUrl = '';
  var course;

  @override
  void initState() {
    super.initState();
    // TODO: Implement fetchCourseDetails
    fetchCourseDetails();
  }

  void parseCurriculumData(String responseBody) {
    final data = json.decode(responseBody);
    final sectionData = data['sectionList'] as List;

    setState(() {
      sections =
          sectionData.map<Section>((json) => Section.fromJson(json)).toList();
    });
  }

  Future<void> fetchCourseDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String studentId = prefs.getString('studentId') ?? '';
    Map<String, String> bodyParams = {
      "course_id": widget.courseId,
      "student_id": studentId,
    };
    await getDataFromApi(bodyParams);
  }

  Future<void> getDataFromApi(Map<String, String> params) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String userId = prefs.getString('userId') ?? '';
    String accessToken = prefs.getString('accessToken') ?? '';
    imgUrl = prefs.getString(Constants.imagesUrl) ?? '';

    String url = '$apiUrl${Constants.coursedetailUrl}';

    Map<String, String> headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": "application/json",
      "User-ID": userId,
      "Authorization": accessToken,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(params),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          isLoading = false;
          course = data['course_detail'];
        });
      } else {
        // Handle non-200 responses here
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e.toString());
    }

    getCourseCurriculumFromApi();
  }

  void getCourseCurriculumFromApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String userId = prefs.getString('userId') ?? '';
    String accessToken = prefs.getString('accessToken') ?? '';
    String studentId = prefs.getString('studentId') ?? '';

    // Assuming you have these constants defined somewhere
    const clientService = Constants.clientService;
    const authKey = Constants.authKey;
    const contentType = Constants.contentType;

    String url =
        '$apiUrl${Constants.coursecurriculumUrl}'; // Make sure to replace with actual endpoint

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Client-Service': clientService,
          'Auth-Key': authKey,
          'Content-Type': contentType,
          'User-ID': userId,
          'Authorization': accessToken,
        },
        body: json
            .encode({"course_id": widget.courseId, "student_id": studentId}),
      );

      if (response.statusCode == 200) {
        parseCurriculumData(response.body); // Parse and set data
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle any errors that occur during the request
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Course Details',
      ),
      body: isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                sections[0].title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: sections.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CourseVideoSectionWidget(
                        section: sections[index], index: index + 1);
                  },
                ),
              ),
            ]),
    );
  }
}
