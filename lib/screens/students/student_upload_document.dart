import 'dart:convert';
import 'dart:io';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class StudentUploadDocuments extends StatefulWidget {
  const StudentUploadDocuments({super.key});

  @override
  _StudentUploadDocumentsState createState() => _StudentUploadDocumentsState();
}

class _StudentUploadDocumentsState extends State<StudentUploadDocuments> {
  File? _selectedFile;
  final TextEditingController _titleController = TextEditingController();
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleText: "Upload Document"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            if (_selectedFile != null)
              Column(
                children: [
                  const Text(
                    'Selected File:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    basename(_selectedFile!.path),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _selectFile(context),
              icon: const Icon(Icons.attach_file),
              label: const Text('Select File'),
              style: ElevatedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                foregroundColor: Colors.deepPurple,
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : () => _uploadFile(context),
              icon: const Icon(Icons.upload),
              label: const Text('Upload File'),
              style: ElevatedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                foregroundColor: _isUploading ? Colors.grey : Colors.deepPurple,
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            if (_isUploading) ...[
              const SizedBox(height: 20),
              const PencilLoaderProgressBar(),
              const SizedBox(height: 20),
              const Text('Uploading, please wait...'),
            ],
          ],
        ),
      ),
    );
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

  Future<void> _uploadFile(BuildContext context) async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a file first.'),
      ));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String studentId = prefs.getString('studentId') ?? '';
    String userId = prefs.getString('userId') ?? '';
    String accessToken = prefs.getString('accessToken') ?? '';

    var url = Uri.parse('$apiUrl${Constants.uploadDocumentUrl}');
    print("URL of uploadDocumentUrl: $url");

    var mimeTypeData = lookupMimeType(_selectedFile!.path)?.split('/');
    var request = http.MultipartRequest('POST', url)
      ..fields['title'] = _titleController.text
      ..fields['student_id'] = studentId
      ..headers['Client-Service'] = Constants.clientService
      ..headers['Auth-Key'] = Constants.authKey
      ..headers['User-ID'] = userId
      ..headers['Authorization'] = accessToken;

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      await _selectedFile!.readAsBytes(),
      filename: basename(_selectedFile!.path),
      contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
    ));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      setState(() {
        _isUploading = false;
      });

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print("Response from the server: $jsonData");

        if (jsonData['status'] == '1') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('File uploaded successfully!'),
          ));
        } else {
          var error = jsonData['error'];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('File upload failed: $error'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'File upload failed. Server responded with status code ${response.statusCode}.'),
        ));
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('An error occurred while uploading the file.'),
      ));
    }
  }
}
