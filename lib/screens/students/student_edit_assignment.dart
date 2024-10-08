import 'dart:convert';
import 'dart:io';
import 'package:drighna_ed_tech/provider/daily_assignment_provider.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:drighna_ed_tech/widgets/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

class StudentEditAssignment extends ConsumerStatefulWidget {
  final String? title, description, id, subjectId, selectedSubject;

  const StudentEditAssignment(
      {super.key,
      this.title,
      this.description,
      this.id,
      this.subjectId,
      this.selectedSubject});

  @override
  _StudentEditAssignmentState createState() => _StudentEditAssignmentState();
}

class _StudentEditAssignmentState extends ConsumerState<StudentEditAssignment> {
  File? _selectedFile;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String selectedSubject = "Select";
  bool _isLoading = true; // Set to true to show loading indicator initially
  String? subjectId;
  List<String> subjectList = ["Select"];
  List<String> subjectidList = [""];

  @override
  void initState() {
    super.initState();
    titleController.text = widget.title ?? '';
    descriptionController.text = widget.description ?? '';
    subjectId = widget.subjectId;
    getScannerDataFromApi();
  }

  Future<void> getScannerDataFromApi() async {
    selectedSubject =
        widget.selectedSubject ?? "Select"; // Set the selectedSubject
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
        print("Scanner Data: $data");

        setState(() {
          List<dynamic> subjectListData = data['subjectlist'] ?? [];

          for (var subject in subjectListData) {
            String name = "${subject['name']} (${subject['code']})";
            String id = subject['subject_group_subjects_id'].toString();
            subjectList.add(name);
            subjectidList.add(id);
          }

          _isLoading = false; // Data loaded, set loading to false
        });
      } else {
        setState(() {
          _isLoading = false; // Data load failed, set loading to false
        });
      }
    } catch (e) {
      ;
      setState(() {
        _isLoading = false; // Error occurred, set loading to false
      });
    }
  }

  Future<void> _selectFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No file selected.'),
      ));
    }
  }

  Future<void> _uploadAssignment(BuildContext context) async {
    if (selectedSubject == "Select" ||
        titleController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields.')));
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
      ..fields['id'] = widget.id ?? ''
      ..fields['student_id'] = studentId
      ..fields['title'] = titleController.text
      ..fields['description'] = descriptionController.text
      ..fields['subject'] = subjectId ?? '';

    if (_selectedFile != null) {
      String mimeType =
          lookupMimeType(_selectedFile!.path) ?? 'application/octet-stream';
      request.files.add(http.MultipartFile(
        'file',
        _selectedFile!.readAsBytes().asStream(),
        _selectedFile!.lengthSync(),
        filename: basename(_selectedFile!.path),
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
          SnackbarUtil.showSnackBar(context, "Assignment edited successfully",
              backgroundColor: Colors.green);

          ref.read(assignmentsProvider.notifier).fetchAssignments();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('Failed to upload assignment: ${responseData['msg']}')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload assignment.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while uploading: $e')));
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
        titleText: 'Edit Assignment',
      ),
      body: _isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButton<String>(
                    value: subjectList.contains(selectedSubject)
                        ? selectedSubject
                        : null,
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
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
