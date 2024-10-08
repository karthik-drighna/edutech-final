import 'dart:convert';
import 'dart:io';
import 'package:drighna_ed_tech/models/download_center_contents_model.dart';
import 'package:drighna_ed_tech/screens/students/download_center_video_play.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/utils/date_format_converter.dart';
import 'package:drighna_ed_tech/widgets/file_viewer.dart';
import 'package:drighna_ed_tech/widgets/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentDownloadAssignmentWidget extends StatefulWidget {
  final Function(List<Map<String, String>>) updateMediaUrls;

  const StudentDownloadAssignmentWidget(
      {super.key, required this.updateMediaUrls});

  @override
  _StudentDownloadAssignmentWidgetState createState() =>
      _StudentDownloadAssignmentWidgetState();
}

class _StudentDownloadAssignmentWidgetState
    extends State<StudentDownloadAssignmentWidget> {
  List<Assignment> assignments = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getDataFromApi();
  }

  Future<void> downloadFile(
      String url, String filename, BuildContext context) async {
    ;

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

  Future<void> getDataFromApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString("apiUrl") ?? "default_api_url";
    String downloadsLinksUrl = Constants.getDownloadsLinksUrl;
    String url = "$apiUrl$downloadsLinksUrl";

    Map<String, String> headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": "application/json",
      "User-ID": prefs.getString("userId") ?? "",
      "Authorization": prefs.getString("accessToken") ?? "",
    };

    Map<String, dynamic> body = {
      "role": prefs.getString(Constants.loginType) ?? "",
      "student_id": prefs.getString(Constants.studentId) ?? "",
      "classId": prefs.getString(Constants.classId) ?? "",
      "sectionId": prefs.getString(Constants.sectionId) ?? "",
      "user_parent_id": prefs.getString(Constants.userId) ?? "",
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var result = json.decode(response.body);

        List<Map<String, String>> mediaUrls = [];
        setState(() {
          assignments = List<Assignment>.from(
              result.map((assignment) => Assignment.fromJson(assignment)));
          assignments.forEach((assignment) {
            assignment.attachments.forEach((attachment) {
              String baseUrl = prefs.getString("imagesUrl") ?? "";
              String thumbUrl = attachment.thumbName != null &&
                      attachment.thumbName.isNotEmpty
                  ? baseUrl + attachment.thumbPath + attachment.thumbName
                  : 'assets/play_icon.png';
              String fileUrl =
                  baseUrl + attachment.dirPath + attachment.imgName;

              if (attachment.fileType == 'image' ||
                  attachment.fileType == 'png' ||
                  attachment.fileType == 'jpg' ||
                  attachment.fileType == 'jpeg') {
                mediaUrls.add(
                    {'type': 'image', 'url': fileUrl, 'thumbUrl': thumbUrl});
              } else if (attachment.fileType == 'video' ||
                  attachment.fileType == 'mp4') {
                mediaUrls.add({
                  'type': 'video',
                  'url': attachment.vidUrl.isNotEmpty
                      ? attachment.vidUrl
                      : fileUrl,
                  'thumbUrl': thumbUrl
                });
              }
            });
          });
        });
        widget.updateMediaUrls(mediaUrls);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return assignments.isNotEmpty
        ? ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              Assignment assignment = assignments[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.title,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Share Date: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateUtilities.formatStringDate(
                                assignment.shareDate),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text(
                            'Valid Upto: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateUtilities.formatStringDate(
                                assignment.validUpto),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text(
                            'Share By: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(assignment.sharedBy),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              assignment.description,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text(
                            'Upload Date: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(DateUtilities.formatStringDate(
                              assignment.uploadDate)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Attachment: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (assignment.attachments.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.attach_file,
                              color: Colors.deepPurple),
                          title: Text(
                            assignment.attachments.first.realName,
                            style: const TextStyle(color: Colors.deepPurple),
                          ),
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            String fileName =
                                assignment.attachments.first.imgName;
                            String url = prefs.getString("imagesUrl") ?? "";
                            String downloadUrl = url +
                                assignment.attachments.first.dirPath +
                                assignment.attachments.first.imgName;

                            assignment.attachments.first.fileType == "video"
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DownloadCenterVideoTutorialPlay(
                                              youtube_url: assignment.videoUrl
                                                  .toString(),
                                            )))
                                : downloadFile(downloadUrl, fileName, context);
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          )
        : const Center(
            child: Text(
              "No data found",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          );
  }
}
