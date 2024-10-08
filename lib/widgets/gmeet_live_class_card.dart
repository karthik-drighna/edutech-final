import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drighna_ed_tech/models/gmeet_live_class_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/utils/date_format_converter.dart';

class LiveClassCard extends StatefulWidget {
  final LiveClass liveClass;

  const LiveClassCard({super.key, required this.liveClass});

  @override
  State<LiveClassCard> createState() => _LiveClassCardState();
}

class _LiveClassCardState extends State<LiveClassCard> {
  String loginType = "";

  @override
  void initState() {
    super.initState();
    checkLoginType();
  }

  checkLoginType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loginType = prefs.getString(Constants.loginType) ?? '';
    });
  }

  Future<void> _joinMeeting(String url) async {
  

    try {
      bool launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to launch the URL'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    bool isJoinVisible;

    switch (widget.liveClass.status) {
      case "0": // Awaiting
        statusColor = Colors.orange;
        statusText = "Awaited";
        isJoinVisible = true;
        break;
      case "2": // Finished
        statusColor = Colors.green;
        statusText = "Finished";
        isJoinVisible = false;
        break;
      default: // Cancelled or any other status
        statusColor = Colors.red;
        statusText = "Cancelled";
        isJoinVisible = false;
        break;
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    widget.liveClass.title,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isJoinVisible && loginType != 'parent')
                  ElevatedButton.icon(
                    onPressed: () {
                      _joinMeeting(widget.liveClass.joinUrl);
                    },
                    icon: const Icon(Icons.videocam),
                    label: const Text('Join'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(DateUtilities.formatDateTimeString(widget.liveClass.date)),
            const SizedBox(height: 8.0),
            Text('Duration: ${widget.liveClass.duration} minutes'),
            const SizedBox(height: 8.0),
            Text(
                'Class: ${widget.liveClass.className} (${widget.liveClass.section})'),
            const SizedBox(height: 8.0),
            Text(
                'Host: ${widget.liveClass.staffName} ${widget.liveClass.staffSurname} (${widget.liveClass.staffRole})'),
            const SizedBox(height: 16.0),
            Text(widget.liveClass.description),
            const SizedBox(height: 16.0),
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
