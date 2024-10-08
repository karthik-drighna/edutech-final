import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/utils/date_format_converter.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CbseExaminationTimeTableScreen extends StatefulWidget {
  const CbseExaminationTimeTableScreen({super.key});

  @override
  _CbseExaminationTimeTableScreenState createState() =>
      _CbseExaminationTimeTableScreenState();
}

class _CbseExaminationTimeTableScreenState
    extends State<CbseExaminationTimeTableScreen> {
  List<CbseExamTimeTableModel> cbseExamList = [];

  @override
  void initState() {
    super.initState();
    getDataFromApi();
  }

  getDataFromApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString("apiUrl") ?? "";
    String url = apiUrl + Constants.cbseexamtimetableUrl;
    String studentSessionId =
        prefs.getString(Constants.student_session_id) ?? "";

    final headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": Constants.contentType,
      'User-ID': prefs.getString(Constants.userId) ?? "",
      'Authorization': prefs.getString("accessToken") ?? "",
    };

    try {
      final response = await http.post(Uri.parse(url),
          headers: headers,
          body: json.encode({"student_session_id": studentSessionId}));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<CbseExamTimeTableModel> loadedExams = [];
        for (var exam in data['result']) {
          final List<CbseTimetableModel> timetable = [];
          for (var tt in exam['time_table']) {
            timetable.add(CbseTimetableModel(
              subjectName: tt['subject_name'],
              subjectCode: tt['subject_code'],
              date: DateUtilities.formatStringDate(tt['date']),
              duration: tt['duration'],
              roomNo: tt['room_no'],
              timeFrom: DateUtilities.formatTimeString(tt['time_from']),
            ));
          }
          loadedExams.add(CbseExamTimeTableModel(
            name: exam['name'],
            timeTable: timetable,
          ));
        }
        setState(() {
          cbseExamList = loadedExams;
        });
      } else {
        print("Failed to load data");
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleText: "CBSE Time Table"),
      body: cbseExamList.isEmpty
          ? const Center(child: Text("No data available"))
          : ListView.builder(
              itemCount: cbseExamList.length,
              itemBuilder: (ctx, index) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          cbseExamList[index].name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            border: TableBorder.all(color: Colors.black),
                            columns: const [
                              DataColumn(label: Text('Subject')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Start Time')),
                              DataColumn(label: Text('Duration (minutes)')),
                              DataColumn(label: Text('Room No.')),
                            ],
                            rows: cbseExamList[index].timeTable.map((tt) {
                              return DataRow(cells: [
                                DataCell(Text(tt.subjectName)),
                                DataCell(Text(tt.date)),
                                DataCell(Text(tt.timeFrom)),
                                DataCell(Text(tt.duration)),
                                DataCell(Text(tt.roomNo)),
                              ]);
                            }).toList(),
                          ),
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

class CbseExamTimeTableModel {
  final String name;
  final List<CbseTimetableModel> timeTable;

  CbseExamTimeTableModel({required this.name, required this.timeTable});
}

class CbseTimetableModel {
  final String subjectName;
  final String subjectCode;
  final String date;
  final String duration;
  final String roomNo;
  final String timeFrom;

  CbseTimetableModel({
    required this.subjectName,
    required this.subjectCode,
    required this.date,
    required this.duration,
    required this.roomNo,
    required this.timeFrom,
  });
}
