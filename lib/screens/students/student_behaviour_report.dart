import 'dart:convert';
import 'package:drighna_ed_tech/models/behaviour_record_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/behaviour_record_widget.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentBehaviourReport extends StatefulWidget {
  const StudentBehaviourReport({super.key});

  @override
  _StudentBehaviourReportState createState() => _StudentBehaviourReportState();
}

class _StudentBehaviourReportState extends State<StudentBehaviourReport> {
  List<BehaviorRecord> behaviorRecords = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loaddata();
  }

  Future<void> loaddata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String studentId = prefs.getString('studentId') ?? '';
    String userId = prefs.getString('userId') ?? '';
    String accessToken = prefs.getString('accessToken') ?? '';

    final bodyParams = {
      "student_id": studentId,
    };

    final url = Uri.parse('$apiUrl${Constants.getstudentbehaviourUrl}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Client-Service': Constants.clientService,
          'Auth-Key': Constants.authKey,
          'User-ID': userId,
          'Authorization': accessToken,
        },
        body: json.encode(bodyParams),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final setting = jsonResponse['behaviour_settings'];
        if (setting['comment_option'] == '') {
          // Handle arrays
        } else {
          // Handle arrays
        }

        final dataArray = jsonResponse['assigned_incident'];

        if (dataArray.isNotEmpty) {
          // Clear previous data before parsing
          behaviorRecords.clear();

          // Parse the JSON response into BehaviorRecord instances
          for (var data in dataArray) {
            behaviorRecords.add(BehaviorRecord.fromJson(data));
          }

          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.student_behaviour_report,
      ),
      body: isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : behaviorRecords.isEmpty
              ? const Center(child: Text('No data available'))
              : ListView.builder(
                  itemCount: behaviorRecords.length,
                  itemBuilder: (context, index) {
                    return BehaviorRecordWidget(
                        behaviorRecord: behaviorRecords[index]);
                  },
                ),
    );
  }
}
