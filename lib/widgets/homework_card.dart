import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:drighna_ed_tech/models/homework_model.dart';
import 'package:drighna_ed_tech/screens/students/student_homework_submit_page.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/utils/date_format_converter.dart';
import 'package:drighna_ed_tech/widgets/file_viewer.dart';
import 'package:drighna_ed_tech/widgets/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeworkCard extends StatefulWidget {
  final HomeworkModel homework;
  final String loginType;

  const HomeworkCard(
      {super.key, required this.homework, required this.loginType});

  @override
  State<HomeworkCard> createState() => _HomeworkCardState();
}

class _HomeworkCardState extends State<HomeworkCard> {
  bool isLoading = false;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.red;
      case 'submitted':
        return Colors.orange; // Changed to orange for better visibility
      case 'evaluated':
        return Colors.green;
      default:
        return Colors.grey; // default color if status is not recognized
    }
  }

  Icon _getFileIcon(String fileName) {
    String extension = fileName.split('.').last;
    switch (extension.toLowerCase()) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'jpg':
      case 'jpeg':
      case 'png':
        return const Icon(Icons.image, color: Colors.blue);
      case 'txt':
        return const Icon(Icons.text_snippet, color: Colors.black);
      case 'doc':
      case 'docx':
        return const Icon(Icons.description, color: Colors.blue);
      case 'xls':
      case 'xlsx':
        return const Icon(Icons.table_chart, color: Colors.green);
      case 'ppt':
      case 'pptx':
        return const Icon(Icons.slideshow, color: Colors.orange);
      case 'zip':
      case 'rar':
        return const Icon(Icons.archive, color: Colors.grey);
      case 'mp4':
      case 'mov':
        return const Icon(Icons.movie, color: Colors.purple);
      case 'mp3':
      case 'wav':
        return const Icon(Icons.audiotrack, color: Colors.teal);
      default:
        return const Icon(Icons.insert_drive_file, color: Colors.grey);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    Color statusColor = _getStatusColor(widget.homework.status);

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.homework.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Your submit functionality goes here.
                  },
                  child: Text(
                    widget.homework.status,
                    style: const TextStyle(
                      color: Colors
                          .white, // Change this to your desired text color
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        statusColor), // Background color
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                if (widget.homework.status != 'evaluated' &&
                    widget.homework.status != 'submitted')
                  widget.loginType == "student"
                      ? ElevatedButton(
                          onPressed: () {
                            // This is where you navigate to the StudentHomeworkSubmitPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeworkSubmitPage(
                                      homework: widget.homework)),
                            );
                          },
                          child: const Text(
                            "Submit",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                          ),
                        )
                      : const SizedBox()
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  bottomLeft:
                      Radius.circular(10), // Rounded corner for bottom left
                  bottomRight:
                      Radius.circular(10), // Rounded corner for bottom right
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightedText(
                      'Homework Date:  ',
                      DateUtilities.formatStringDate(
                          widget.homework.homeworkDate)),
                  _buildHighlightedText(
                      'Submission Date:  ',
                      DateUtilities.formatStringDate(
                          widget.homework.submissionDate)),
                  _buildHighlightedText(
                      'Created By:  ', widget.homework.createdBy),
                  _buildHighlightedText(
                      'Evaluated By:  ', widget.homework.evaluatedBy),
                  _buildHighlightedText(
                      'Evaluation Date:  ', widget.homework.evaluationDate),
                  _buildHighlightedText(
                      'Marks:  ', widget.homework.marks.toString()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHighlightedText('Marks Obtained:  ',
                          widget.homework.marksObtained.toString()),
                      widget.homework.homeworkDocument != ""
                          ? TextButton.icon(
                              icon: _getFileIcon(
                                  widget.homework.homeworkDocument),
                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();

                                String imgUrl =
                                    prefs.getString(Constants.imagesUrl) ?? "";
                                String urlStr = imgUrl +
                                    "uploads/homework/" +
                                    widget.homework.homeworkDocument;

                                downloadFile(
                                    urlStr,
                                    widget.homework.homeworkDocument
                                        .split("/")
                                        .last,
                                    context);
                              },
                              label: const Text("Download"))
                          : const Text("")
                    ],
                  ),
                  _buildHighlightedText('Note:  ', widget.homework.note),
                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Html(
                    data: widget.homework.description,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String title, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
