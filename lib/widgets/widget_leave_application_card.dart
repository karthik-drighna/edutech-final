import 'dart:convert';
import 'package:drighna_ed_tech/screens/students/student_leave_edit_page.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/utils/date_format_converter.dart';
import 'package:drighna_ed_tech/widgets/file_viewer.dart';
import 'package:drighna_ed_tech/widgets/image_viewer.dart';
import 'package:drighna_ed_tech/widgets/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class LeaveApplicationCard extends StatefulWidget {
  final String applyDate;
  final String fromDate;
  final String toDate;
  final String reason;
  final String status;
  final String leaveId;
  final String approvedDate;
  final String documentFile;
  final VoidCallback onLeaveUpdated;

  const LeaveApplicationCard({
    super.key,
    required this.applyDate,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
    required this.leaveId,
    required this.approvedDate,
    required this.documentFile,
    required this.onLeaveUpdated,
  });

  @override
  State<LeaveApplicationCard> createState() => _LeaveApplicationCardState();
}

class _LeaveApplicationCardState extends State<LeaveApplicationCard> {
  PlatformFile? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Apply Date: ${DateUtilities.formatStringDate(widget.applyDate)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (widget.status == "0") ...[
                  Row(
                    children: [
                      if (widget.documentFile.isEmpty) ...[
                        IconButton(
                          onPressed: () async {
                            await _pickFile();
                            if (_selectedFile != null) {
                              await uploadFile(
                                id: widget.leaveId,
                                fromDate: widget.fromDate,
                                reason: widget.reason,
                                toDate: widget.toDate,
                                applyDate: widget.applyDate,
                                selectedFile: _selectedFile!,
                                context: context,
                              );
                            }
                          },
                          icon: const Icon(Icons.upload_file),
                        ),
                      ] else ...[
                        IconButton(
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String imgUrl =
                                prefs.getString(Constants.imagesUrl) ?? "";
                            String downloadUrl = imgUrl +
                                "uploads/student_leavedocuments/" +
                                widget.documentFile;

                            await _viewFile(downloadUrl);
                          },
                          icon: const Icon(Icons.download),
                        ),
                      ],
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentEditLeave(
                                applyDate: widget.applyDate,
                                fromDate: widget.fromDate,
                                id: widget.leaveId,
                                reason: widget.reason,
                                toDate: widget.toDate,
                              ),
                            ),
                          ).then((value) {
                            if (value == true) {
                              widget.onLeaveUpdated();
                            }
                          });
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () => _confirmDeleteLeave(context),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'From Date: ${DateUtilities.formatStringDate(widget.fromDate)}'),
                Text(
                  '${widget.status == "0" ? "Pending" : widget.status == "1" ? "Approved (${DateUtilities.formatStringDate(widget.approvedDate)})" : "Disapproved"}',
                  style: TextStyle(
                    color: widget.status == "0"
                        ? Colors.orange
                        : widget.status == "1"
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('To Date: ${DateUtilities.formatStringDate(widget.toDate)}'),
            const SizedBox(height: 4),
            Text('Reason: ${widget.reason}'),
          ],
        ),
      ),
    );
  }

  Future<void> deleteLeave(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';

    final url = Uri.parse(apiUrl + Constants.deleteLeaveUrl);
    final response = await http.post(
      url,
      headers: {
        "Client-Service": Constants.clientService,
        "Auth-Key": Constants.authKey,
        "User-ID": prefs.getString('userId') ?? '',
        "Authorization": prefs.getString('accessToken') ?? '',
        "Content-Type": "application/json",
      },
      body: json.encode({
        "leave_id": widget.leaveId.toString(),
      }),
    );

    if (response.statusCode == 200) {
      SnackbarUtil.showSnackBar(context, 'Leave deleted successfully',
          backgroundColor: Colors.green);

      widget.onLeaveUpdated();
    } else {
      SnackbarUtil.showSnackBar(context, 'Leave deleted successfully',
          backgroundColor: Colors.green);
    }
  }

  void _confirmDeleteLeave(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Leave'),
          content: const Text(
              'Are you sure you want to permanently delete this leave application? This action cannot be undone.'),
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
                deleteLeave(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  Future<void> uploadFile({
    required String id,
    required String fromDate,
    required String reason,
    required String toDate,
    required String applyDate,
    required PlatformFile selectedFile,
    required BuildContext context,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var apiUrl = prefs.getString("apiUrl") ?? "";
    var url = Uri.parse(apiUrl + Constants.updateLeaveUrl);

    var request = http.MultipartRequest('POST', url)
      ..fields['id'] = id
      ..fields['apply_date'] = applyDate
      ..fields['from_date'] = fromDate
      ..fields['to_date'] = toDate
      ..fields['reason'] = reason;

    var file = await http.MultipartFile.fromPath(
      'file',
      selectedFile.path!,
      filename: selectedFile.name,
    );
    request.files.add(file);

    request.headers.addAll({
      'Content-Type': Constants.contentType,
      'Client-Service': Constants.clientService,
      'Auth-Key': Constants.authKey,
      'User-ID': prefs.getString(Constants.userId) ?? "",
      'Authorization': prefs.getString("accessToken") ?? "",
    });

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        SnackbarUtil.showSnackBar(context, 'File uploaded successfully',
            backgroundColor: Colors.green);

        widget
            .onLeaveUpdated(); // Call this to refresh the leave list after upload
      } else {
        SnackbarUtil.showSnackBar(context, 'File upload failed',
            backgroundColor: Colors.red);
      }
    } catch (e) {
      SnackbarUtil.showSnackBar(context, 'Error: $e',
          backgroundColor: Colors.red);
    }
  }

  Future<void> _viewFile(String url) async {
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var documentDirectory = await getApplicationDocumentsDirectory();
        String fileName = url.split('/').last;
        File file = File('${documentDirectory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        if (fileName.endsWith('.pdf') || fileName.endsWith('.txt')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FileViewer(filePath: file.path),
            ),
          );
        } else if (fileName.endsWith('.jpg') ||
            fileName.endsWith('.png') ||
            fileName.endsWith('.jpeg')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewer(filePath: file.path),
            ),
          );
        } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FileViewer(filePath: file.path),
            ),
          );
        } else {
          _launchURL(url);
        }
      } else {
        _showSnackBar("Failed to download file", context);
      }
    } catch (e) {
      _showSnackBar('Error: $e', context);
    }
  }

  void _showSnackBar(String message, context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showSnackBar('Could not launch $url', context);
    }
  }
}
