import 'dart:convert';
import 'package:drighna_ed_tech/sqflite/notification_database.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class StudentNotificationScreen extends ConsumerStatefulWidget {
  final String? payload;
  const StudentNotificationScreen({super.key, this.payload});

  @override
  _StudentNotificationScreenState createState() =>
      _StudentNotificationScreenState();
}

class _StudentNotificationScreenState
    extends ConsumerState<StudentNotificationScreen> {
  late Future<List<NotificationMessage>> notificationMessagesFuture;

  @override
  void initState() {
    super.initState();
    notificationMessagesFuture =
        NotificationDatabase.instance.readAllNotifications();
    if (widget.payload != null) {
      _handlePayload(widget.payload!);
    }
  }

  void _handlePayload(String payload) async {
    final messageData = json.decode(payload);
    final newMessage = NotificationMessage(
      id: messageData['id'],
      message: messageData['message'],
      receivedAt: DateTime.now(),
    );
    await NotificationDatabase.instance.create(newMessage);
    setState(() {
      notificationMessagesFuture =
          NotificationDatabase.instance.readAllNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Notifications",
        actions: [
          IconButton(
            onPressed: () => _showDeleteConfirmationDialog(context),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: FutureBuilder<List<NotificationMessage>>(
        future: notificationMessagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading notifications'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications to display'));
          } else {
            final notificationMessages = snapshot.data!;
            return ListView.builder(
              itemCount: notificationMessages.length,
              itemBuilder: (context, index) {
                final message = notificationMessages[index];
                final formattedDateTime = DateFormat('MMM dd, yyyy hh:mm a')
                    .format(message.receivedAt);

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    title: Text(message.message,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Received at: $formattedDateTime'),
                    leading: const Icon(Icons.notification_important,
                        color: Colors.blue),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Notifications'),
        content: const Text('Do you want to delete all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              NotificationDatabase.instance.clearNotifications();
              setState(() {
                notificationMessagesFuture =
                    NotificationDatabase.instance.readAllNotifications();
              });
              Navigator.of(context).pop();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
