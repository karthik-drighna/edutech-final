import 'package:drighna_ed_tech/models/homework_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/homework_card.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Homework extends StatefulWidget {
  const Homework({super.key});

  @override
  _HomeworkState createState() => _HomeworkState();
}

class _HomeworkState extends State<Homework>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<dynamic> homeworkList = [];
  bool isLoading = true;
  String status = "pending"; // default status
  String apiUrl = ''; // Add your API url
  String studentId = ''; // Add your studentId
  String accessToken = ''; // Add your accessToken
  String userId = ''; // Add your userId
  String dropdownValue = 'All';
  List<String> subjectList = ["All"];
  List<String> subjectidList = [""];
  String subjectId = "";
  String loginType = "student";
  // Initialize more fields if necessary

  @override
  void initState() {
    super.initState();
    getScannerDataFromApi();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    fetchHomework();
  }

  Future<void> getScannerDataFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    apiUrl = prefs.getString('apiUrl') ?? '';
    studentId = prefs.getString('studentId') ?? '';
    accessToken = prefs.getString('accessToken') ?? '';
    userId = prefs.getString('userId') ?? '';

    var url = Uri.parse("$apiUrl${Constants.getstudentsubjectUrl}");

    try {
      var response = await http.post(
        url,
        headers: {
          'Client-Service': Constants.clientService,
          'Auth-Key': Constants.authKey,
          'Content-Type': Constants.contentType,
          'User-ID': userId,
          'Authorization': accessToken,
        },
        body: jsonEncode({
          'student_id': studentId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          List<dynamic> subjectListData = data['subjectlist'] ?? [];

          for (var subject in subjectListData) {
            String name = "${subject['name']} (${subject['code']})";
            String id = subject['subject_group_subjects_id'].toString();
            subjectList.add(name);
            subjectidList.add(id);
          }
        });
      } else {
        print('Failed to load scanner data');
      }
    } catch (e) {
      print("Error fetching scanner data: $e");
    }
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        isLoading = true; // Show loader
      });
      switch (_tabController.index) {
        case 0:
          status = "pending";
          break;
        case 1:
          status = "submitted";
          break;
        case 2:
          status = "evaluated";
          break;
      }
      fetchHomework();
    }
  }

  Future<void> fetchHomework() async {
    final prefs = await SharedPreferences.getInstance();
    studentId = prefs.getString('studentId') ?? studentId;
    loginType = prefs.getString(Constants.loginType) ?? "student";

    final bodyParams = {
      'student_id': studentId,
      'homework_status': status,
      'subject_group_subject_id': subjectId
    };

    getDataFromApi(bodyParams);
  }

  Future<void> getDataFromApi(bodyParams) async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    apiUrl = prefs.getString('apiUrl') ?? apiUrl;
    studentId = prefs.getString('studentId') ?? studentId;
    accessToken = prefs.getString('accessToken') ?? accessToken;
    userId = prefs.getString('userId') ?? userId;

    var response = await http.post(
      Uri.parse(apiUrl + Constants.getHomeworkUrl),
      headers: {
        'Client-Service': Constants.clientService,
        'Auth-Key': Constants.authKey,
        'Content-Type': 'application/json',
        'User-ID': userId,
        'Authorization': accessToken,
      },
      body: jsonEncode(bodyParams),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        homeworkList = data['homeworklist'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.home_work,
      ),
      body: isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                          width: screenWidth * 0.5,
                          child: const Text(
                            "Your Homework is here!",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.clip,
                          )),
                      const Spacer(),
                      Image.asset(
                        "assets/homeworkpage.png",
                        height: 80,
                        width: screenWidth * 0.44,
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors
                              .grey[350], // Background color of the Container
                          borderRadius: BorderRadius.circular(
                              20), // Rounded corners for the Container
                        ),
                        height: 40,
                        width: screenWidth * 0.68,
                        child: TabBar(
                          labelPadding: EdgeInsets.zero,
                          controller: _tabController,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.black,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                20), // Creates the rounded corners
                            color: Colors.red, // Background color
                          ),
                          tabs: const [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Pending'),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Submitted'),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Evaluated'),
                            )
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(5),
                        width: screenWidth * 0.26,
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey, // Color of the border
                            width: 1, // Width of the border
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: dropdownValue,
                          icon: const Icon(Icons.arrow_drop_down),
                          elevation: 10,
                          style: const TextStyle(color: Colors.black),
                          onChanged: (String? newValue) async {
                            setState(() {
                              dropdownValue = newValue!;
                              subjectId = subjectidList[
                                  subjectList.indexOf(dropdownValue)];
                              fetchHomework();
                            });
                            final prefs = await SharedPreferences.getInstance();
                            studentId =
                                prefs.getString('studentId') ?? studentId;

                            final bodyParams = {
                              'student_id': studentId,
                              'homework_status': status,
                              'subject_group_subject_id': subjectId
                            };

                            getDataFromApi(bodyParams);
                          },
                          items: subjectList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        RefreshIndicator(
                          onRefresh: fetchHomework,
                          child: homeworkList.isNotEmpty
                              ? ListView.builder(
                                  itemCount: homeworkList.length,
                                  itemBuilder: (context, index) {
                                    var homeworkItem = homeworkList[index];
                                    var homeworkModel = HomeworkModel(
                                      id: homeworkItem['id'],
                                      marksObtained:
                                          homeworkItem['evaluation_marks'],
                                      title:
                                          '${homeworkItem['subject_name']} (${homeworkItem['subject_code']})',
                                      status: homeworkItem['status'],
                                      homeworkDate:
                                          homeworkItem['homework_date'],
                                      submissionDate:
                                          homeworkItem['submit_date'],
                                      createdBy:
                                          '${homeworkItem['created_by_name']} (${homeworkItem['created_by_employee_id']})',
                                      evaluatedBy: homeworkItem['evaluated_by'],
                                      evaluationDate:
                                          homeworkItem['evaluation_date'],
                                      marks: double.tryParse(
                                              homeworkItem['marks']
                                                  .toString()) ??
                                          0.0,
                                      note: homeworkItem['note'],
                                      description: homeworkItem['description'],
                                      homeworkDocument:
                                          homeworkItem['document'],
                                    );
                                    return HomeworkCard(
                                        homework: homeworkModel,
                                        loginType: loginType);
                                  },
                                )
                              : const Center(
                                  child: Text("No data found",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                        ),
                        RefreshIndicator(
                          onRefresh: fetchHomework,
                          child: homeworkList.isNotEmpty
                              ? ListView.builder(
                                  itemCount: homeworkList.length,
                                  itemBuilder: (context, index) {
                                    var homeworkItem = homeworkList[index];
                                    var homeworkModel = HomeworkModel(
                                      marksObtained:
                                          homeworkItem['evaluation_marks'],
                                      title:
                                          '${homeworkItem['subject_name']} (${homeworkItem['subject_code']})',
                                      status: homeworkItem['status'],
                                      homeworkDate:
                                          homeworkItem['homework_date'],
                                      submissionDate:
                                          homeworkItem['submit_date'],
                                      createdBy:
                                          '${homeworkItem['created_by_name']} (${homeworkItem['created_by_employee_id']})',
                                      evaluatedBy: homeworkItem['evaluated_by'],
                                      evaluationDate:
                                          homeworkItem['evaluation_date'],
                                      marks: double.tryParse(
                                              homeworkItem['marks']
                                                  .toString()) ??
                                          0.0,
                                      note: homeworkItem['note'],
                                      description: homeworkItem['description'],
                                      id: homeworkItem['id'],
                                      homeworkDocument:
                                          homeworkItem['document'],
                                    );
                                    return HomeworkCard(
                                        homework: homeworkModel,
                                        loginType: loginType);
                                  },
                                )
                              : const Center(
                                  child: Text("No data found",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                        ),
                        RefreshIndicator(
                          onRefresh: fetchHomework,
                          child: homeworkList.isNotEmpty
                              ? ListView.builder(
                                  itemCount: homeworkList.length,
                                  itemBuilder: (context, index) {
                                    var homeworkItem = homeworkList[index];
                                    var homeworkModel = HomeworkModel(
                                      marksObtained:
                                          homeworkItem['evaluation_marks'],
                                      title:
                                          '${homeworkItem['subject_name']} (${homeworkItem['subject_code']})',
                                      status: homeworkItem['status'],
                                      homeworkDate:
                                          homeworkItem['homework_date'],
                                      submissionDate:
                                          homeworkItem['submit_date'],
                                      createdBy:
                                          '${homeworkItem['created_by_name']} (${homeworkItem['created_by_employee_id']})',
                                      evaluatedBy: homeworkItem['evaluated_by'],
                                      evaluationDate:
                                          homeworkItem['evaluation_date'],
                                      marks: double.tryParse(
                                              homeworkItem['marks']
                                                  .toString()) ??
                                          0.0,
                                      note: homeworkItem['note'],
                                      description: homeworkItem['description'],
                                      id: homeworkItem['id'],
                                      homeworkDocument:
                                          homeworkItem['document'],
                                    );
                                    return HomeworkCard(
                                        homework: homeworkModel,
                                        loginType: loginType);
                                  },
                                )
                              : const Center(
                                  child: Text("No data found",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
