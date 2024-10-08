import 'dart:convert';
import 'package:drighna_ed_tech/provider/attendance_provider.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:drighna_ed_tech/models/attendance_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentAttendance extends ConsumerStatefulWidget {
  const StudentAttendance({super.key});

  @override
  _StudentAttendanceState createState() => _StudentAttendanceState();
}

class _StudentAttendanceState extends ConsumerState<StudentAttendance> {
  List<dynamic> dayPeriodAttendance = [];
  bool isdaywise = false;
  DateTime? selectedDay;
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load attendance data for the current date when the widget is first created
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    loadPeriodwiseAttendance(formattedDate);
  }

  Future<void> loadPeriodwiseAttendance(String formattedDate) async {
    final prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String currentYear = now.year.toString();
    String currentMonth =
        now.month < 10 ? '0${now.month}' : now.month.toString();
    String studentId = prefs.getString('studentId') ?? '';

    Map<String, String> params = {
      'year': currentYear,
      'month': currentMonth,
      'student_id': studentId,
      'date': formattedDate,
    };

    String apiUrl = prefs.getString("apiUrl") ?? "";
    String url = "$apiUrl${Constants.getAttendanceUrl}";

    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        "Client-Service": Constants.clientService,
        "Auth-Key": Constants.authKey,
        "Content-Type": "application/json",
        'User-ID': prefs.getString('userId') ?? '',
        'Authorization': prefs.getString('accessToken') ?? '',
      },
      body: jsonEncode(params),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      setState(() {
        isdaywise = data['attendence_type'] == "0";
        dayPeriodAttendance = data['data'];
      });
    } else {
      throw Exception('Failed to load attendance');
    }
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<Map<DateTime, List<AttendanceData>>> attendanceDataAsyncValue =
        ref.watch(attendanceDataProvider);

    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.attendance,
      ),
      body: attendanceDataAsyncValue.when(
        data: (attendanceData) {
          // Calculate attendance summary
          var attendanceSummary =
              calculateAttendanceSummary(dayPeriodAttendance);

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        this.selectedDay = selectedDay;
                        this.focusedDay = focusedDay;
                      });
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(selectedDay);

                      loadPeriodwiseAttendance(formattedDate);
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        var dateKey = DateTime(date.year, date.month, date.day);
                        if (attendanceData[dateKey] != null) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: _buildMarkers(attendanceData[dateKey]!),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                  !isdaywise
                      ? dayPeriodAttendance.length == 0
                          ? const Center(
                              child: Text(
                                "Please select a day to view attendance",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            )
                          : Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: dayPeriodAttendance.length,
                                  itemBuilder: (context, index) {
                                    var attendance = dayPeriodAttendance[index];
                                    return ListTile(
                                      leading: Text(
                                          '${attendance['time_from']} - ${attendance['time_to']}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      title: Text(
                                        '${attendance['name']} (${attendance['type']})',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: _attendanceColor(
                                              attendance['type']),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Text(
                                //   'Total Attendance Percentage: ${attendanceSummary['percentage']!.toStringAsFixed(2)}%',
                                // ),
                                // Text(
                                //   'Times Late: ${attendanceSummary['lateCount']}',
                                // ),
                              ],
                            )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8.0),
                                  buildLegendItem(Colors.green, 'Present'),
                                  buildLegendItem(Colors.red, 'Absent'),
                                  buildLegendItem(Colors.yellow, 'Late'),
                                  buildLegendItem(Colors.orange, 'Half Day'),
                                  buildLegendItem(Colors.grey, 'Holiday'),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '${AppLocalizations.of(context)!.attendance_percentage}: ${attendanceSummary['percentage']!.toStringAsFixed(2)}%',
                                  ),
                                  Text(
                                    '${AppLocalizations.of(context)!.times_late}: ${attendanceSummary['lateCount']}',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: PencilLoaderProgressBar()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  List<Widget> _buildMarkers(List<AttendanceData> attendances) {
    return attendances.map((attendance) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _attendanceColor(attendance.type),
        ),
        width: 7.0,
        height: 7.0,
      );
    }).toList();
  }

  Widget buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Color _attendanceColor(String type) {
    switch (type) {
      case 'Present':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Late':
        return Colors.yellow;
      case 'Half Day':
        return Colors.orange;
      case 'Holiday':
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

  Map<String, double> calculateAttendanceSummary(
      List<dynamic> dayPeriodAttendance) {
    double presentPeriods = 0.0;
    double totalPeriods = 0.0;
    int lateCount = 0;

    dayPeriodAttendance.forEach((attendance) {
      if (attendance['type'] == 'Present' || attendance['type'] == 'Late') {
        presentPeriods += 1.0;
      } else if (attendance['type'] == 'Half Day') {
        presentPeriods += 0.5;
      }
      if (attendance['type'] != 'Holiday') {
        totalPeriods += 1.0;
      }
      if (attendance['type'] == 'Late') {
        lateCount += 1;
      }
    });

    double percentage =
        totalPeriods > 0 ? (presentPeriods / totalPeriods) * 100 : 0.0;

    return {
      'percentage': percentage,
      'lateCount': lateCount.toDouble(),
    };
  }
}
