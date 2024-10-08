import 'package:drighna_ed_tech/models/leave_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:drighna_ed_tech/widgets/widget_leave_application_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentAppyLeave extends StatefulWidget {
  const StudentAppyLeave({super.key});

  @override
  _StudentAppyLeaveState createState() => _StudentAppyLeaveState();
}

class _StudentAppyLeaveState extends State<StudentAppyLeave> {
  List<dynamic> _leaves = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaves();
  }

  Future<void> _fetchLeaves() async {
    final prefs = await SharedPreferences.getInstance();
    String studentId = prefs.getString("studentId") ?? "";

    // Create a map of the parameters
    Map<String, String> params = {
      "student_id": studentId,
    };

    // Convert the parameters to a JSON string
    String jsonBody = json.encode(params);

    getDataFromApi(jsonBody);
  }

  Future<void> getDataFromApi(String bodyParams) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId") ?? "";
    final accessToken = prefs.getString("accessToken") ?? "";
    final apiUrl = prefs.getString("apiUrl") ?? "";
    final url = Uri.parse('$apiUrl${Constants.getApplyLeaveUrl}');

    final headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": "application/json",
      "User-ID": userId,
      "Authorization": accessToken,
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: bodyParams,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> leavesJson = data['result_array'];

        // Create a list of LeaveApplications directly
        List<LeaveApplication> leaves =
            leavesJson.map((json) => LeaveApplication.fromJson(json)).toList();

        setState(() {
          _leaves = leaves; // Update _leaves with the new list
          _isLoading = false; // Set loading to false
        });
      } else {
        // Handle the error; maybe show an alert or a Snackbar
      }
    } catch (e) {
      // Handle any errors that occur during the request
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide the loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.leave_applications,
      ),
      body: _isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : RefreshIndicator(
              onRefresh: _fetchLeaves,
              child: _leaves.isNotEmpty
                  ? ListView.builder(
                      itemCount: _leaves.length,
                      itemBuilder: (context, index) {
                        final leave = _leaves[index];
                        // Use the separate LeaveApplicationCard widget
                        return LeaveApplicationCard(
                          applyDate: leave.applyDate,
                          fromDate: leave.fromDate,
                          toDate: leave.toDate,
                          reason: leave.reason,
                          status: leave.status,
                          leaveId: leave.id,
                          approvedDate: leave.approveDate,
                          documentFile: leave.documentFile,
                          onLeaveUpdated: _fetchLeaves, // Pass the callback
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                      "No data found",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/studentAddLeave').then((value) {
            if (value == true) {
              setState(() {
                _fetchLeaves();
              });
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
