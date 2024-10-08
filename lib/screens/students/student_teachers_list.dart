import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:drighna_ed_tech/models/teacher_and_subject_model.dart';
import 'package:drighna_ed_tech/widgets/teacher_rating_card.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentTeachersList extends StatefulWidget {
  const StudentTeachersList({super.key});

  @override
  _StudentTeachersListState createState() => _StudentTeachersListState();
}

class _StudentTeachersListState extends State<StudentTeachersList> {
  late Future<List<Teacher>> futureTeachers;
  String loginType = "";

  @override
  void initState() {
    super.initState();
    futureTeachers = fetchTeachers();
    chechLoginType();
  }

  chechLoginType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loginType = prefs.getString(Constants.loginType) ?? "";
    print(
        "parent login type?????????????????++++++++++++++++++++++>>>>>>>>>>>>>>" +
            loginType);
  }

  Future<void> refreshTeachers() async {
    setState(() {
      futureTeachers = fetchTeachers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          CustomAppBar(titleText: AppLocalizations.of(context)!.teachers_list),
      body: FutureBuilder<List<Teacher>>(
        future: futureTeachers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: PencilLoaderProgressBar());
          } else if (snapshot.hasError) {
            return const Center(
                child:
                    Text('No Data found')); //Text('Error: ${snapshot.error}')
          } else {
            return RefreshIndicator(
              onRefresh: refreshTeachers,
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Teacher teacher = snapshot.data![index];
                  return TeacherCard(
                    loginType: loginType,
                    teacher: teacher,
                    onRatingSubmitted: refreshTeachers,
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

Future<List<Teacher>> fetchTeachers() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String apiUrl = prefs.getString('apiUrl') ?? '';

  final response = await http.post(
    Uri.parse("$apiUrl${Constants.getTeacherListUrl}"),
    headers: {
      'Content-Type': 'application/json',
      'Client-Service': Constants.clientService,
      'Auth-Key': Constants.authKey,
      'User-ID': prefs.getString(Constants.userId) ?? '',
      'Authorization': prefs.getString('accessToken') ?? '',
    },
    body: jsonEncode({
      'class_id': prefs.getString('classId') ?? '',
      'section_id': prefs.getString('sectionId') ?? '',
      'user_id': prefs.getString('userId') ?? '',
    }),
  );

  if (response.statusCode == 200) {
    List<Teacher> teachers = [];
    Map<String, dynamic> data = json.decode(response.body)['result_list'];
    data.forEach((key, value) {
      teachers.add(Teacher.fromJson(value));
    });
    return teachers;
  } else {
    throw Exception('Failed to load teachers');
  }
}
