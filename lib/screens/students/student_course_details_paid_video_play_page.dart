import 'package:cached_network_image/cached_network_image.dart';
import 'package:drighna_ed_tech/models/course_details.dart';
import 'package:drighna_ed_tech/screens/students/student_start_lesson.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/course_details_widget.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StudentCourseDetailsPaidVideoPlayPage extends StatefulWidget {
  final String courseId;

  const StudentCourseDetailsPaidVideoPlayPage(
      {super.key, required this.courseId});

  @override
  _StudentCourseDetailsPaidVideoPlayPageState createState() =>
      _StudentCourseDetailsPaidVideoPlayPageState();
}

class _StudentCourseDetailsPaidVideoPlayPageState
    extends State<StudentCourseDetailsPaidVideoPlayPage> {
  bool isLoading = true;
  late List<Sections> sections = []; // Initialize with actual data

  String userImage = '';
  var course;

  @override
  void initState() {
    super.initState();

    fetchCourseDetails();
  }

  void parseCurriculumData(String responseBody) {
    final data = json.decode(responseBody);
    final sectionData = data['sectionList'] as List;
    setState(() {
      sections =
          sectionData.map<Sections>((json) => Sections.fromJson(json)).toList();
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

          String imgUrl = prefs.getString(Constants.imagesUrl) ?? '';

          userImage = imgUrl + "uploads/staff_images/" + course['image'];
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
        body: json.encode({"course_id": widget.courseId}),
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
                course['title'],
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              Flexible(
                  child: Text(
                course['description'],
                softWrap: true,
              )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Column(
                      children: [
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: userImage,
                            height: 100,
                            width: 100,
                            placeholder: (context, url) => ClipOval(
                              child: Image.asset(
                                'assets/placeholder_user.png',
                                height: 80,
                                width: 80,
                              ),
                            ),
                            errorWidget: (context, url, error) => ClipOval(
                              child: Image.asset(
                                'assets/placeholder_user.png',
                                height: 80,
                                width: 80,
                              ),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          '${course['name']} ${course['surname']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        // Text("Last Updated:"),
                        // Text("date")
                      ],
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.note_add_outlined),
                            Text(course['class'] + "-"),
                            Text(course['section'])
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.play_arrow),
                            Text("Lesson " + course['lesson_count'].toString())
                          ],
                        ),
                        // Icon(Icons.quiz),
                        Row(
                          children: [
                            const Icon(Icons.lock_clock_rounded),
                            Text(" " + course['total_hour'])
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StudentStartLesson(
                                          courseId: widget.courseId.toString(),
                                        )));
                          },
                          child: const Text('Start Lesson'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // background color
                            foregroundColor: Colors.white, // text color
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Text(
                "What Will I Learn",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Curriculam for this Courese",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: sections.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CourseDetailsSectionWidget(
                      section: sections[index],
                      index: index + 1,
                    );
                  },
                ),
              ),
            ]),
    );
  }
}
