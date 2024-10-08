import 'dart:convert';
import 'package:drighna_ed_tech/l10n/l10n.dart';
import 'package:drighna_ed_tech/provider/notification_count_provider.dart';
import 'package:drighna_ed_tech/routes/named_routes.dart';
import 'package:drighna_ed_tech/screens/students/student_notification_screen.dart';
import 'package:drighna_ed_tech/services/notification_service.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

const LinearGradient globalAppGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF0093E9),
    Color(0xFF80D0C7),
  ],
);

extension CustomThemeExtension on ThemeData {
  LinearGradient get appGradient => globalAppGradient;
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final container = ProviderContainer();
  // NotificationService(container).showNotification(message.notification!,
  //   payload: json.encode(message.data));
  container
      .read(notificationCountProvider.notifier)
      .increment(); // Increment the counter here
}

Future<void> _firebaseMessagingOpenedAppHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final container = ProviderContainer();
  // NotificationService(container).showNotification(message.notification!,
  //   payload: json.encode(message.data));

  NotificationService(container).incrCount(message.notification!);

  container
      .read(notificationCountProvider.notifier)
      .increment(); // Increment the counter here
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessageOpenedApp
      .listen(_firebaseMessagingOpenedAppHandler);

  final container = ProviderContainer();
  final notificationService = NotificationService(container); // Initialize here

  runApp(
    ProviderScope(
      parent: container, // Ensure the same container is used here
      child: MyApp(notificationService: notificationService),
    ),
  );
}

class MyApp extends StatefulWidget {
  final NotificationService notificationService;
  const MyApp({required this.notificationService, super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String langCode = "en";
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    getLocalData();
    widget.notificationService.setupFirebaseMessaging();
    _initialization = _checkInitialMessage();
  }

  Future<void> getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedLangCode = prefs.getString(Constants.langCode);
    if (storedLangCode != null) {
      setState(() {
        langCode = storedLangCode;
      });
    }
  }

  Future<void> _checkInitialMessage() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    RemoteMessage? initialMessage = await messaging.getInitialMessage();

    if (initialMessage != null && initialMessage.notification != null) {
      String payload = json.encode({
        'id': DateTime.now().toString(),
        'message': initialMessage.notification!.body,
      });
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => StudentNotificationScreen(payload: payload),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: const Color(0xFF0093E9),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Color(0xFF0093E9),
              ),
              buttonTheme: const ButtonThemeData(
                buttonColor: Color(0xFF0093E9),
                textTheme: ButtonTextTheme.primary,
              ),
            ),
            locale: Locale(langCode),
            supportedLocales: L10n.all,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            initialRoute: '/',
            routes: routes,
          );
        }
      },
    );
  }
}
