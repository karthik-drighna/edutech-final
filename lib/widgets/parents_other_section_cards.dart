import 'package:flutter/material.dart';

class ParentsOtherSectionCards extends StatefulWidget {
  final List<DataSet> listOfDataSets;

  const ParentsOtherSectionCards({super.key, required this.listOfDataSets});

  @override
  State<ParentsOtherSectionCards> createState() =>
      _ParentsOtherSectionCardsState();
}

class _ParentsOtherSectionCardsState extends State<ParentsOtherSectionCards> {
  void _navigateToScreen(String id) {
    switch (id) {
      case "fees":
        Navigator.pushNamed(context, '/feesList');
        break;
      case "attendance":
        Navigator.pushNamed(context, '/Attendance');
        break;
      case "exams_report_card":
        Navigator.pushNamed(context, '/Exam');
        break;
      case "homework":
        Navigator.pushNamed(context, '/Homework');
        break;
      case "class_time_table":
        Navigator.pushNamed(context, '/ClassTimetable');
        break;
      case "complaint":
        Navigator.pushNamed(context, '/Behaviour');
        break;
      case "lesson_plan":
        Navigator.pushNamed(context, '/LessonPlan');
        break;
      case "syllabus_status":
        Navigator.pushNamed(context, "/SyllabusStatus");
        break;
      case "transport_routes":
        Navigator.pushNamed(context, "/studentTransportRoutes");
        break;
      case "hostel_rooms":
        Navigator.pushNamed(context, "/studentHostel");
        break;
      case "live_classes":
        Navigator.pushNamed(context, "/GmeetLiveClasses");
        break;
      case "apply_leave":
        Navigator.pushNamed(context, "/studentLeave");
        break;
      case "download_center":
        Navigator.pushNamed(context, "/DownloadCenter");
        break;
      case "documents":
        Navigator.pushNamed(context, "/Documents");
        break;
      case "library":
        Navigator.pushNamed(context, "/library");
        break;
      case "online_exam":
        Navigator.pushNamed(context, "/OnlineExamination");
        break;
      case "teacher_ratings":
        Navigator.pushNamed(context, "/studentTeachersList");
        break;
      case "classwork":
        Navigator.pushNamed(context, "/DailyAssignment");
        break;
      case "online_class":
        Navigator.pushNamed(context, "/OnlineCourse");
        break;
      default:
        // Handle unknown screens if necessary
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            shrinkWrap:
                true, // Important: This allows the GridView to take only the space it needs
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 15.0,
              mainAxisSpacing: 15.0,
            ),
            itemCount: widget.listOfDataSets.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _navigateToScreen(widget.listOfDataSets[index].id);
                },
                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: Colors.blueGrey,
                      width: 1.3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(5, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blueGrey,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Image.asset(
                              widget.listOfDataSets[index].thumbnail,
                              height: 30,
                              width: 30,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.listOfDataSets[index].name ==
                                  "Gmeet Live Classes"
                              ? "Live Classes"
                              : widget.listOfDataSets[index].name,
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class DataSet {
  final String id; 
  final String name;
  final String thumbnail;

  DataSet({required this.id, required this.name, required this.thumbnail});
}
