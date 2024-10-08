import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:drighna_ed_tech/models/syllabus_subject_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';

final syllabusProvider = FutureProvider<List<SyllabusSubject>>((ref) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String apiUrl = prefs.getString('apiUrl') ?? '';
  String studentId = prefs.getString('studentId') ?? '';
  var url = Uri.parse('$apiUrl${Constants.getsyllabussubjectsUrl}');

  Map<String, dynamic> params = {
    "student_id": studentId,
  };

  var response = await http.post(url,
      headers: {
        "Client-Service": Constants.clientService,
        "Auth-Key": Constants.authKey,
        "Content-Type": "application/json",
        'User-ID': prefs.getString('userId') ?? '',
        'Authorization': prefs.getString('accessToken') ?? '',
      },
      body: json.encode(params));

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    List<dynamic> subjectsData = data['subjects'];
    return subjectsData.map((json) => SyllabusSubject.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load syllabus');
  }
});
