import 'package:drighna_ed_tech/models/student_visitor_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:drighna_ed_tech/widgets/student_visitor_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentVisitorBook extends StatefulWidget {
  const StudentVisitorBook({super.key});

  @override
  _StudentVisitorBookState createState() => _StudentVisitorBookState();
}

class _StudentVisitorBookState extends State<StudentVisitorBook> {
  late List<Visitor> visitors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVisitors();
  }

  Future<void> fetchVisitors() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String studentId = prefs.getString('studentId') ?? '';

    final response = await http.post(
      Uri.parse('$apiUrl${Constants.getVisitorsUrl}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Client-Service': Constants.clientService,
        'Auth-Key': Constants.authKey,
        'User-ID': prefs.getString('userId') ?? '',
        'Authorization': prefs.getString('accessToken') ?? '',
      },
      body: jsonEncode({
        'student_id': studentId,
        // You can add other body fields if needed
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('result')) {
        final List<dynamic> result = jsonResponse['result'];
        setState(() {
          visitors = result.map((data) => Visitor.fromJson(data)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Result key not found in response');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load visitors');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.student_visitor_book,
      ),
      body: isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : visitors.isEmpty
              ? const Center(child: Text('No Data found'))
              : ListView.builder(
                  itemCount: visitors.length,
                  itemBuilder: (context, index) {
                    Visitor visitor = visitors[index];
                    return VisitorCard(
                        visitor: visitor); // Use VisitorCard widget here
                  },
                ),
    );
  }
}
