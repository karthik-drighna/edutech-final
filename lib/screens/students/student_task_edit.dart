import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drighna_ed_tech/models/student_task_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TaskEditScreen extends StatefulWidget {
  final Task task;

  const TaskEditScreen({super.key, required this.task});

  @override
  _TaskEditScreenState createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _dateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(widget.task.startDate)));
  }

  Future<void> _updateTask(String taskId, String title, String date) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString("apiUrl") ?? "";

    var url =
        apiUrl + Constants.createTaskUrl; // Update with the actual endpoint.

    Map<String, dynamic> updateParams = {
      "user_id": prefs.getString("userId") ?? "",
      "task_id": taskId,
      "event_title": title,
      "date": date, // Format this to match your API requirements.
    };

    // Check for connectivity before attempting the API call
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      SnackbarUtil.showSnackBar(context, 'No internet connection',
          backgroundColor: Colors.red);

      return;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': Constants.contentType,
          'Client-Service': Constants.clientService,
          'Auth-Key': Constants.authKey,
          'User-ID': prefs.getString(Constants.userId) ?? "",
          'Authorization': prefs.getString("accessToken") ?? "",
        },
        body: jsonEncode(updateParams),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(true); // Pass back true to indicate success
      } else {
        SnackbarUtil.showSnackBar(context, 'Failed to update task',
            backgroundColor: Colors.red);
      }
    } catch (e) {
      SnackbarUtil.showSnackBar(
          context, 'An error occurred while updating task',
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleText: 'Edit Task'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate:
                        DateFormat('yyyy-MM-dd').parse(_dateController.text),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    _dateController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateTask(widget.task.id, _titleController.text,
                        _dateController.text);
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
