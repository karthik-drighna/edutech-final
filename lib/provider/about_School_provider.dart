import 'dart:convert';
import 'package:drighna_ed_tech/models/about_school_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final aboutSchoolProvider =
    StateNotifierProvider<AboutSchoolNotifier, AboutSchoolData?>((ref) {
  return AboutSchoolNotifier();
});

// StateNotifier to fetch and hold the about school data
class AboutSchoolNotifier extends StateNotifier<AboutSchoolData?> {
  AboutSchoolNotifier() : super(null);

  Future fetchAboutSchoolData() async {
    final prefs = await SharedPreferences.getInstance();
    // Assume 'apiUrl' and 'aboutSchoolEndpoint' are keys in your constants where you store the respective strings
    final apiUrl = prefs.getString(Constants.apiUrl) ?? "";

    String url = "$apiUrl${Constants.getSchoolDetailsUrl}";

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Client-Service': Constants.clientService,
          'Auth-Key': Constants.authKey,
          'Content-Type': 'application/json',
          'User-ID': prefs.getString(Constants.userId) ?? "",
          'Authorization': prefs.getString("accessToken") ?? "",
        },
      );
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data != null) {
        state = AboutSchoolData.fromJson(data);
      } else {
        // Handle the case when the server did not return a "200 OK" response
        throw Exception('Failed to load about school details');
      }
    } catch (e) {
      // Handle any exceptions when calling the endpoint
      throw Exception('Failed to load about school details: $e');
    }
  }
}
