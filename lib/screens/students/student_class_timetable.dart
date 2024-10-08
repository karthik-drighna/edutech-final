import 'package:drighna_ed_tech/models/class_time_table_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentClassTimetable extends StatefulWidget {
  const StudentClassTimetable({super.key});

  @override
  _StudentClassTimetableState createState() => _StudentClassTimetableState();
}

class _StudentClassTimetableState extends State<StudentClassTimetable> {
  List<ClassTimetable> timetable = [];
  Map<String, List<ClassTimetable>> weeklyTimetable = {};

  @override
  void initState() {
    super.initState();
    fetchTimetable();
  }

  void fetchTimetable() async {
    final prefs = await SharedPreferences.getInstance();
    String apiUrl =
        "${prefs.getString("apiUrl")}${Constants.getClassScheduleUrl}";
    String studentId = prefs.getString("studentId") ?? "";
    String accessToken = prefs.getString("accessToken") ?? "";

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Client-Service': Constants.clientService,
        'Auth-Key': Constants.authKey,
        'User-ID': prefs.getString("userId") ?? "",
        'Authorization': accessToken,
      },
      body: jsonEncode({"student_id": studentId}),
    );

    if (response.statusCode == 200) {
      var decodedResponse = jsonDecode(response.body);

      Map<String, dynamic> timetableData = decodedResponse['timetable'];
      if (timetableData != null) {
        setState(() {
          weeklyTimetable = timetableData.map((day, classes) {
            return MapEntry(
                day,
                (classes as List)
                    .map((item) => ClassTimetable(
                          subjectName: item['subject_name'] as String,
                          time: "${item['time_from']} - ${item['time_to']}",
                          roomNo: item['room_no'].toString(),
                        ))
                    .toList());
          });
        });
      } else {
        print("Timetable data is null");
      }
    } else {
      print("Failed to load timetable");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.class_time_table,
      ),
      body: ListView.builder(
        itemCount: weeklyTimetable.length,
        itemBuilder: (context, index) {
          String day = weeklyTimetable.keys.elementAt(index);
          return Card(
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    day,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Table(
                    border: TableBorder.all(),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(3),
                      2: FlexColumnWidth(1),
                    },
                    children: [
                      const TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Time",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Subject",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Room No.",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      ...weeklyTimetable[day]!.map((classTimetable) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(classTimetable.time),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(classTimetable.subjectName),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(classTimetable.roomNo),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
