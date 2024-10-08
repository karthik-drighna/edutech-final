import 'dart:convert';
import 'package:drighna_ed_tech/models/hostel_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/hostel_card.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentHostel extends StatefulWidget {
  const StudentHostel({super.key});

  @override
  _StudentHostelState createState() => _StudentHostelState();
}

class _StudentHostelState extends State<StudentHostel> {
  List<Hostel> hostels = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchHostels();
  }

  Future<void> fetchHostels() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    String studentId = prefs.getString('studentId') ?? '';
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String url = "$apiUrl${Constants.getHostelListUrl}";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Client-Service": Constants.clientService,
          "Auth-Key": Constants.authKey,
          "Content-Type": "application/json",
          "User-ID": prefs.getString('userId') ?? '',
          "Authorization": prefs.getString('accessToken') ?? '',
        },
        body: jsonEncode({
          "student_id": studentId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List<dynamic> hostelArray = data['hostelarray'];

        setState(() {
          hostels = hostelArray.map((json) => Hostel.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // Handle server error.
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle network error.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          titleText: AppLocalizations.of(context)!.student_hostel,
        ),
        body: isLoading
            ? const Center(child: PencilLoaderProgressBar())
            : hostels.isNotEmpty
                ? ListView.builder(
                    itemCount: hostels.length,
                    itemBuilder: (context, index) {
                      return HostelListItem(hostel: hostels[index]);
                    },
                  )
                : const Center(
                    child: Text(
                    "No data found",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )));
  }
}
