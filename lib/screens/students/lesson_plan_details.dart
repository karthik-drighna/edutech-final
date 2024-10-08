import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/utils/date_format_converter.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/file_viewer.dart';
import 'package:drighna_ed_tech/widgets/image_viewer.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LessonPlanDetailsPage extends StatefulWidget {
  final subjectId;
  final className;
  final Section;
  final subject;

  const LessonPlanDetailsPage(
      {super.key,
      required this.subjectId,
      this.className,
      this.subject,
      this.Section});
  @override
  _LessonPlanDetailsPageState createState() => _LessonPlanDetailsPageState();
}

class _LessonPlanDetailsPageState extends State<LessonPlanDetailsPage> {
  bool isLoading = true;
  Map<String, dynamic> syllabusData = {};
  List<String> namelist = [];
  List<String> datelist = [];
  List<String> messagelist = [];
  List<String> imagelist = [];
  List<String> typelist = [];
  List<String> idlist = [];
  TextEditingController commentController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchSyllabusData();
    getCommentsFromApi();
  }

  Future<void> fetchSyllabusData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString("apiUrl") ?? "";

    var response = await http.post(
      Uri.parse("$apiUrl${Constants.getsyllabusUrl}"),
      headers: {
        'Content-Type': Constants.contentType,
        'Client-Service': Constants.clientService,
        'Auth-Key': Constants.authKey,
        'User-ID': prefs.getString(Constants.userId) ?? "",
        'Authorization': prefs.getString("accessToken") ?? "",
      },
      body: json.encode({"subject_syllabus_id": widget.subjectId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        syllabusData = json.decode(response.body);

        isLoading = false;
      });
    } else {
      print("Failed to load data!");
    }
  }

  Future<void> getCommentsFromApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString("apiUrl") ?? "default_api_url";
    String userId = prefs.getString("userId") ?? "";
    String accessToken = prefs.getString("accessToken") ?? "";
    String url = "$apiUrl${Constants.getforummessageUrl}";

    setState(() {
      // Clear the lists before filling them with new data
      namelist.clear();
      datelist.clear();
      messagelist.clear();
      imagelist.clear();
      typelist.clear();
      idlist.clear();
    });

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Client-Service': Constants.clientService,
          'Auth-Key': Constants.authKey,
          'User-ID': userId,
          'Authorization': accessToken,
        },
        body: json.encode({"subject_syllabus_id": widget.subjectId}),
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        // Assuming jsonData['syllabus'] is a list of comments.
        List<dynamic> dataArray = jsonData['syllabus'];
        for (var commentData in dataArray) {
          String type = commentData['type'];
          String image = type == "student"
              ? "${prefs.getString('imagesUrl')}${commentData['student_image']}"
              : "${prefs.getString('imagesUrl')}uploads/staff_images/${commentData['staff_image']}";
          String name = type == "student"
              ? "${commentData['firstname']} ${commentData['middlename']} ${commentData['lastname']} (${commentData['admission_no']})"
              : "${commentData['staff_name']} ${commentData['staff_surname']} (${commentData['staff_employee_id']})";
          String message = commentData['message'];
          String id = commentData['lesson_plan_forum_id'];
          String date = DateUtilities.formatStringDate(commentData[
              'created_date']); // You might need to convert this date to your preferred format

          // Add to lists
          namelist.add(name);
          datelist.add(date);
          messagelist.add(message);
          imagelist.add(image);
          typelist.add(type);
          idlist.add(id);
        }

        // Refresh the UI after lists are updated
        setState(() {});
      } else {
        print("Failed to load comments!");
        // Optionally show a snackbar or alert dialog
      }
    } catch (e) {
      print("An error occurred: $e");
      // Optionally show a snackbar or alert dialog
    }
  }

  Future<void> saveComment() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString("apiUrl") ?? "default_api_url";
    String userId = prefs.getString("userId") ?? "";
    String accessToken = prefs.getString("accessToken") ?? "";
    String studentId = prefs.getString("studentId") ?? "";
    String url = "$apiUrl${Constants.addforummessageUrl}";

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Client-Service': Constants.clientService,
        'Auth-Key': Constants.authKey,
        'User-ID': userId,
        'Authorization': accessToken,
      },
      body: json.encode({
        "subject_syllabus_id": widget.subjectId,
        "message": commentController
            .text, // Use the text from the TextEditingController
        "student_id": studentId
      }),
    );

    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      if (result['msg'] == "Success") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Comment saved successfully!"),
        ));
        // Clear the TextField after successful submission
        setState(() {
          commentController.clear();
        });
        // Refresh the comments
        await getCommentsFromApi();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to save comment."),
      ));
    }
  }

  Future<void> confirmDeleteDialog(String commentId) async {
    // Show dialog to ask user if they are sure about deleting the comment
    bool delete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Comment'),
              content:
                  const Text('Are you sure you want to delete this comment?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // Will not delete the comment
                  },
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    Navigator.of(context).pop(true); // Will delete the comment
                  },
                ),
              ],
            );
          },
        ) ??
        false; // if dialog is dismissed by tapping outside the dialog, it should not delete

    if (delete) {
      await deleteComment(commentId); // Only delete if user confirmed
    }
  }

  Future<void> deleteComment(String commentId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString("apiUrl") ?? "default_api_url";
    String userId = prefs.getString("userId") ?? "";
    String accessToken = prefs.getString("accessToken") ?? "";
    String url = "$apiUrl${Constants.deleteforummessageUrl}";

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Client-Service': Constants.clientService,
        'Auth-Key': Constants.authKey,
        'User-ID': userId,
        'Authorization': accessToken,
      },
      body: json.encode({
        "lesson_plan_forum_id": commentId,
      }),
    );

    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      if (result['status'] == "1") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Comment deleted successfully!"),
          ),
        );
        // Refresh the comments list after deletion
        getCommentsFromApi();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to delete comment."),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete comment."),
        ),
      );
    }
  }

  // Future<void> downloadFile(String url, String filename) async {
  //   final status = await Permission.storage.request();
  //   if (status.isGranted) {
  //     final externalDir = await getExternalStorageDirectory();
  //     await FlutterDownloader.enqueue(
  //       url: url,
  //       savedDir: externalDir.path,
  //       fileName: filename,
  //       showNotification: true,
  //       openFileFromNotification: true,
  //     );
  //   } else {
  //     print("Permission denied");
  //   }
  // }

  Future<void> _launchInBrowser(String videoLink) async {
    if (!await launchUrl(
      Uri.parse(videoLink),
      mode: LaunchMode.externalApplication,
    )) {
      _showSnackBar('Could not launch $videoLink', context);
    }
  }

  void _showSnackBar(String message, context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> downloadFile(
      String url, String filename, BuildContext context) async {
    // Checking and requesting storage permission
    // var status = await Permission.storage.request();

    try {
      // Using flutter_file_downloader to download the file
      await FileDownloader.downloadFile(
        url: url,
        name: filename,
        onProgress: (name, progress) {
          setState(() {
            isLoading = true;
          });
          // Optional: Update progress to the user
        },
        onDownloadCompleted: (path) {
          setState(() {
            isLoading = false;
          });
          // Success: Show a success message
          _showSnackBar("File downloaded to $path", context);
          _viewFile(url);
        },
        onDownloadError: (error) {
          setState(() {
            isLoading = false;
          });
          // Error: Show an error message
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

  void openFile(String attachment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String urlStr = prefs.getString(Constants.imagesUrl) ?? "";

    urlStr += "uploads/syllabus_attachment/" + attachment;
    // Assuming you want to extract the filename from the URL
    final String filename = urlStr.split('/').last;
    // _launchInBrowser(urlStr);

    downloadFile(urlStr, filename, context);
  }

  @override
  Widget build(BuildContext context) {
    var data = syllabusData['data'] ?? {};
    String classValue = widget.className ??
        'N/A'; // Make sure you handle nulls for these values too
    String subjectValue = widget.subject ?? 'N/A';
    String sectionName = widget.Section ?? 'N/A';

    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Lesson Plan Details',
      ),
      body: isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : SingleChildScrollView(
              // This allows the entire page to scroll
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Lesson Plan",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  if (data['attachment'] != "")
                                    IconButton(
                                      onPressed: () {
                                        if (data['attachment']?.isNotEmpty ??
                                            false) {
                                          openFile(
                                              data['attachment'].toString());
                                        }
                                      },
                                      icon: const Icon(Icons.file_copy),
                                    ),
                                  if (data['lacture_youtube_url'] != "")
                                    IconButton(
                                      onPressed: () {
                                        // Here, we're calling the launchURL method with the YouTube URL from your data
                                        if (data['lacture_youtube_url'] !=
                                            null) {
                                          _launchInBrowser(
                                              data['lacture_youtube_url']
                                                  .toString());
                                        } else {
                                          print('No YouTube URL provided');
                                        }
                                      },
                                      icon: const Icon(Icons.play_arrow),
                                    ),
                                  if (data['lacture_video'] != "")
                                    IconButton(
                                      onPressed: () async {
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        String lactureVideo =
                                            data['lacture_video'];
                                        String imgUrl = prefs.getString(
                                                Constants.imagesUrl) ??
                                            "";

                                        String videoUrl = imgUrl +
                                            "uploads/syllabus_attachment/lacture_video/" +
                                            lactureVideo;

                                        // Here, we're calling the launchURL method with the YouTube URL from your data
                                        if (data['lacture_video'] != null) {
                                          _launchInBrowser(videoUrl);
                                        } else {
                                          print('No YouTube URL provided');
                                        }
                                      },
                                      icon: const Icon(
                                          Icons.video_collection_sharp),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(),
                          Text('Class:  $classValue ($sectionName)',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Subject:  $subjectValue',
                              style: const TextStyle(fontSize: 16)),
                          Text(
                              'Date:  ${DateUtilities.formatStringDate(data['date']) ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16)),
                          Text(
                              'Time:  ${data['time_from'] ?? 'N/A'} - ${data['time_to'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 20),
                          Text('Lesson: ${data['lesson_name'] ?? 'N/A'}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Topic: ${data['topic_name'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16)),
                          Text('Sub Topic: ${data['sub_topic'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 20),
                          const Text('General Objectives:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Html(data: data['general_objectives'] ?? 'N/A'),
                          const SizedBox(height: 20),
                          const Text('Teaching Method:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Html(data: data['teaching_method'] ?? 'N/A'),
                          const SizedBox(height: 20),
                          const Text('Previous Knowledge:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Html(data: data['previous_knowledge'] ?? 'N/A'),
                          const SizedBox(height: 20),
                          const Text('Comprehensive Questions:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Html(data: data['comprehensive_questions'] ?? 'N/A'),
                          const SizedBox(height: 20),
                          const Text('Presentation:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Html(data: data['presentation'] ?? 'N/A'),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Comments",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: namelist.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                CachedNetworkImageProvider(imagelist[index]),
                          ),
                          title: Text(namelist[index]),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Html(data: messagelist[index]),
                              const SizedBox(height: 5),
                              Text(datelist[index],
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          trailing: Column(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () =>
                                      confirmDeleteDialog(idlist[index]),
                                  child: const Text("Delete"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your comment here',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(
                            width:
                                8), // Add some space between the TextField and the Button
                        ElevatedButton(
                          onPressed: saveComment,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, // Text color
                            backgroundColor:
                                Colors.blueAccent, // Background color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            elevation: 5,
                            shadowColor: Colors.blueGrey,
                          ),
                          child: const Text(
                            'Send',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
