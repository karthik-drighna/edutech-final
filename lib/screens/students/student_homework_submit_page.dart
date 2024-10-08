import 'dart:io';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/snackbar_message.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:drighna_ed_tech/models/homework_model.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart'; // For setting the content type in multipart request

class HomeworkSubmitPage extends StatefulWidget {
  final HomeworkModel homework;

  const HomeworkSubmitPage({super.key, required this.homework});

  @override
  _HomeworkSubmitPageState createState() => _HomeworkSubmitPageState();
}

class _HomeworkSubmitPageState extends State<HomeworkSubmitPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;
  File? _pickedFile;

  Future<void> pickFile() async {
    // Check if the message is entered before allowing file selection
    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message before selecting a file.'),
          duration: Duration(seconds: 3),
        ),
      );
      return; // Exit the function if no message is entered
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'pdf',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'xls',
        'xlsx',
        'txt',
        'zip',
        'png',
        'jpeg'
      ],
    );

    if (result != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
      });
    } else {
      // User canceled the picker
    }
  }

  Future<void> submitHomework() async {
    // Check if the message is entered before allowing file selection
    if (_messageController.text.isEmpty) {
      SnackbarUtil.showSnackBar(
        context,
        'Please enter a message before submitting',
        duration: 3,
        backgroundColor: Colors.red,
        // action: SnackBarAction(
        //   label: 'UNDO',
        //   onPressed: () {
        //     // Code to undo the deletion
        //   },
        // ),
      );

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Please enter a message before submitting'),
      //     duration: Duration(seconds: 3),
      //   ),
      // );
      return; // Exit the function if no message is entered
    }

    setState(() {
      _isSubmitting = true;
    });

    final prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String accessToken = prefs.getString('accessToken') ?? '';
    String userId = prefs.getString('userId') ?? '';

    var uri = Uri.parse("$apiUrl${Constants.uploadHomeworkUrl}");
    var request = http.MultipartRequest("POST", uri)
      ..headers['Authorization'] = accessToken
      ..headers['Client-Service'] = Constants.clientService
      ..headers['Auth-Key'] = Constants.authKey
      ..headers['User-ID'] = userId
      ..fields['student_id'] = prefs.getString('studentId') ?? ''
      ..fields['homework_id'] = widget.homework.id.toString()
      ..fields['message'] = _messageController.text;

    if (_pickedFile != null) {
      String mimeType =
          lookupMimeType(_pickedFile!.path) ?? 'application/octet-stream';
      request.files.add(
        http.MultipartFile(
          'file',
          _pickedFile!.readAsBytes().asStream(),
          await _pickedFile!.length(),
          filename: _pickedFile!.path.split("/").last,
          contentType: MediaType.parse(mimeType),
        ),
      );
    } else {
      request.fields['file'] = "";
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Homework submitted successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit homework')));
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Submit Homework: ${widget.homework.title}',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _pickedFile != null
                ? Text("File selected: ${_pickedFile!.path.split('/').last}")
                : ElevatedButton(
                    onPressed: pickFile,
                    child: const Text('Select File'),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => submitHomework(),
              child: Text(_isSubmitting ? 'Submitting...' : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
