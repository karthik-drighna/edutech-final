import 'dart:convert';
import 'package:drighna_ed_tech/models/gmeet_live_class_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/gmeet_live_class_card.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentGmeetLiveClasses extends StatefulWidget {
  const StudentGmeetLiveClasses({super.key});

  @override
  _StudentGmeetLiveClassesState createState() =>
      _StudentGmeetLiveClassesState();
}

class _StudentGmeetLiveClassesState extends State<StudentGmeetLiveClasses> {
  List<dynamic> liveClasses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLiveClasses();
  }

  Future<void> loadLiveClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('studentId') ?? '';
    final apiUrl = prefs.getString('apiUrl') ?? '';
    final accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.post(
      Uri.parse('$apiUrl${Constants.gmeetclassesUrl}'),
      headers: {
        'Client-Service': Constants.clientService,
        'Auth-Key': Constants.authKey,
        'Content-Type': 'application/json; charset=UTF-8',
        'User-ID': prefs.getString('userId') ?? '',
        'Authorization': accessToken,
      },
      body: jsonEncode({'student_id': studentId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
        liveClasses = json.decode(response.body)['live_classes'];
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load live classes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.live_classes,
      ),
      body: isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : liveClasses.isEmpty
              ? const Center(child: Text('No data found'))
              : ListView.builder(
                  itemCount: liveClasses.length,
                  itemBuilder: (context, index) {
                    final item = LiveClass.fromJson(liveClasses[index]);
                    return LiveClassCard(liveClass: item);
                  },
                ),
    );
  }
}
