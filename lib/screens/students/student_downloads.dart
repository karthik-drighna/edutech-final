import 'dart:convert';
import 'package:drighna_ed_tech/screens/students/gallery_page.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/student_download_assignment_widget.dart';
import 'package:drighna_ed_tech/widgets/student_download_videos_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentDownloads extends StatefulWidget {
  const StudentDownloads({super.key});

  @override
  _StudentDownloadsState createState() => _StudentDownloadsState();
}

class _StudentDownloadsState extends State<StudentDownloads>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<Map<String, String>> mediaUrls = [];

  void updateMediaUrls(List<Map<String, String>> urls) {
    setState(() {
      mediaUrls = urls;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchAndParseData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> fetchAndParseData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonResponse = '''[Your JSON response here]''';
    List<dynamic> data = jsonDecode(jsonResponse);
    List<Map<String, String>> parsedMediaUrls = [];

    for (var item in data) {
      if (item['upload_contents'] != null && item['upload_contents'].isNotEmpty) {
        for (var content in item['upload_contents']) {
          if (content['file_type'] == 'image' || content['file_type'] == 'jpeg' || content['file_type'] == 'mp4' || content['file_type'] == 'video') {
            String baseUrl = prefs.getString("imagesUrl") ?? '';
            String thumbUrl = content['thumb_name'] != null && content['thumb_name'].isNotEmpty
                ? baseUrl + content['thumb_path'] + content['thumb_name']
                : 'assets/play_icon.png';
            String fileUrl = baseUrl + content['dir_path'] + content['img_name'];

            parsedMediaUrls.add({
              'type': content['file_type'] == 'mp4' || content['file_type'] == 'video' ? 'video' : 'image',
              'url': content['vid_url'].isNotEmpty ? content['vid_url'] : fileUrl,
              'thumbUrl': thumbUrl,
            });
          }
        }
      }
    }
    setState(() {
      mediaUrls = parsedMediaUrls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.download_center,
        // actions: [
        //   TextButton.icon(
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => Gallery(mediaUrls: mediaUrls),
        //         ),
        //       );
        //     },
        //     icon: Icon(Icons.photo),
        //     label: Text("Gallery"),
        //   )
        // ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.blue,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ),
            tabs: const [
              Tab(text: 'CONTENTS'),
              Tab(text: 'VIDEO TUTORIAL'),
              Tab(text: 'GALLERY'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                StudentDownloadAssignmentWidget(updateMediaUrls: updateMediaUrls),
                StudentDownloadVideosWidget(),
                Gallery(mediaUrls: mediaUrls),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
