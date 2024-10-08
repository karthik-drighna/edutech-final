// Provider for fetching and storing attendance data
import 'dart:convert';

import 'package:drighna_ed_tech/models/attendance_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final attendanceDataProvider =
    FutureProvider.autoDispose<Map<DateTime, List<AttendanceData>>>(
        (ref) async {
  final prefs = await SharedPreferences.getInstance();
  DateTime now = DateTime.now();
  String currentYear = now.year.toString();
  String currentMonth = now.month < 10 ? '0${now.month}' : now.month.toString();
  String studentId = prefs.getString('studentId') ?? '';

  Map<String, String> params = {
    'year': currentYear,
    'month': currentMonth,
    'student_id': studentId,
    'date': DateFormat('yyyy-MM-dd').format(now),
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

    return _processAttendanceData(data);
  } else {
    throw Exception('Failed to load attendance');
  }
});

// Method for processing attendance data
Map<DateTime, List<AttendanceData>> _processAttendanceData(dynamic data) {
  var newAttendanceData = <DateTime, List<AttendanceData>>{};

  if (data['attendence_type'] == "0") {
    List<dynamic> responseData = data['data'];
    for (var attendance in responseData) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(attendance['date']);
      String type = attendance['type'];
      DateTime dateKey = DateTime(date.year, date.month, date.day);
      newAttendanceData
          .putIfAbsent(dateKey, () => [])
          .add(AttendanceData(date: date, type: type));
    }
  }
  return newAttendanceData;
}
