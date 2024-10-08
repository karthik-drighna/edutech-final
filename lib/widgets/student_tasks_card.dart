import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drighna_ed_tech/models/student_task_model.dart';
import 'package:drighna_ed_tech/widgets/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/screens/students/student_task_edit.dart';
import 'package:drighna_ed_tech/utils/date_format_converter.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final ValueChanged<bool?> onToggleStatus;
  final Function(String) onTaskDelete;
  final VoidCallback onTaskUpdated; // Add this line

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleStatus,
    required this.onTaskDelete,
    required this.onTaskUpdated, // Add this line
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  Future<void> deleteTask(String taskId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString("apiUrl") ?? "";

    var url =
        "$apiUrl${Constants.deleteTaskUrl}"; // Your API endpoint for deleting a task

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
        body: jsonEncode({"task_id": taskId}),
      );

      if (response.statusCode == 200) {
        widget.onTaskDelete(taskId);

        SnackbarUtil.showSnackBar(context, 'Task successfully deleted',
            backgroundColor: Colors.green);
      } else {
        SnackbarUtil.showSnackBar(context, 'Failed to delete task',
            backgroundColor: Colors.red);
      }
    } catch (e) {
      SnackbarUtil.showSnackBar(
          context, 'An error occurred while deleting task',
          backgroundColor: Colors.red);
    }
  }

  void _confirmDeleteTask(String taskId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Do you really want to delete this task?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                deleteTask(taskId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      decoration: widget.task.isActive
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TaskEditScreen(task: widget.task),
                      ),
                    );
                    if (result == true) {
                      widget.onTaskUpdated(); // Call the onTaskUpdated callback
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _confirmDeleteTask(
                      widget.task.id), // Use the confirmation dialog
                ),
                Checkbox(
                  value: widget.task.isActive,
                  onChanged: (bool? newValue) {
                    if (newValue != null) {
                      widget.onToggleStatus(newValue);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              // 'Start',
              "",
              DateUtilities.formatStringDate(widget.task.startDate),
            ),
            // _buildInfoRow(
            //   'End',
            //   DateUtilities.formatStringDate(widget.task.endDate),
            // ),
            if (widget.task.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Description: ${widget.task.description}',
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
