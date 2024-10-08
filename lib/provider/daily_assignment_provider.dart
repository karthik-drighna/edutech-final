import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drighna_ed_tech/utils/constants.dart';

final assignmentsProvider =
    StateNotifierProvider<AssignmentsNotifier, List<dynamic>>(
        (ref) => AssignmentsNotifier());

class AssignmentsNotifier extends StateNotifier<List<dynamic>> {
  AssignmentsNotifier() : super([]);

  Future<void> fetchAssignments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String studentId = prefs.getString('studentId') ?? '';

    var url = Uri.parse('$apiUrl/${Constants.getdailyassignmentUrl}');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Client-Service': Constants.clientService,
        'Auth-Key': Constants.authKey,
      },
      body: jsonEncode(<String, String>{
        'student_id': studentId,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      state = data['dailyassignment'];
    } else {
      // Handle error or inform the user
      // For simplicity, we just print the error here
    }
  }

  Future<void> deleteAssignment(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String url =
        '$apiUrl${Constants.deletedailyassignmentUrl}'; // Adjust URL as needed

    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Client-Service': Constants.clientService,
        'Auth-Key': Constants.authKey,
        // Add any other headers you need
      },
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode == 200) {
      // Optionally handle response

      fetchAssignments(); // Refresh the list after deletion
    } else {
      // Handle error
    }
  }
}
