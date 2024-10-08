import 'dart:convert';
import 'package:drighna_ed_tech/models/exam_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final examinationListProvider =
    FutureProvider.family<List<Examination>, String>((ref, studentId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String apiUrl = prefs.getString('apiUrl') ?? '';
  String userId = prefs.getString('userId') ?? '';
  String accessToken = prefs.getString('accessToken') ?? '';

  var url = Uri.parse('$apiUrl${Constants.getExamListUrl}');

  var response = await http.post(url,
      headers: {
        "Client-Service": Constants.clientService,
        "Auth-Key": Constants.authKey,
        "Content-Type": "application/json",
        "User-ID": userId,
        "Authorization": accessToken,
      },
      body: json.encode({"student_id": studentId}));

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body) as Map<String, dynamic>;
    var examsData = jsonResponse['examSchedule'] as List;
    return examsData.map((json) => Examination.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load exams');
  }
});
