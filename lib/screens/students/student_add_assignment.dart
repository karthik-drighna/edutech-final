import 'dart:convert';
import 'dart:io';
import 'package:drighna_ed_tech/provider/daily_assignment_provider.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart'; // Import the path package

class StudentAddAssignment extends ConsumerStatefulWidget {
  @override
  _StudentAddAssignmentState createState() => _StudentAddAssignmentState();
}

class _StudentAddAssignmentState extends ConsumerState<StudentAddAssignment> {
  File? _selectedFile;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String selectedSubject = "Select";
  String subjectId = "";
  List<String> subjectList = ["Select"];
  List<String> subjectidList = [""];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getScannerDataFromApi();
  }

  Future<void> getScannerDataFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String studentId = prefs.getString('studentId') ?? '';
    String accessToken = prefs.getString('accessToken') ?? '';
    String userId = prefs.getString('userId') ?? '';

    var url = Uri.parse("$apiUrl${Constants.getstudentsubjectUrl}");

    try {
      var response = await http.post(
        url,
        headers: {
          'Client-Service': Constants.clientService,
          'Auth-Key': Constants.authKey,
          'Content-Type': 'application/json',
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

  Future<void> _selectFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No file selected.'),
      ));
    }
  }

  Future<void> _uploadAssignment(context) async {
    if (selectedSubject == "Select") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a subject.'),
      ));
      return;
    }

    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter title and description.'),
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String studentId = prefs.getString('studentId') ?? '';
    String url = '$apiUrl${Constants.addeditdailyassignmentUrl}';

    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['student_id'] = studentId
      ..fields['title'] = titleController.text
      ..fields['description'] = descriptionController.text
      ..fields['subject'] = subjectId;

    if (_selectedFile != null) {
      String mimeType =
          lookupMimeType(_selectedFile!.path) ?? 'application/octet-stream';
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _selectedFile!.path,
        contentType: MediaType.parse(mimeType),
      ));
    }

    request.headers.addAll({
      'Client-Service': Constants.clientService,
      'Auth-Key': Constants.authKey,
      'User-ID': prefs.getString('userId') ?? '',
      'Authorization': prefs.getString('accessToken') ?? '',
    });

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['status'] == "1") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Assignment uploaded successfully.')));
          ref.read(assignmentsProvider.notifier).fetchAssignments();
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Error uploading assignment: ${responseData['message']}')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error uploading assignment: Server error')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading assignment: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Add Assignment',
      ),
      body: _isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButton<String>(
                    value: selectedSubject,
                    hint: const Text('Select Subject'),
                    items: subjectList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSubject = value!;
                        subjectId = subjectidList[
                            (subjectList.indexOf(selectedSubject))];
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  _selectedFile != null
                      ? Column(
                          children: [
                            Text(
                              'Selected File: ${basename(_selectedFile!.path)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                          ],
                        )
                      : Container(),
                  ElevatedButton(
                    child: const Text('Choose File'),
                    onPressed: () => _selectFile(context),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      child: const Text('Submit'),
                      onPressed: () {
                        _uploadAssignment(context);
                      }),
                ],
              ),
            ),
    );
  }
}
