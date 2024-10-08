import 'dart:io';
import 'package:drighna_ed_tech/screens/students/student_edit_assignment.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/file_viewer.dart';
import 'package:drighna_ed_tech/widgets/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentCard extends StatefulWidget {
  final dynamic assignment;
  final VoidCallback onDelete;

  const AssignmentCard(
      {super.key, required this.assignment, required this.onDelete});

  @override
  State<AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<AssignmentCard> {
  String loginType = "";

  @override
  void initState() {
    super.initState();

    checkLoginType();
  }

  checkLoginType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loginType = prefs.getString(Constants.loginType) ?? '';
  }

  bool isLoading = false;

  Future<void> downloadFile(
      String url, String filename, BuildContext context) async {
    try {
      await FileDownloader.downloadFile(
        url: url,
        name: filename,
        onProgress: (name, progress) {
          setState(() {
            isLoading = true;
          });
        },
        onDownloadCompleted: (path) {
          setState(() {
            isLoading = false;
          });
          _showSnackBar("File downloaded to $path", context);
          _viewFile(url);
        },
        onDownloadError: (error) {
          setState(() {
            isLoading = false;
          });
          _showSnackBar("Error downloading file: $error", context);
        },
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar("Error: $e", context);
    }
  }

  void _showSnackBar(String message, context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String formatDate(String date) {
    if (date.isEmpty) {
      return 'No Date';
    } else {
      DateTime dateTime = DateFormat("yyyy-MM-dd").parse(date);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  Icon _getFileIcon(String fileName) {
    String extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'jpg':
      case 'jpeg':
      case 'png':
        return const Icon(Icons.image, color: Colors.blue);
      case 'doc':
      case 'docx':
        return const Icon(Icons.description, color: Colors.blue);
      case 'xls':
      case 'xlsx':
        return const Icon(Icons.table_chart, color: Colors.green);
      case 'ppt':
      case 'pptx':
        return const Icon(Icons.slideshow, color: Colors.orange);
      case 'txt':
        return const Icon(Icons.text_snippet, color: Colors.black);
      case 'zip':
      case 'rar':
        return const Icon(Icons.archive, color: Colors.brown);
      case 'mp4':
      case 'mov':
        return const Icon(Icons.movie, color: Colors.purple);
      case 'mp3':
      case 'wav':
        return const Icon(Icons.audiotrack, color: Colors.teal);
      case 'html':
        return const Icon(Icons.language, color: Colors.orange);
      case 'csv':
        return const Icon(Icons.insert_chart, color: Colors.green);
      default:
        return const Icon(Icons.insert_drive_file, color: Colors.grey);
    }
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content:
              const Text('Are you sure you want to delete this assignment?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                widget.onDelete(); // Call the onDelete callback
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
      margin: const EdgeInsets.all(8.0),
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
                Expanded(
                  child: Text(
                    "${widget.assignment['subject_name']} (${widget.assignment['subject_code']})",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (widget.assignment['evaluation_date'].isEmpty &&
                    loginType == "student") ...[
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentEditAssignment(
                          selectedSubject:
                              "${widget.assignment['subject_name']} (${widget.assignment['subject_code']})",
                          description: widget.assignment['description'],
                          id: widget.assignment['id'],
                          subjectId:
                              widget.assignment['subject_group_subject_id'],
                          title: widget.assignment['title'],
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => _showDeleteConfirmationDialog(context),
                    icon: const Icon(Icons.delete),
                  ),
                ] else ...[
                  const Text('Evaluated',
                      style: TextStyle(color: Colors.green)),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Title: ${widget.assignment['title']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text("Remark: ${widget.assignment['remark']}"),
            const SizedBox(height: 4),
            Text("Submission Date: ${formatDate(widget.assignment['date'])}"),
            const SizedBox(height: 4),
            Text(
                "Evaluation Date: ${formatDate(widget.assignment['evaluation_date'])}"),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Description",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                widget.assignment['attachment'] != ""
                    ? TextButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String urlStr =
                              prefs.getString(Constants.imagesUrl) ?? '';
                          urlStr += "uploads/homework/daily_assignment/" +
                              widget.assignment['attachment'].toString();

                          downloadFile(
                              urlStr, widget.assignment['attachment'], context);
                        },
                        child: isLoading
                            ? const Text("Downloading.......")
                            : Row(
                                children: [
                                  _getFileIcon(widget.assignment['attachment']),
                                  const SizedBox(width: 5),
                                  const Text('Download'),
                                ],
                              ),
                      )
                    : const Text(""),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.assignment['description']),
          ],
        ),
      ),
    );
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

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showSnackBar('Could not launch $url', context);
    }
  }
}
