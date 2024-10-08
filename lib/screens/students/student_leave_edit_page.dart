import 'dart:io';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:drighna_ed_tech/widgets/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:file_picker/file_picker.dart';

class StudentEditLeave extends StatefulWidget {
  final String id;
  final String applyDate;
  final String fromDate;
  final String toDate;
  final String reason;
  final File? file;

  const StudentEditLeave({
    super.key,
    required this.id,
    required this.applyDate,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    this.file,
  });

  @override
  _StudentEditLeaveState createState() => _StudentEditLeaveState();
}

class _StudentEditLeaveState extends State<StudentEditLeave> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  PlatformFile? _selectedFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fromDateController.text = widget.fromDate;
    _toDateController.text = widget.toDate;
    _reasonController.text = widget.reason;
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(controller.text),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
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
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var apiUrl = prefs.getString("apiUrl") ?? "";
    var url = Uri.parse(apiUrl + Constants.updateLeaveUrl);

    var request = http.MultipartRequest('POST', url)
      ..fields['id'] = widget.id
      ..fields['apply_date'] =
          widget.applyDate // This should be current date in edit
      ..fields['from_date'] = _fromDateController.text
      ..fields['to_date'] = _toDateController.text
      ..fields['reason'] = _reasonController.text;

    if (_selectedFile != null) {
      var file = await http.MultipartFile.fromPath(
        'file',
        _selectedFile!.path!,
        filename: _selectedFile!.name,
      );
      request.files.add(file);
    }

    request.headers.addAll({
      'Content-Type': Constants.contentType,
      'Client-Service': Constants.clientService,
      'Auth-Key': Constants.authKey,
      'User-ID': prefs.getString(Constants.userId) ?? "",
      'Authorization': prefs.getString("accessToken") ?? "",
    });

    var response = await request.send();

    if (response.statusCode == 200) {
      SnackbarUtil.showSnackBar(
          context, 'Leave application updated successfully',
          backgroundColor: Colors.green);

      Navigator.of(context).pop(true); // Pass true to indicate success
    } else {
      SnackbarUtil.showSnackBar(context, 'Failed to update leave application',
          backgroundColor: Colors.red);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Edit Leave Application',
      ),
      body: _isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateField(_fromDateController, 'From Date', context),
                    const SizedBox(height: 16),
                    _buildDateField(_toDateController, 'To Date', context),
                    const SizedBox(height: 16),
                    _buildReasonField(),
                    const SizedBox(height: 16),
                    _buildFilePicker(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDateField(
      TextEditingController controller, String label, BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () => _selectDate(context, controller),
    );
  }

  Widget _buildReasonField() {
    return TextFormField(
      controller: _reasonController,
      decoration: const InputDecoration(
        labelText: 'Reason for leave',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      ),
      maxLines: 3,
    );
  }

  Widget _buildFilePicker() {
    return _selectedFile != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedFile!.name,
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _pickFile,
              ),
            ],
          )
        : Center(
            child: OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Edit File of Leave'),
            ),
          );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _uploadLeaveApplication,
        child: const Text('Update Leave'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
