import 'dart:convert';
import 'dart:io';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/file_viewer.dart';
import 'package:drighna_ed_tech/widgets/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentDocuments extends StatefulWidget {
  const StudentDocuments({super.key});

  @override
  _StudentDocumentsState createState() => _StudentDocumentsState();
}

class _StudentDocumentsState extends State<StudentDocuments> {
  List<Map<String, String>> documents = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String studentId = prefs.getString('studentId') ?? '';
    String userId = prefs.getString('userId') ?? '';
    String accessToken = prefs.getString('accessToken') ?? '';

    var headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "User-ID": userId,
      "Authorization": accessToken,
      "Content-Type": "application/json",
    };

    var body = json.encode({
      "student_id": studentId,
    });

    var response = await http.post(
      Uri.parse("$apiUrl${Constants.getDocumentUrl}"),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      setState(() {
        documents = List<Map<String, String>>.from(data.map((i) => {
              'title': i['title'].toString(),
              'doc': i['doc'].toString(),
            })).reversed.toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to load documents'),
      ));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.documents,
      ),
      body: RefreshIndicator(
        onRefresh: loadDocuments,
        child: documents.isNotEmpty
            ? ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      leading: _getFileIcon(documents[index]['doc']!),
                      title: Text(
                        documents[index]['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(documents[index]['doc']!),
                      trailing: const Text(
                        "Download",
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                      onTap: () => downloadFile(documents[index]['doc']!,
                          documents[index]['title']!, context),
                    ),
                  );
                },
              )
            : const Center(
                child: Text("No data found",
                    style: TextStyle(fontWeight: FontWeight.bold))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/studentUploadDocuments');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> downloadFile(
      String url, String filename, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final imagesUrl = prefs.getString('imagesUrl') ?? '';
    final studentId = prefs.getString('studentId') ?? '';

    String downloadUrl = "$imagesUrl/uploads/student_documents/$studentId/$url";

    try {
      await FileDownloader.downloadFile(
        url: downloadUrl,
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
          _viewFile(downloadUrl);
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

  void _showSnackBar(String message, context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
