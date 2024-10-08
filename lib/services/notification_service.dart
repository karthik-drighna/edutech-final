import 'package:drighna_ed_tech/main.dart';
import 'package:drighna_ed_tech/sqflite/notification_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:drighna_ed_tech/provider/notification_count_provider.dart';
import 'package:drighna_ed_tech/screens/students/student_notification_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class NotificationService {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final ProviderContainer container;

  NotificationService(this.container) {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/splash');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        _handleNotificationResponse(response.payload);
      },
    );
  }

  Future<void> showNotification(RemoteNotification notification,
      {String? payload}) async {
    // Generate a unique ID based on notification data
    int notificationId = notification.hashCode;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/splash',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: payload,
    );

    // Save the notification message to SQFlite
    final newMessage = NotificationMessage(
      id: notificationId.toString(),
      message: notification.body ?? '',
      receivedAt: DateTime.now(),
    );
    await NotificationDatabase.instance.create(newMessage);

    // Increment the notification count
    container.read(notificationCountProvider.notifier).increment();
  }

  Future<void> incrCount(RemoteNotification notification) async {
    int notificationId = notification.hashCode;
    // Save the notification message to SQFlite
    final newMessage = NotificationMessage(
      id: notificationId.toString(),
      message: notification.body ?? '',
      receivedAt: DateTime.now(),
    );
    await NotificationDatabase.instance.create(newMessage);

    // // Increment the notification count
    // container.read(notificationCountProvider.notifier).increment();
  }

  void setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showNotification(message.notification!,
            payload: json.encode(message.data));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      if (message.notification != null) {
        _handleNotificationResponse(json.encode(message.data));
      }
    });
  }

  void _handleNotificationResponse(String? payload) {
    if (payload != null) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => StudentNotificationScreen(payload: payload),
        ),
        (route) => false,
      );
    }
  }
}
