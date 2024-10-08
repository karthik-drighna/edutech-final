import 'dart:convert';
import 'package:drighna_ed_tech/models/student_profile_data.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final decoratorProvider =
    FutureProvider.autoDispose<Map<String, String>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  // Create a map and populate it with user data from SharedPreferences
  return {
    'userName': prefs.getString(Constants.userName) ?? "",
    'admissionNo': prefs.getString(Constants.admission_no) ?? "",
    'userImage': prefs.getString(Constants.userImage) ?? "",
    'classSection': prefs.getString(Constants.classSection) ?? "",
    'studentName': prefs.getString("studentName") ?? "",
    'loginType': prefs.getString(Constants.loginType) ?? "",
    'hasMultipleChild': prefs.getBool('hasMultipleChild').toString(),
    'primaryColor': prefs.getString(Constants.primaryColour) ?? "",
    'secondaryColor': prefs.getString(Constants.secondaryColour) ?? "",
    'domainUrl': prefs.getString(Constants.appDomain) ?? ""
  };
});

// Provider to manage fetching and holding the student data
final studentProfileProvider =
    StateNotifierProvider<StudentProfileNotifier, StudentProfile?>((ref) {
  return StudentProfileNotifier();
});

class StudentProfileNotifier extends StateNotifier<StudentProfile?> {
  StudentProfileNotifier() : super(null);

  Future<void> fetchStudentProfile(String apiUrl, String bodyParams) async {
    String url = apiUrl +
        Constants.getStudentProfileUrl; // Replace with your API endpoint

    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Client-Service': Constants.clientService,
          'Auth-Key': Constants.authKey,
          'Content-Type': 'application/json; charset=UTF-8',
          'User-ID': prefs.getString("userId") ?? "",
          'Authorization': prefs.getString("accessToken") ?? "",
        },
        body: bodyParams,
      );
      final data = json.decode(response.body);

      prefs.setString(
          Constants.admission_no, data['student_result']['admission_no']);

      if (response.statusCode == 200 && data != null) {
        state = StudentProfile.fromJson(data);
      } else {
        // Handle the case when the server did not return a "200 OK" response
        throw Exception('Failed to load student profile');
      }
    } catch (e) {
      // Handle any exceptions when calling the endpoint
      throw Exception('Failed to load student profile: $e');
    }
  }
}
