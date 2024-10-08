import 'dart:convert';
import 'dart:io';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/utils/date_format_converter.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/file_viewer.dart';
import 'package:drighna_ed_tech/widgets/image_viewer.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentTimeline extends StatefulWidget {
  const StudentTimeline({super.key});

  @override
  _StudentTimelineState createState() => _StudentTimelineState();
}

class _StudentTimelineState extends State<StudentTimeline> {
  List<Map<String, String>> timelineData = [];
  bool isLoading = true;
  bool isAddLeaveVisible = false;

  @override
  void initState() {
    super.initState();
    loaddata();
  }

  loaddata() {
    fetchStudentTimelineStatus();
  }

  Future<void> fetchStudentTimelineStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final apiUrl = prefs.getString('apiUrl') ?? '';
    final url = "$apiUrl${Constants.getStudentTimelineStatusUrl}";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Client-Service': Constants.clientService,
          'Auth-Key': Constants.authKey,
          'Content-Type': 'application/json',
          'User-ID': prefs.getString('userId') ?? '',
          'Authorization': prefs.getString('accessToken') ?? '',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final studentTimeline = result['student_timeline'];

        setState(() {
          isAddLeaveVisible = studentTimeline == 'enabled';
        });
        fetchTimelineData();
      } else {
        print('Failed to fetch timeline status: ${response.body}');
      }
    } catch (e) {
      print('Error fetching timeline status: $e');
    }
  }

  Future<void> fetchTimelineData() async {
    final prefs = await SharedPreferences.getInstance();
    final apiUrl = prefs.getString('apiUrl') ?? '';
    final studentId = prefs.getString('studentId') ?? '';
    final url = "$apiUrl${Constants.getTimelineUrl}";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Client-Service': Constants.clientService,
          'Auth-Key': Constants.authKey,
          'Content-Type': 'application/json',
          'User-ID': prefs.getString('userId') ?? '',
          'Authorization': prefs.getString('accessToken') ?? '',
        },
        body: jsonEncode(<String, String>{
          'studentId': studentId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is List) {
          final List<dynamic> timelineList = responseData;

          setState(() {
            timelineData = timelineList.map((item) {
              return {
                'id': item['id'].toString(),
                'document': item['document'].toString(),
                'title': item['title'].toString(),
                'description': item['description'].toString(),
                'timeline_date': DateUtilities.formatStringDate(
                    item['timeline_date'].toString()),
                'status': item['status'].toString(),
              };
            }).toList();
            isLoading = false;
          });
        } else {
          print("Unexpected response format");
        }
      } else {
        setState(() => isLoading = false);
        print('Failed to load timeline data: ${response.body}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error fetching timeline data: $e');
    }
  }

  Future<void> downloadFile(String url, String filename) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // Check if the URL is accessible
      final headResponse = await http.head(Uri.parse(url));
      if (headResponse.statusCode == 200) {
        await FileDownloader.downloadFile(
          url: url,
          name: filename,
          headers: {
            'Client-Service': Constants.clientService,
            'Auth-Key': Constants.authKey,
            'User-ID': prefs.getString('userId') ?? '',
            'Authorization': prefs.getString('accessToken') ?? '',
          },
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
      } else {
        setState(() {
          isLoading = false;
        });
        _showSnackBar(
            "Error: File not accessible (status code: ${headResponse.statusCode})",
            context);
      }
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
    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.student_timeline,
      ),
      body: isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : timelineData.isNotEmpty
              ? RefreshIndicator(
                  onRefresh: fetchTimelineData,
                  child: ListView.builder(
                    itemCount: timelineData.length,
                    itemBuilder: (context, index) {
                      final item = timelineData[index];
                      return Column(
                        children: [
                          TimelineTile(
                            alignment: TimelineAlign.manual,
                            lineXY: 0.1,
                            isFirst: index == 0,
                            isLast: index == timelineData.length - 1,
                            indicatorStyle: const IndicatorStyle(
                              width: 20,
                              color: Colors.blue,
                              indicatorXY: 0.5,
                              padding: EdgeInsets.all(6),
                            ),
                            beforeLineStyle: LineStyle(
                              color: Colors.blue.withOpacity(0.7),
                              thickness: 3,
                            ),
                            afterLineStyle: LineStyle(
                              color: Colors.blue.withOpacity(0.7),
                              thickness: 3,
                            ),
                            endChild: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Card(
                                elevation: 5,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        item['timeline_date'] ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        item['description'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      item['document'] != ""
                                          ? Align(
                                              alignment: Alignment.centerRight,
                                              child: ElevatedButton.icon(
                                                onPressed: () async {
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  String imgUrl =
                                                      prefs.getString(Constants
                                                              .imagesUrl) ??
                                                          "";
                                                  String downloadUrl = imgUrl +
                                                      "uploads/student_timeline/" +
                                                      item['document']!;

                                                  final String filename =
                                                      downloadUrl
                                                          .split('/')
                                                          .last;
                                                  downloadFile(
                                                      downloadUrl, filename);
                                                },
                                                icon:
                                                    const Icon(Icons.download),
                                                label: const Text("Download"),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            startChild: Container(
                              padding: const EdgeInsets.all(16),
                              alignment: Alignment.center,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
              : const Center(
                  child: Text(
                    "No Data Found",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
      floatingActionButton: isAddLeaveVisible
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to Add Leave Page
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
