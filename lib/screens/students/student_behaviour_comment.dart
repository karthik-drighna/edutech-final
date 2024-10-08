import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BehaviourComment extends StatefulWidget {
  final String id;

  const BehaviourComment({super.key, required this.id});

  @override
  _BehaviourCommentState createState() => _BehaviourCommentState();
}

class _BehaviourCommentState extends State<BehaviourComment> {
  List<Map<String, String>> commentsList = [];
  final TextEditingController commentController = TextEditingController();
  String apiUrl = ''; // Load your apiUrl from SharedPreferences or constants

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  loadComments() async {
    // Fetch from SharedPreferences or constants
    final prefs = await SharedPreferences.getInstance();
    prefs.getString('studentId');
    String userId = prefs.getString('userId') ?? "";
    String accessToken = prefs.getString('accessToken') ?? "";
    final apiUrl = prefs.getString('apiUrl');
    String imgUrl = prefs.getString(Constants.imagesUrl) ?? "";

    final response = await http.post(
      Uri.parse("$apiUrl${Constants.getincidentcommentsUrl}"),
      headers: {
        "Client-Service": Constants.clientService,
        "Auth-Key": Constants.authKey,
        "User-ID": userId,
        "Authorization": accessToken,
        "Content-Type": "application/json",
      },
      body: json.encode({"student_incident_id": widget.id}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final List<dynamic> messages =
          data['messagelist']; // This is the correct line
      setState(() {
        commentsList = messages.map<Map<String, String>>((message) {
          return {
            'name': message['firstname'] + " " + message['lastname'],
            'date': message['created_date'],
            'message': message['comment'],
            'image': imgUrl + message['student_image'] ??
                "", // Assuming you have a placeholder image
            'type': message['type'],
            'id': message['id'].toString(),
          };
        }).toList();
      });
    } else {
      // Handle errors
    }
  }

  saveComment(String comment) async {
    // Fetch from SharedPreferences or constants
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('studentId');
    String userId = prefs.getString('userId') ?? "";
    String accessToken = prefs.getString('accessToken') ?? "";
    final apiUrl = prefs.getString('apiUrl');

    final headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "User-ID": userId,
      "Authorization": accessToken,
      "Content-Type": "application/json",
    };

    final response = await http.post(
      Uri.parse("$apiUrl${Constants.addincidentcommentsUrl}"),
      headers: headers,
      body: json.encode({
        "student_incident_id": widget.id,
        "type": prefs.getString(Constants.loginType) ??
            "student", // or fetch the type as needed
        "comment": comment,
        "student_id": studentId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['msg'] == 'Success') {
        // Comment was saved successfully
        // Reload comments or add new comment to the list
        setState(() {
          loadComments();
        });
      } else {
        // Handle errors
      }
    } else {
      // Handle errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Behaviour Comment',
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: commentsList.length,
              itemBuilder: (context, index) {
                final comment = commentsList[index];
                return ListTile(
                  title: Text(comment['name']!),
                  subtitle: Text(comment['message']!),
                  // trailing: Text(comment['created_date']!),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(comment['image']!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: 'Enter comment',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (commentController.text.isNotEmpty) {
                      saveComment(commentController.text);
                      commentController.clear();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
