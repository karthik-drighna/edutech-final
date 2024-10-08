import 'package:drighna_ed_tech/models/download_center_video_tutorial.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'video_item.dart'; // Import your video item model

class StudentDownloadVideosWidget extends StatefulWidget {
  const StudentDownloadVideosWidget({super.key});

  @override
  _StudentDownloadVideosWidgetState createState() =>
      _StudentDownloadVideosWidgetState();
}

class _StudentDownloadVideosWidgetState
    extends State<StudentDownloadVideosWidget> {
  List<VideoModel> videos = [];
  String imgUrl = "";

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final apiUrl = prefs.getString('apiUrl') ?? '';
    final userId = prefs.getString('userId') ?? 'default_user_id';
    final accessToken =
        prefs.getString('accessToken') ?? 'default_access_token';
    imgUrl = prefs.getString(Constants.imagesUrl) ?? "";

    final response = await http.post(
      Uri.parse('$apiUrl${Constants.getVideoTutorialUrl}'),
      headers: {
        'Client-Service': Constants.clientService,
        'Auth-Key': Constants.authKey,
        'Content-Type': 'application/json',
        'User-ID': userId,
        'Authorization': accessToken,
      },
      body: jsonEncode({
        'class_id': prefs.getString(Constants.classId),
        'section_id': prefs.getString(Constants.sectionId),
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> videoListRaw = json.decode(response.body)['result'];
      setState(() {
        videos = videoListRaw
            .map((videoJson) => VideoModel.fromJson(videoJson))
            .toList();
      });
    } else {
      // Handle errors
    }
  }

  Future<void> _launchInBrowser(String videoLink) async {
    if (!await launchUrl(
      Uri.parse(videoLink),
      mode: LaunchMode.externalApplication,
    )) {
      _showSnackBar('Could not launch $videoLink');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
          onRefresh: fetchVideos,
          child: videos.isNotEmpty
              ? ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    final thumbImage = imgUrl + video.thumbnailPath;

                    return ListTile(
                      leading: Image.network(thumbImage),
                      title: Text(video.title,
                          // textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Description: ${video.description}"),
                          Text("Created By: ${video.createdBy}"),
                        ],
                      ),
                      onTap: () {
                        // Handle video tap, e.g., open a video player
                        _launchInBrowser(video.videoLink);
                      },
                    );
                  },
                )
              : const Center(
                  child: Text(
                  "No data found",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ))),
    );
  }
}
