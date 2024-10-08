import 'dart:convert';
import 'package:drighna_ed_tech/models/course_start_lesson_videoplay_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;

class CourseVideoSectionWidget extends StatefulWidget {
  final Section section;
  final int index;

  const CourseVideoSectionWidget(
      {super.key, required this.section, required this.index});

  @override
  State<CourseVideoSectionWidget> createState() =>
      _CourseVideoSectionWidgetState();
}

class _CourseVideoSectionWidgetState extends State<CourseVideoSectionWidget> {
  YoutubePlayerController? _controller;
  bool isLoading = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _playVideo(String videoUrl) {
    var videoId = YoutubePlayer.convertUrlToId(videoUrl);
    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
      );
      setState(() {});
    }
  }

  void _toggleLessonProgress(LessonQuiz quiz, Section section) {
    quiz.toggleProgress();
    setState(() {});
    updateLessonProgress(quiz, section); // Call your API update function here
  }

  Future<void> changeStatusApi(
      BuildContext context, Map<String, dynamic> params) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String apiUrl = prefs.getString('apiUrl') ?? '';
      String userId = prefs.getString('userId') ?? '';
      String accessToken = prefs.getString('accessToken') ?? '';
      String url = '$apiUrl${Constants.markAsCompleteUrl}';

      Map<String, String> headers = {
        "Client-Service":
            Constants.clientService, // Replace with actual header values
        "Auth-Key": Constants.authKey,
        "Content-Type": "application/json",
        "User-ID": userId,
        "Authorization": accessToken,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(params),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == "1") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['msg'])),
          );
        }
      } else {
        throw Exception('Failed to update status');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {}
  }

  void updateLessonProgress(LessonQuiz quiz, Section section) async {
    // Example API call function
    // Implement your own API call logic here
    print("Update progress for lesson: ${quiz.id} to ${quiz.progress}");
    // After successful API response
    // setState(() => quiz.progress = newProgress);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String studentId = prefs.getString('studentId') ?? '';

    Map<String, dynamic> params = {
      "student_id": studentId,
      "lesson_quiz_id": quiz.id,

      "section_id": section.id,
      "lesson_quiz_type": quiz.type == "lesson"
          ? "1"
          : quiz.type == "quiz"
              ? "2"
              : "1", // 1 for lesson, 2 for quiz
    };

    changeStatusApi(context, params);
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

  void _showSnackBar(String message, context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showDescription(BuildContext context, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Description'),
          content: Text(description),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Text(
        //   widget.section.title,
        //   style: TextStyle(fontWeight: FontWeight.bold),
        // ),
        if (_controller != null)
          Column(
            children: [
              YoutubePlayer(
                controller: _controller!,
                showVideoProgressIndicator: true,
                onReady: () {
                  _controller!.addListener(() {});
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.section.sectionTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        Card(
          margin: const EdgeInsets.all(8.0),
          child: ExpansionTile(
            title: Text(
              "Section ${widget.index} :" + widget.section.sectionTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              Container(
                height: MediaQuery.of(context).size.height *
                    0.3, // Adjust height accordingly
                child: ListView.builder(
                  itemCount: widget.section.lessonQuizzes.length,
                  itemBuilder: (BuildContext context, int index) {
                    final lessonQuiz = widget.section.lessonQuizzes[index];

                    return ListTile(
                      leading: Icon(lessonQuiz.lessonType == "video"
                          ? Icons.play_circle_fill
                          : Icons.attach_file),
                      title: GestureDetector(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String imgUrl =
                              prefs.getString(Constants.imagesUrl) ?? "";
                          String downloadUrl = imgUrl +
                              "uploads/course_content/" +
                              lessonQuiz.courseSectionId +
                              "/" +
                              lessonQuiz.lessonId +
                              "/" +
                              lessonQuiz.attatchmentFile;

                          lessonQuiz.lessonType == "video"
                              ? _playVideo(lessonQuiz.videoUrl)
                              : downloadFile(downloadUrl,
                                  lessonQuiz.attatchmentFile, context);
                        },
                        child: Text(
                          lessonQuiz.type == "quiz"
                              ? lessonQuiz.quizTitle
                              : lessonQuiz.lessonTitle,
                          style: const TextStyle(color: Colors.deepPurple),
                        ),
                      ),
                      subtitle: lessonQuiz.lessonType == "video"
                          ? Text("Duration: ${lessonQuiz.duration}")
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  _showDescription(context, lessonQuiz.summary);
                                },
                                child: const Row(
                                  children: [
                                    Text("Description "),
                                    Icon(Icons.file_copy_outlined),
                                  ],
                                ),
                              ),
                            ),
                      trailing: Checkbox(
                        value: lessonQuiz.progress == 1,
                        onChanged: (bool? newValue) {
                          if (newValue != null) {
                            _toggleLessonProgress(lessonQuiz, widget.section);
                          }
                        },
                      ),
                      onTap: () => _playVideo(lessonQuiz.videoUrl),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
