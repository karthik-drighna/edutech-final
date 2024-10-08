import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drighna_ed_tech/models/syllabus_subject_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:drighna_ed_tech/widgets/syllabus_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentSyllabusStatus extends StatefulWidget {
  const StudentSyllabusStatus({super.key});

  @override
  _StudentSyllabusStatusState createState() => _StudentSyllabusStatusState();
}

class _StudentSyllabusStatusState extends State<StudentSyllabusStatus> {
  bool isLoading = false;
  List<SyllabusSubject> subjects = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String studentId = prefs.getString('studentId') ?? '';

      Map<String, dynamic> params = {
        "student_id": studentId,
      };
      await getDataFromApi(params);
    } else {
      // No internet connection
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No Internet connection"),
        ),
      );
      print('No internet connection');
    }
  }

  Future<void> getDataFromApi(Map<String, dynamic> params) async {
    setState(() {
      isLoading = true;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String apiUrl = prefs.getString('apiUrl') ?? '';

      var url = Uri.parse('$apiUrl${Constants.getsyllabussubjectsUrl}');

      var response = await http.post(url,
          headers: {
            "Client-Service": Constants.clientService,
            "Auth-Key": Constants.authKey,
            "Content-Type": "application/json; charset=utf-8",
            'User-ID': prefs.getString('userId') ?? '',
            'Authorization': prefs.getString('accessToken') ?? '',
          },
          body: json.encode(params));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var subjectsData = data['subjects'] as List;
        setState(() {
          isLoading = false;

          subjects = subjectsData
              .map((json) => SyllabusSubject.fromJson(json))
              .toList();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("Error Loading Data"),
      //   ),
      // );
      // print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.syllabus_status,
      ),
      body: isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : subjects.isEmpty
              ? const Center(child: Text('No data found'))
              : RefreshIndicator(
                  onRefresh: loadData,
                  child: ListView.builder(
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      return SyllabusCard(subject: subjects[index]);
                    },
                  ),
                ),
    );
  }
}
