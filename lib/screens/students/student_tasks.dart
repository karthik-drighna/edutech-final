import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drighna_ed_tech/models/student_task_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:drighna_ed_tech/widgets/snackbar_message.dart';
import 'package:drighna_ed_tech/widgets/student_tasks_card.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentTasks extends StatefulWidget {
  const StudentTasks({super.key});

  @override
  _StudentTasksState createState() => _StudentTasksState();
}

class _StudentTasksState extends State<StudentTasks> {
  bool isLoading = false;
  List<Task> tasks = [];
  TextEditingController titleController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String taskId = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void removeTaskFromList(String taskId) {
    setState(() {
      tasks.removeWhere((task) => task.id == taskId);
    });
  }

  Future<void> loadData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId') ?? '';

      Map<String, dynamic> params = {
        'user_id': userId,
      };
      fetchTasks(params);
    } else {
      SnackbarUtil.showSnackBar(context, 'No internet connection',
          backgroundColor: Colors.red);
    }
  }

  Future<void> fetchTasks(params) async {
    setState(() => isLoading = true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('userId') ?? '';
    final String apiUrl = prefs.getString('apiUrl') ?? '';
    final String url = "$apiUrl${Constants.getTaskUrl}";

    Map<String, String> headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": "application/json",
      "User-ID": userId,
      "Authorization": prefs.getString('accessToken') ?? '',
    };

    Map<String, String> body = {
      "user_id": userId,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          tasks =
              List<Task>.from(data['tasks'].map((task) => Task.fromJson(task)));
        });
      } else {
        print("Error fetching tasks: ${response.body}");
      }
    } catch (e) {
      print("Network error occurred: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> addTask(String title, String date) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';
    String apiUrl = prefs.getString('apiUrl') ?? '';

    String formattedDate = "${selectedDate.toLocal()}".split(' ')[0];

    Map<String, dynamic> taskData = {
      'user_id': userId,
      'event_title': title,
      'task_id': taskId,
      'date': formattedDate,
    };

    String url =
        "$apiUrl${Constants.createTaskUrl}"; // Replace with actual endpoint

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Client-Service": Constants.clientService,
          "Auth-Key": Constants.authKey,
          "Content-Type": "application/json",
          "User-ID": prefs.getString('userId') ?? '',
          "Authorization": prefs.getString('accessToken') ?? '',
        },
        body: jsonEncode(taskData),
      );

      if (response.statusCode == 200) {
        setState(() {
          loadData();
        });

        print("Task created: ${response.body}");
      } else {
        print("Error creating task: ${response.body}");
      }
    } catch (e) {
      print("Network error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.student_tasks,
      ),
      body: isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : tasks.isEmpty
              ? const Center(child: Text('No tasks added'))
              : RefreshIndicator(
                  onRefresh: loadData,
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      Task task = tasks[index];
                      return TaskCard(
                        task: task,
                        onToggleStatus: (value) {
                          toggleTaskStatus(task, value);
                        },
                        onTaskDelete: removeTaskFromList,
                        onTaskUpdated: loadData, // Add this line
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  title = value;
                },
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    String formattedDate =
                        "${pickedDate.toLocal()}".split(' ')[0];
                    dateController.text = formattedDate;
                  }
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                titleController.clear();
                dateController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                addTask(title, dateController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void toggleTaskStatus(Task task, bool? value) {
    if (value != null) {
      setState(() {
        tasks = tasks.map((t) {
          if (t.id == task.id) {
            return t.copyWith(isActive: value);
          }
          return t;
        }).toList();
        // Update the task status on the server here
      });
    }
  }
}
