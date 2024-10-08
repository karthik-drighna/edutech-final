import 'dart:convert';
import 'package:drighna_ed_tech/models/online_course_model.dart';
import 'package:drighna_ed_tech/screens/students/course_payment_webview.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class StudentCourseDetailPage extends StatefulWidget {
  final String courseId;

  const StudentCourseDetailPage({super.key, required this.courseId});

  @override
  _StudentCourseDetailPageState createState() =>
      _StudentCourseDetailPageState();
}

class _StudentCourseDetailPageState extends State<StudentCourseDetailPage> {
  bool isLoading = true;
  String imgUrl = '';
  CourseDetail? course;
  // If you have a list of sections or something similar, declare it here
  List<Section> sections = [];

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
        ;
        setState(() {
          isLoading = false;
          course = CourseDetail.fromJson(data['course_detail']);
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
    // Loading state
    if (isLoading) {
      return Scaffold(
        appBar: CustomAppBar(
          titleText: 'Course Details',
        ),
        body: const Center(child: PencilLoaderProgressBar()),
      );
    }

    // Check if course is not null before trying to access it
    if (course != null) {
      return Scaffold(
        appBar: CustomAppBar(
          titleText: 'Course Details',
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Image.network(
                imgUrl +
                    "uploads/course/course_thumbnail/" +
                    course!.courseThumbnail,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),

              // Title Section
              Text(
                course!.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),

              // Price and Buy Now Button Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        // Assuming the image is available via an URL
                        backgroundImage: NetworkImage(
                            imgUrl + "uploads/staff_images/" + course!.image),
                      ),
                      Text(course!.name),
                      const Text("Last Updated:"),
                      Text(course!.updatedDate.toString()),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.school),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(course!.className + "-" + course!.section),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.play_arrow),
                          const SizedBox(
                            width: 5,
                          ),
                          Text("Lesson " + course!.lessonCount.toString())
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.lock_clock),
                          const SizedBox(
                            width: 5,
                          ),
                          Text("Lesson " + course!.totalHour)
                        ],
                      ),
                      Text(
                        '₹${course!.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          color:
                              course!.discount > 0 ? Colors.red : Colors.black,
                          decoration: course!.discount > 0
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (course!.discount > 0)
                        Text(
                          '₹${(course!.price * (1 - course!.discount / 100)).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CoursePaymentWebView(
                                courseId: course!.id.toString(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.orange, // Background color is orange
                          foregroundColor: Colors.white, // Text color is white
                        ),
                        child: Text('Buy Now ' +
                            '₹${(course!.price * (1 - course!.discount / 100)).toStringAsFixed(2)}'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Course Details Section
              const Text(
                'What Will I Learn',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              for (String outcome in course!.outcomes) Text('• $outcome'),

              // Class and Teacher Section
              // Text('Class: $courseClass'),
              Text('Teacher: ${course!.name}'),

              // Curriculum Section
              ExpansionTile(
                title: const Text('Curriculum For This Course'),
                children: sections.map((section) {
                  return ExpansionTile(
                    title: Text(section.sectionTitle),
                    children: section.lessonQuizzes.map((lessonQuiz) {
                      return ListTile(
                        title: Text(lessonQuiz.lessonTitle),
                        subtitle: Text(lessonQuiz.type),
                        trailing: Text(lessonQuiz.duration),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),

              // Teacher Information Section
            ],
          ),
        ),
      );
    } else {
      // Handle the state where there is no course data available
      return Scaffold(
        appBar: CustomAppBar(
          titleText: 'Course Not Found',
        ),
        body: const Center(child: Text('Could not load course data.')),
      );
    }
  }
}
