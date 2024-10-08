import 'dart:convert';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CardSection extends StatelessWidget {
  final List listOfDataSets;

  final List<List<Color>> gradientColors = [
    [Colors.red, Colors.orange],
    [Colors.green, Colors.lightGreen],
    [Colors.blue, Colors.lightBlue],
    [Colors.purple, Colors.deepPurple],
    [Colors.pink, Colors.redAccent],
  ];

  CardSection({required this.listOfDataSets});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: listOfDataSets.length,
      itemBuilder: (context, index) {
        // List<Color> cardGradientColors =
        //     gradientColors[index % gradientColors.length];

        return GestureDetector(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              String routeName = listOfDataSets[index].name;

              switch (routeName.trim()) {
                case 'Homework':
                  Navigator.pushNamed(context, "/Homework");
                  break;
                case "Daily Assignment":
                  Navigator.pushNamed(context, "/DailyAssignment");
                  break;
                case "Lesson Plan":
                  Navigator.pushNamed(context, "/LessonPlan");
                  break;

                case "Online Examination":
                  Navigator.pushNamed(context, "/OnlineExamination");
                  break;
                case "Download Center":
                  Navigator.pushNamed(context, "/DownloadCenter");
                  break;
                case "Online Course":
                  //  Navigator.pushNamed(context, '/OnlineCourse');
                  final Map<String, dynamic> aparams = {
                    'site_url': prefs.getString(Constants.imagesUrl) ?? '',
                    'addontype': 'ssoclc',
                  };

                  checkAddonforElearning(
                      json.encode(aparams), 'ssoclc', context);
                  break;
                case "Zoom Live Classes":
                  final Map<String, dynamic> aparams = {
                    'site_url': prefs.getString(Constants.imagesUrl) ?? '',
                    'addontype': 'sszlc',
                  };

                  checkAddonforElearning(
                      json.encode(aparams), 'sszlc', context);
                  break;

                case "Gmeet Live Classes":
                  final Map<String, dynamic> aparams = {
                    'site_url': prefs.getString(Constants.imagesUrl) ?? '',
                    'addontype': 'ssglc',
                  };

                  checkAddonforElearning(
                      json.encode(aparams), 'ssglc', context);
                  break;

                case "Class Timetable":
                  Navigator.pushNamed(context, "/ClassTimetable");
                  break;

                case "Syllabus Status":
                  Navigator.pushNamed(context, "/SyllabusStatus");
                  break;

                case "Attendance":
                  Navigator.pushNamed(context, "/Attendance");
                  break;

                case "Examinations":
                  Navigator.pushNamed(context, "/Exam");
                  break;

                case "Student Timeline":
                  Navigator.pushNamed(context, "/Timeline");
                  break;

                case "My Documents":
                  Navigator.pushNamed(context, "/Documents");
                  break;

                case "Behaviour Records":
                  final Map<String, dynamic> aparams = {
                    'site_url': prefs.getString(Constants.imagesUrl) ?? '',
                    'addontype': 'ssbr',
                  };

                  checkAddonForAcademics(json.encode(aparams), 'ssbr', context);

                  break;
                case "CBSE Examination":
                  final Map<String, dynamic> aparams = {
                    'site_url': prefs.getString(Constants.imagesUrl) ?? '',
                    'addontype': 'sscbse',
                  };

                  checkAddonForAcademics(
                      json.encode(aparams), 'sscbse', context);
                  break;
                case 'Notice Board':
                  Navigator.pushNamed(context, "/noticeBoard");
                  break;
                case 'fees':
                  Navigator.pushNamed(context, "/feesList");

                  break;

                case 'apply_leave':
                  Navigator.pushNamed(context, "/studentLeave");
                  break;

                case 'visitor_book':
                  Navigator.pushNamed(context, "/studentVisitorBook");
                  break;
                case 'transport_routes':
                  Navigator.pushNamed(context, "/studentTransportRoutes");
                  break;
                case 'hostel_rooms':
                  Navigator.pushNamed(context, "/studentHostel");
                  break;
                case 'calendar_to_do_list':
                  Navigator.pushNamed(context, "/studentTasks");
                  break;
                case 'library':
                  Navigator.pushNamed(context, "/library");
                  break;
                case 'teachers_rating':
                  Navigator.pushNamed(context, "/studentTeachersList");
                  break;

                default:
                  Navigator.pushNamed(context, "/home");
                  break;
                // Handle an unknown dataset name if necessary
              }
            },
            child: Container(
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Colors.blueGrey, // Border color
                  width: 1.3, // Border width
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withOpacity(0.5), // Shadow color with some opacity
                    spreadRadius: 1, // Reduced spread radius
                    blurRadius: 5, // Increased blur radius for a softer shadow
                    offset: const Offset(
                        5, 8), // Increased vertical offset to move shadow lower
                  ),
                ],
                // Uncomment below lines to use gradient with elevation
                // gradient: LinearGradient(
                //   colors: cardGradientColors,
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                // ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50, // Width of the container
                      height: 50, // Height of the container
                      decoration: BoxDecoration(
                        color:
                            Colors.white, // Background color of the container
                        shape: BoxShape.circle, // Makes the container a circle
                        border: Border.all(
                          color: Colors.blueGrey, // Color of the border
                          width: 1, // Thickness of the border
                        ),
                      ),
                      child: Center(
                        child: Image.asset(
                          listOfDataSets[index].thumbnail,
                          height: 30,
                          width: 30,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      listOfDataSets[index].name == "Gmeet Live Classes "
                          ? "Live Classes"
                          : listOfDataSets[index].name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }

  Future<void> checkAddonforElearning(
      String bodyParams, String type, BuildContext context) async {
    final String url = 'https://sstrace.qdocs.in/postlic/verifyaddon';
    final prefs = await SharedPreferences.getInstance();

    final headers = {
      'Client-Service': Constants.clientService,
      'Auth-Key': Constants.authKey,
      'Content-Type': Constants.contentType,
      'User-ID': prefs.getString('userId') ?? '',
      'Authorization': prefs.getString('accessToken') ?? '',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyParams,
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        if (result['status'] == '1') {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text(''),
                content: const Text(
                    'Verification Message'), // Replace with your resource call
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'), // Replace with your resource call
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                    },
                  ),
                ],
              );
            },
          );
        } else {
          switch (type) {
            case 'sszlc':
              Navigator.pushNamed(context, '/LiveClasses');
              break;
            case 'ssoclc':
              Navigator.pushNamed(context, '/OnlineCourse');
              break;
            case 'ssglc':
              Navigator.pushNamed(context, '/GmeetLiveClasses');
              break;
            default:
              // Handle other types if needed

              break;
          }
        }
      } else {
        // Handle the case when the server doesn't respond with a 200 OK
        // Show error message to user
      }
    } catch (e) {
      // Handle any errors that occur during the POST
      print('Error making POST request: $e');

      // Show error message to user
    }
  }

  Future<void> checkAddonForAcademics(
      String bodyParams, String type, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String url = 'https://sstrace.qdocs.in/postlic/verifyaddon';
    final headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": Constants.contentType,
      'User-ID': prefs.getString('userId') ?? '',
      'Authorization': prefs.getString('accessToken') ?? '',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyParams,
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == '1') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(''),
                content: const Text('Verification Message'),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          if (type == "ssbr") {
            Navigator.pushNamed(context, "/Behaviour");
          } else if (type == "sscbse") {
            Navigator.pushNamed(context, "/CbseExamination");
          }
        }
      } else {
        // Handle non-200 responses
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to communicate with the server')),
      );
    }
  }
}
