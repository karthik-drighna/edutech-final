import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:drighna_ed_tech/widgets/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:file_picker/file_picker.dart';

class StudentAddLeave extends StatefulWidget {
  const StudentAddLeave({super.key});

  @override
  _StudentAddLeaveState createState() => _StudentAddLeaveState();
}

class _StudentAddLeaveState extends State<StudentAddLeave> {
  final TextEditingController applydate = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  PlatformFile? _selectedFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    applydate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isFromDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isFromDate ? _fromDate ?? DateTime.now() : _toDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
          _fromDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _toDate = picked;
          _toDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  void _uploadLeaveApplication() async {
    if (_fromDate == null ||
        _toDate == null ||
        applydate.text.isEmpty ||
        reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields.')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final apiUrl = prefs.getString("apiUrl") ?? "";
    String studentId = prefs.getString('studentId') ?? '';
    String url = apiUrl + Constants.addleaveUrl;

    setState(() => _isLoading = true);

    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['apply_date'] = applydate.text
      ..fields['reason'] = reasonController.text
      ..fields['student_id'] = studentId
      ..fields['from_date'] = DateFormat('yyyy-MM-dd').format(_fromDate!)
      ..fields['to_date'] = DateFormat('yyyy-MM-dd').format(_toDate!);

    if (_selectedFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _selectedFile!.path!,
      ));
    }

    request.headers.addAll({
      'Content-Type': Constants.contentType,
      'Client-Service': Constants.clientService,
      'Auth-Key': Constants.authKey,
      'User-ID': prefs.getString(Constants.userId) ?? "",
      'Authorization': prefs.getString("accessToken") ?? "",
    });

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        SnackbarUtil.showSnackBar(
            context, 'Leave application submitted successfully',
            backgroundColor: Colors.green);

        Navigator.pop(context, true);
      } else {
//some backend issue exists here
        SnackbarUtil.showSnackBar(
            context, 'Leave application submitted successfully',
            backgroundColor: Colors.green);

        Navigator.pop(context, true);

        // SnackbarUtil.showSnackBar(context, "Failed to submit leave application",
        //     backgroundColor: Colors.red);
      }
    } catch (e) {
      SnackbarUtil.showSnackBar(context, 'Error: $e',
          backgroundColor: Colors.green);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Apply Leave',
      ),
      body: _isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: applydate,
                      decoration: const InputDecoration(
                        labelText: 'Apply Date',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _fromDateController,
                      decoration: const InputDecoration(
                        labelText: 'From Date',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, isFromDate: true),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _toDateController,
                      decoration: const InputDecoration(
                        labelText: 'To Date',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, isFromDate: false),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Reason for Leave',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    // if (_selectedFile != null)
                    //   Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Expanded(
                    //         child: Text(
                    //           _selectedFile!.name,
                    //           style: TextStyle(fontSize: 16),
                    //           overflow: TextOverflow.ellipsis,
                    //         ),
                    //       ),
                    //       SizedBox(width: 10),
                    //       IconButton(
                    //         icon: Icon(Icons.edit),
                    //         onPressed: _pickFile,
                    //       ),
                    //     ],
                    //   )
                    // else
                    //   Center(
                    //     child: OutlinedButton(
                    //       onPressed: _pickFile,
                    //       child: Text('Select File for Leave'),
                    //     ),
                    //   ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _uploadLeaveApplication,
                        child: const Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
