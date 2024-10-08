import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drighna_ed_tech/main.dart';
import 'package:drighna_ed_tech/models/album1.dart';
import 'package:drighna_ed_tech/models/notice_board_model.dart';
import 'package:drighna_ed_tech/provider/app_logo_provider.dart';
import 'package:drighna_ed_tech/provider/notification_count_provider.dart';
import 'package:drighna_ed_tech/screens/login_screen.dart';
import 'package:drighna_ed_tech/screens/students/student_notification_screen.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/utils/date_format_converter.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/dashboard_cards.dart';
import 'package:drighna_ed_tech/widgets/parents_other_section_cards.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:drighna_ed_tech/widgets/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../provider/user_data_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  //decoration
  String userName = '';
  late String admissionNo;
  String userImage = '';
  String classSection = '';
  String studentName = '';
  String primaryColor = '';
  String secondaryColor = '';

  String device_token =
      "e1WORCOlR--HLjQnIA4_g2:APA91bE_znn-7UUCpOzGxwpQG3WCGxdT22Yroy0A1_nejuwlDFIGfQ4U32N0Rj38m5QK1GSYM94oUJ5gvP2FJAzOXtpkKVAwiwJ0xo6hv3JnAlRa_smUjsmGCGy4bgkpM23-hx6IuVK7";

  List<String> childIdList = [];
  List<String> childNameList = [];
  List<String> childClassList = [];
  List<String> childImageList = [];
  List<String> childAdmissionNo = [];

  List<Album1> communicateAlbumList = [];
  List<Album1> elearningAlbumList = [];
  List<Album1> academicAlbumList = [];
  List<Album1> otherAlbumList = [];

  int _currentIndex = 0;
  String domainUrl = '';
  String langCode = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String loginTypeOfuser = '';
  List<NoticeBoardModel> noticeList = [];
  bool isLoading = true;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late Timer timer;
  String studentId = "";

  @override
  void initState() {
    super.initState();
    // _loadAppLogo();
    getNoticeBoardDataFromApi();
    // getNotification();
    prepareDataForStudentprofile();
    getDatasFromApi();
    checkLoginType();
    prepareNavList();
    setUpPermissions();
    fetchStudentCurrency();
  }

  // getNotification() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   studentId = prefs.getString(Constants.studentId) ?? "";
  //   print("????????????===StudentId for notifcation------------" + studentId);
  //   flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //   var initializationSettingsAndroid =
  //       const AndroidInitializationSettings('@drawable/edutech_logo');
  //   var initializationSettings = InitializationSettings(
  //     android: initializationSettingsAndroid,
  //   );
  //   flutterLocalNotificationsPlugin.initialize(
  //     initializationSettings,
  //     onDidReceiveNotificationResponse: (NotificationResponse response) {
  //       handleNotificationTap(response.payload, ref);
  //     },
  //   );

  //   _setupNotificationChannel();

  //   timer = Timer.periodic(const Duration(seconds: 10),
  //       (Timer t) => getNotificationDataFromApi(ref));
  // }

  // void _setupNotificationChannel() async {
  //   const AndroidNotificationChannel channel = AndroidNotificationChannel(
  //     'your_channel_id', // id
  //     'your_channel_name', // name
  //     description: 'your_channel_description', // description
  //     importance: Importance.max,
  //   );
  //   await flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //           AndroidFlutterLocalNotificationsPlugin>()
  //       ?.createNotificationChannel(channel);
  // }

  // void handleNotificationTap(String? payload, WidgetRef ref) {
  //   // Handle notification tap logic here
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => Homework()),
  //   );

  //   ref.read(notificationCountProvider.notifier).decrement(); // Decrement count

  //   print("Notification clicked: $payload");
  // }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  // Future<void> getNotificationDataFromApi(WidgetRef ref) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String apiUrl = prefs.getString(Constants.apiUrl) ?? "";
  //   String url = apiUrl + Constants.getHomeworkUrl;

  //   var response = await http.post(
  //     Uri.parse(url),
  //     headers: {
  //       'Client-Service': Constants.clientService,
  //       'Auth-Key': Constants.authKey,
  //       'Content-Type': Constants.contentType,
  //       'User-ID': prefs.getString(Constants.userId) ?? "",
  //       'Authorization': prefs.getString("accessToken") ?? "",
  //     },
  //     body: jsonEncode({
  //       'student_id': studentId,
  //       'homework_status': "pending",
  //       'subject_group_subject_id': ""
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     print(data.toString());
  //     List<String> currentData = [];
  //     for (var item in data['homeworklist']) {
  //       currentData.add(item['id']); // Parse the description
  //     }
  //     print("Current Data: $currentData");

  //     final previousData = ref.read(homeworkDataNotifierProvider);
  //     List<String> newData = [];
  //     for (var item in currentData) {
  //       if (!previousData.contains(item)) {
  //         newData.add(item);
  //       }
  //     }

  //     if (newData.isNotEmpty && previousData.isNotEmpty) {
  //       showNotification("New homework assigned");
  //       ref
  //           .read(notificationCountProvider.notifier)
  //           .increment(); // Increment count

  //       // Add new notification message
  //       final notificationMessage = NotificationMessage(
  //         id: DateTime.now().millisecondsSinceEpoch.toString(),
  //         message: "New homework assigned",
  //         receivedAt: DateTime.now(),
  //       );
  //       ref
  //           .read(homeworkNotificationMessagesProvider.notifier)
  //           .addMessage(notificationMessage);
  //     }

  //     ref.read(homeworkDataNotifierProvider.notifier).updateData(currentData);
  //   } else {
  //     print("Failed to load data");
  //   }
  // }

  // Future<void> showNotification(String message) async {
  //   var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
  //     'your_channel_id',
  //     'your_channel_name',
  //     channelDescription: 'your_channel_description',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     showWhen: false,
  //   );
  //   var platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
  //   );

  //   print("Attempting to show notification: $message");
  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     'Notification',
  //     message,
  //     platformChannelSpecifics,
  //     payload: 'item x',
  //   );
  //   print("Notification shown");
  // }

  void prepareDataForStudentprofile() async {
    if (await isConnectingToInternet()) {
      final prefs = await SharedPreferences.getInstance();
      String apiUrl = prefs.getString("apiUrl") ?? "";
      userImage = prefs.getString(Constants.userImage) ?? "";
      // admissionNo = prefs.getString(Constants.admission_no) ?? "";

      userName = prefs.getString(Constants.userName) ?? "";

      domainUrl = prefs.getString(Constants.appDomain) ?? "";
      final body = jsonEncode({
        "student_id": prefs.getString("studentId"),
      });
      ref
          .read(studentProfileProvider.notifier)
          .fetchStudentProfile(apiUrl, body);
    } else {
      print("No internet connection");
    }
  }

  // Future<void> _loadAppLogo() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String baseLogoUrl = prefs.getString(Constants.appLogo) ?? '';
  //   setState(() {
  //     // Append a random query parameter to the URL to avoid caching
  //     _appLogoUrl = '$baseLogoUrl?${Random().nextInt(100)}';
  //   });
  //   print("App Logo url is >>>>>>>>>>>>>>>>>" + _appLogoUrl);
  // }

  Future<void> getElearningFromApi(bodyparams) async {
    final prefs = await SharedPreferences.getInstance();
    // Add your headers
    final headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": "application/json",
      "User-ID": prefs.getString("userId") ?? "",
      "Authorization": prefs.getString("accessToken") ?? "",
    };

    String apiUrl = prefs.getString("apiUrl") ?? "";
    String getELearningUrl = Constants.getELearningUrl;
    String url = "$apiUrl$getELearningUrl";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyparams,
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        // Process your result here

        final modulesJson = result["module_list"] as List;

        // Assuming you have a predefined list of covers like in your Android code
        List<String> covers = [
          'assets/ic_dashboard_homework.png',
          'assets/ic_assignment.png',
          'assets/ic_lessonplan.png',
          'assets/ic_onlineexam.png',
          'assets/ic_downloadcenter.png',
          'assets/ic_onlinecourse.png',
          'assets/ic_videocam.png',
          'assets/ic_videocam.png',
        ];

        prefs.setString(Constants.modulesArray, modulesJson.toString());

        // Clear the list before adding new items to avoid duplication
        elearningAlbumList.clear();

        for (int i = 0; i < modulesJson.length; i++) {
          final module = modulesJson[i];
          if (module["status"] == "1") {
            Album1 album = Album1(
              name: module["name"],
              value: module["short_code"],
              thumbnail: covers[i],
              // For thumbnail, use AssetImage or NetworkImage based on your actual use case
            );
            elearningAlbumList.add(album);
          }
        }

        // Update the UI
        setState(() {});
      } else {
        // Handle server error
      }
    } catch (e) {
      print("Error fetching eLearning data: $e");
      // Handle network error
    }
  }

  Future<void> getCommunicateFromApi(bodyParams) async {
    final prefs = await SharedPreferences.getInstance();
    final headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": "application/json",
      "User-ID": prefs.getString("userId") ?? "",
      "Authorization": prefs.getString("accessToken") ?? "",
    };

    String apiUrl = prefs.getString("apiUrl") ?? "";
    String getCommunicateUrl = Constants.getCommunicateUrl;
    String url = "$apiUrl$getCommunicateUrl";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyParams,
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final modulesJson = result["module_list"] as List;

        List<String> covers = [
          'assets/ic_notice.png',
          'assets/ic_notification.png',
        ];

        prefs.setString(Constants.modulesArray, modulesJson.toString());
        // Clear the list before adding new items to avoid duplication
        communicateAlbumList.clear();

        for (int i = 0; i < modulesJson.length; i++) {
          final module = modulesJson[i];
          if (module["status"] == "1") {
            Album1 album = Album1(
              name: module["name"],
              value: module["short_code"],
              thumbnail: covers[i], // Adjust indexing for covers
            );
            communicateAlbumList.add(album);
          }
        }

        setState(() {}); // Update UI
      } else {
        // Handle server error
        print("Server error: ${response.body}");
      }
    } catch (e) {
      print("Error fetching communication data: $e");
      // Handle network error
    }
  }

  Future<void> fetchStudentCurrency() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> params = {
        "student_id": prefs.getString(Constants.studentId) ?? '',
      };

      await getCurrencyDataFromApi(json.encode(params));
    } else {
      // Show toast or message indicating no internet connection
      print('No internet connection.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> isConnectingToInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<String?> getSharedPreference(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  void checkLoginType() async {
    bool isConnected = await isConnectingToInternet();
    if (isConnected) {
      String? loginType = await getSharedPreference(Constants.loginType);

      if (loginType == "parent") {
        String? studentId = await getSharedPreference("studentId");
        String? userId = await getSharedPreference("userId");
        String? apiUrl = await getSharedPreference("apiUrl");

        // Assuming getDateOfMonth is implemented and returns String

        String getDateOfMonth(DateTime date, String index) {
          DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
          DateTime lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

          if (index == "first") {
            return "${firstDayOfMonth.year}-${firstDayOfMonth.month.toString().padLeft(2, '0')}-${firstDayOfMonth.day.toString().padLeft(2, '0')}";
          } else {
            return "${lastDayOfMonth.year}-${lastDayOfMonth.month.toString().padLeft(2, '0')}-${lastDayOfMonth.day.toString().padLeft(2, '0')}";
          }
        }

        String dateFrom = getDateOfMonth(DateTime.now(), "first");
        String dateTo = getDateOfMonth(DateTime.now(), "last");

        Map<String, String> obj = {
          "student_id": studentId ?? "",
          "date_from": dateFrom,
          "date_to": dateTo,
          "role": loginType ?? "",
          "user_id": userId ?? "",
        };

        final body = jsonEncode({
          "student_id": studentId,
        });
        ref
            .read(studentProfileProvider.notifier)
            .fetchStudentProfile(apiUrl!, body);

        // setState(() {
        //   ref.invalidate(decoratorProvider);
        // });

        getDataFromApi(obj);
      } else {
        //for Student
        String? studentId = await getSharedPreference("studentId");
        // String? userId = await getSharedPreference("userId");

        String getDateOfMonth(DateTime date, String index) {
          DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
          DateTime lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

          if (index == "first") {
            return "${firstDayOfMonth.year}-${firstDayOfMonth.month.toString().padLeft(2, '0')}-${firstDayOfMonth.day.toString().padLeft(2, '0')}";
          } else {
            return "${lastDayOfMonth.year}-${lastDayOfMonth.month.toString().padLeft(2, '0')}-${lastDayOfMonth.day.toString().padLeft(2, '0')}";
          }
        }

        String dateFrom = getDateOfMonth(DateTime.now(), "first");

        String dateTo = getDateOfMonth(DateTime.now(), "last");

        Map<String, String> obj = {
          "student_id": studentId ?? "",
          "date_from": dateFrom,
          "date_to": dateTo,
          "role": loginType ?? "",
        };

        getDataFromApi(obj);
      }
    } else {
      _showSnackBar("not connected to internet");
    }
  }

  Future<void> getDatasFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve the site_url from shared preferences
    String siteUrl = prefs.getString('imagesUrl') ??
        ''; // Default to empty string if not found

    Map<String, dynamic> params = {
      "site_url": siteUrl,
    };
    String bodyParams = json.encode(params); // Convert map to a JSON string

    String url = "https://sstrace.qdocs.in/postlic/verifyappjsonv2";
    final Map<String, String> headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": "application/json",
      "User-ID": prefs.getString("userId") ?? "",
      "Authorization": prefs.getString("accesstoken") ?? ""
    };
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyParams,
      );
      if (response.statusCode == 200) {
        var result = json.decode(response.body);

        if (result['status'] == "1") {
          prefs.setBool(Constants.isLoggegIn, false);
          // Your logic here
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Title"),
                content: Text(result['msg']),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Map<String, dynamic> logoutParams = {
                        "deviceToken": device_token,
                        // Add other logout parameters here as needed
                      };

                      loginOutApi(context, logoutParams);
                    },
                  ),
                ],
              );
            },
          );
        } else {
          final prefs = await SharedPreferences.getInstance();
          String loginType = prefs.getString(Constants.loginType) ?? '';
          String id = prefs.getString("studentId") ?? '';

          if (loginType == "student") {
            Map<String, dynamic> params = {
              "id": id,
              "user_type": loginType,
            };
            checkStudentStatus(json.encode(params));
          } else {
            id = prefs.getString(Constants.parentsId) ?? "";
            Map<String, dynamic> params = {
              "id": id,
              "user_type": loginType,
            };

            checkStudentStatus(json.encode(params));
          }
        }
      } else {
        // Handle server error
        print("Server error: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
      // Handle network error
    }
  }

  Future<void> getNoticeBoardDataFromApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String loginType = prefs.getString('loginType') ?? '';
    String userId = prefs.getString('userId') ?? '';
    String accessToken = prefs.getString('accessToken') ?? '';

    final bodyParams = {
      "type": loginType,
    };

    final url = Uri.parse('$apiUrl${Constants.getNotificationsUrl}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Client-Service': Constants.clientService,
          'Auth-Key': Constants.authKey,
          'User-ID': userId,
          'Authorization': accessToken,
        },
        body: json.encode(bodyParams),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // String success = jsonResponse['success'];
        // if (success == 1) {
        //   setState(() {
        //     isLoading = false;
        //   });

        List<dynamic> dataArray = jsonResponse['data'];

        for (int i = 0; i < dataArray.length; i++) {
          NoticeBoardModel notice = NoticeBoardModel.fromJson(dataArray[i]);
          noticeList.add(notice);
        }
        setState(() {
          isLoading = false;
        });
        // else {
        //   setState(() {
        //     isLoading = false;
        //   });
        //   // Handle unsuccessful response
        // }
      } else {
        setState(() {
          isLoading = false;
        });
        // Handle other status codes
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error: $error");
    }
  }

  Future<void> getDataFromApi(Map<String, dynamic> params) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? apiUrl = prefs.getString('apiUrl');
    String? userId = prefs.getString('userId');
    String? accessToken = prefs.getString('accessToken');

    // Construct the full URL
    String url = "$apiUrl${Constants.getDashboardUrl}";

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Client-Service": Constants.clientService,
          "Auth-Key": Constants.authKey,
          "Content-Type": Constants.contentType,
          "User-ID": userId ?? "",
          "Authorization": accessToken ?? "",
        },
        body: json.encode(params),
      );

      if (response.statusCode == 200) {
        // Parse the JSON response if needed or handle it as a raw string
        var result = json.decode(response.body);

        // Update shared preferences with new data
        await prefs.setString(Constants.classId, result['class_id']);
        await prefs.setString(Constants.sectionId, result['section_id']);
      } else {
        // Handle error response
        print('Failed to load data with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the request
      print('Error making the request: $e');
    }
  }

  Future<void> prepareNavList() async {
    var isConnected =
        await (Connectivity().checkConnectivity()) != ConnectivityResult.none;
    if (isConnected) {
      final prefs = await SharedPreferences.getInstance();
      String? loginType = prefs.getString(Constants.loginType);

      loginTypeOfuser = prefs.getString(Constants.loginType) ?? "";

      if (loginType != null) {
        var params = {'user': loginType};

        getElearningFromApi(jsonEncode(params));
        getCommunicateFromApi(jsonEncode(params));
        getAcademicsFromApi(jsonEncode(params));
        getOthersFromApi(jsonEncode(params));
      }
    } else {
      _showSnackBar("No internet connection");
    }
  }

  Future<void> getOthersFromApi(bodyParams) async {
    print("Fetching Others Modules...");
    final prefs = await SharedPreferences.getInstance();
    final headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": "application/json",
      "User-ID": prefs.getString("userId") ?? "",
      "Authorization": prefs.getString("accessToken") ?? "",
    };

    String apiUrl = prefs.getString("apiUrl") ?? "";
    String getOthersUrl = Constants.getOthersUrl;
    String url = "$apiUrl$getOthersUrl";

    try {
      // Showing loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const PencilLoaderProgressBar();
        },
      );

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyParams,
      );

      // Dismiss the loading indicator
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print("Modules Result for others: $result");

        final modulesJson = result["module_list"] as List;
        print("Modules length: ${modulesJson.length}");

        List<String> covers = [
          'assets/ic_nav_fees.png',
          'assets/ic_leave.png',
          'assets/ic_visitors.png',
          'assets/ic_nav_transport.png',
          'assets/ic_nav_hostel.png',
          'assets/ic_dashboard_pandingtask.png',
          'assets/ic_library.png',
          'assets/ic_teacher.png',
        ];

        // Clear the list before adding new items to avoid duplication
        otherAlbumList.clear();

        for (int i = 0; i < modulesJson.length; i++) {
          final module = modulesJson[i];
          if (module["status"] == "1") {
            Album1 album = Album1(
              name: module["short_code"],
              value: module["status"],
              thumbnail: covers[i], // Example handling for covers
            );
            otherAlbumList.add(album);
          }
        }

        setState(() {});
      } else {
        print("Server error: ${response.body}");
      }
    } catch (e) {
      // Dismiss the loading indicator in case of an error too
      Navigator.pop(context);
      print("Error fetching other modules: $e");
    }
  }

  Future<void> getCurrencyDataFromApi(String stdId) async {
    final prefs = await SharedPreferences.getInstance();
    final apiUrl = prefs.getString("apiUrl") ?? "";
    final userId = prefs.getString("userId") ?? "";
    final accessToken = prefs.getString("accessToken") ?? "";
    final url = "$apiUrl${Constants.getStudentCurrencyUrl}";

    // Prepare headers and body
    final headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": Constants.contentType,
      "User-ID": userId,
      "Authorization": accessToken,
    };

    final body = jsonEncode({
      "student_id": stdId,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        // final data = result['result'];

        // Save the fetched currency data to SharedPreferences
        await prefs.setString(
            Constants.currency_price, result['result']['base_price']);
        await prefs.setString(
            Constants.currency_short_name, result['result']['name']);
        await prefs.setString(Constants.currency, result['result']['symbol']);
      } else {
        print('Failed to fetch data from API');
        // Handle HTTP error
      }
    } catch (e) {
      print('An error occurred: $e');
      // Handle exceptions
    }
  }

  Future<void> setUpPermissions() async {
    // Request multiple permissions at once, now including Permission.phone.
    Map<Permission, PermissionStatus> statuses = await [
      Permission
          .storage, // Maps to Manifest.permission.READ_EXTERNAL_STORAGE and Manifest.permission.WRITE_EXTERNAL_STORAGE
      Permission.camera, // Maps to Manifest.permission.CAMERA
      Permission.microphone, // Maps to Manifest.permission.RECORD_AUDIO
      Permission.phone,
      Permission.notification

      // Add other permissions if needed.
    ].request();

    // Check if all permissions are granted.
    final isAllPermissionsGranted =
        statuses.values.every((status) => status.isGranted);

    if (!isAllPermissionsGranted) {
      // Handle the scenario when not all permissions are granted.
      print("Not all permissions granted.");
      // Implement your dialog or toast here.
    } else {
      print("All permissions granted.");
    }

    // Optionally, if you want to persist the permission status.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.permissionStatus, isAllPermissionsGranted);
  }

  Future<void> checkStudentStatus(String bodyParams) async {
    final prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String checkStudentStatusUrl =
        prefs.getString('checkStudentStatusUrl') ?? '';
    String url = "$apiUrl$checkStudentStatusUrl";

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Client-Service": Constants.clientService,
          "Auth-Key": Constants.authKey,
          "Content-Type": Constants.contentType,
        },
        body: bodyParams,
      );

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        String responseValue = result["response"];
        print("response=$responseValue");
        await prefs.setString("response", responseValue);

        if (prefs.getString("response") == "no") {
          await prefs.setBool("isLoggedIn", false);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) =>
                    const LoginScreen()), // Replace Login() with your login screen widget
            (Route<dynamic> route) => false,
          );
        }
      } else {
        print("Server error: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void showChildList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the sheet to expand to full screen if needed
      backgroundColor: Colors.transparent, // Optional: for better styling
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(top: 20), // Top padding for aesthetics
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(25.0)), // Rounded corners at the top
          ),
          child: Wrap(
            // Use Wrap to adjust to the content size dynamically
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(25.0)), // Consistent rounded corners
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'Child List',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              18, // Larger font size for better readability
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap:
                    true, // Important to make ListView only occupy needed space
                physics:
                    const NeverScrollableScrollPhysics(), // Disables scrolling within the ListView
                itemCount: childNameList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: Colors.white,
                    elevation: 5,
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: childImageList[index] != null
                          ? Image.network(
                              childImageList[index],
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                return const Icon(Icons.error);
                              },
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const CircularProgressIndicator();
                              },
                            )
                          : CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              child:
                                  Icon(Icons.person, color: Colors.grey[700]),
                            ),
                      title: Text(
                        childNameList[index],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(childClassList[index]),
                      onTap: () async {
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setString(
                            Constants.admission_no, childAdmissionNo[index]);
                        await prefs.setBool(Constants.isLoggegIn, true);

                        await prefs.setString(
                            Constants.classSection, childClassList[index]);

                        await prefs.setString(
                            Constants.studentId, childIdList[index]);
                        await prefs.setString(
                            "studentName", childNameList[index]);
                        // await prefs.setString('selectedChild', jsonEncode(children[0]));
                        SnackbarUtil.showSnackBar(context,
                            "Showing result of " + childNameList[index],
                            backgroundColor: Colors.green);
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(
                        //       content: Text(
                        //           "Showing result for "+childNameList[index].toString())),
                        // );
                        ref.invalidate(
                            decoratorProvider); //trigger the provider

                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (_) =>
                                const DashboardScreen())); // Adjust as needed
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> loginOutApi(BuildContext context, logoutParams) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString("apiUrl") ?? "";
    String logoutUrl = apiUrl + Constants.logoutUrl; // Your logout endpoint
    Map<String, String> headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": "application/json",
      "User-ID": prefs.getString("userId") ?? "",
      "Authorization": prefs.getString("accessToken") ?? "",
    };

    // Step 2: Perform the logout request
    try {
      final response = await http.post(
        Uri.parse(logoutUrl),
        headers: headers,
        body: jsonEncode(logoutParams),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result["status"] == "1") {
          await prefs.setBool("isLoggedIn", false);

          String schoolDomain = prefs.getString("schoolDomain") ?? "";

          getDomainDataFromApi(schoolDomain);

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) =>
                    const LoginScreen()), // Navigate to the LoginScreen
            (Route<dynamic> route) => false,
          );
        } else {
          _showSnackBar("status is 0");
        }
      } else {
        _showSnackBar("status code is not 200");
      }
    } catch (e) {
      _showSnackBar("Error occured $e");
    }
  }

  Future<void> getDomainDataFromApi(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String schoolAppDomain = prefs.getString("schoolAppDomain") ?? "";
    prefs.clear();
    // if (!domain.endsWith("/")) {
    //   domain += "/";
    // }
    // String url = domain + "app";

    prefs.setString("schoolDomain", url);
    prefs.setString("schoolAppDomain", schoolAppDomain);

    prefs.setString(Constants.appDomain, schoolAppDomain);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": Constants.contentType,
          "Client-Service": Constants.clientService,
          "Auth-Key": Constants.authKey,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        await _processResponse(result);
      } else {
        _showSnackBar('Invalid Domain.');

        // ScaffoldMessenger.of(context)
        //     .showSnackBar(const SnackBar(content: Text('Invalid Domain.')));
      }
    } catch (e) {
      langCode = "";

      _showSnackBar('An error occurred: $e');

      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    } finally {}
  }

  Future<void> _processResponse(Map<String, dynamic> result) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isUrlTaken', true);
    await prefs.setString('apiUrl', result['url']);
    await prefs.setString('imagesUrl', result['site_url']);

    await prefs.setString(Constants.app_ver, result["app_ver"]);
    String appLogo = result["site_url"] +
        "uploads/school_content/logo/app_logo/" +
        result["app_logo"];
    await prefs.setString(Constants.appLogo, appLogo);

    String secColour = result["app_secondary_color_code"];
    String primaryColour = result["app_primary_color_code"];
    if (secColour.length == 7 && primaryColour.length == 7) {
      await prefs.setString(Constants.secondaryColour, secColour);
      await prefs.setString(Constants.primaryColour, primaryColour);
    } else {
      await prefs.setString(
          Constants.secondaryColour, Constants.defaultSecondaryColour);
      await prefs.setString(
          Constants.primaryColour, Constants.defaultPrimaryColour);
    }

    langCode = result["lang_code"];
    await prefs.setString(Constants.langCode, langCode);

    if (!langCode.isEmpty) {
      //  setLocale(langCode);
    }

    final isMaintenanceMode = result['maintenance_mode'] == "1";
    await prefs.setBool('maintenance_mode', isMaintenanceMode);

    if (isMaintenanceMode) {
      showMaintenanceMessage();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  // void _showSnackBar(String message, Color color) {
  //   SnackbarUtil.showSnackBar(
  //     context,
  //     message,
  //     duration: 3,
  //     backgroundColor: color,
  //   );
  // }

  void showMaintenanceMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Maintenance"),
          content: const Text("The app is currently under maintenance."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> getAcademicsFromApi(bodyParams) async {
    print("Getting academics data...");
    final prefs = await SharedPreferences.getInstance();
    // Retrieve the necessary data from shared preferences
    String apiUrl = prefs.getString("apiUrl") ?? "";
    String getAcademicsUrl =
        Constants.getAcademicsUrl; // Ensure this constant is defined
    String url = "$apiUrl$getAcademicsUrl";

    // Setup your headers
    final headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": "application/json",
      "User-ID": prefs.getString("userId") ?? "",
      "Authorization": prefs.getString("accessToken") ?? "",
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyParams,
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print("Modules Result for academics: $result");

        final modulesJson = result["module_list"] as List;
        print("Modules length: ${modulesJson.length}");

        // Assuming you have a predefined list of covers like in your Android code
        List<String> covers = [
          'assets/ic_calender_cross.png',
          'assets/ic_lessonplan.png',
          'assets/ic_nav_attendance.png',
          'assets/ic_nav_reportcard.png',
          'assets/ic_nav_timeline.png',
          'assets/ic_documents_certificate.png',
          'assets/ic_dashboard_homework.png',
          'assets/ic_nav_reportcard.png', // Repeated if it's intentional
        ];

        prefs.setString(Constants.modulesArray, modulesJson.toString());

        // Clear the list before adding new items to avoid duplication
        academicAlbumList.clear();

        for (int i = 0; i < modulesJson.length; i++) {
          final module = modulesJson[i];
          if (module["status"] == "1") {
            Album1 album = Album1(
              name: module["name"],
              value: module["short_code"],
              thumbnail: covers[
                  i], // Make sure covers list has enough elements or handle this differently
              // For thumbnail, use AssetImage, NetworkImage, or appropriate widget
            );
            academicAlbumList.add(album);
          }
        }

        print("Academic List Updated");
        setState(() {}); // Update your UI if necessary
      } else {
        print("Server error: ${response.body}");
      }
    } catch (e) {
      print("Error fetching academics data: $e");
    }
  }

  Future<void> getStudentsListFromApi(
      BuildContext context, String bodyParams) async {
    childIdList.clear();
    childNameList.clear();
    childClassList.clear();
    childImageList.clear();
    childAdmissionNo.clear();

    // Fetch URL and headers from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? "";
    String parentsStudentsList = Constants.parent_getStudentList;
    String userId = prefs.getString('userId') ?? "";
    String accessToken = prefs.getString('accessToken') ?? "";
    String imgUrl = prefs.getString(Constants.imagesUrl) ?? "";

    // Assuming Constants are replaced with actual constants values
    String url = apiUrl + parentsStudentsList;

    Map<String, String> headers = {
      "Client-Service": Constants.clientService, // Adjust accordingly
      "Auth-Key": Constants.authKey, // Adjust accordingly
      "Content-Type": "application/json",
      "User-ID": userId,
      "Authorization": accessToken,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyParams,
      );

      // Navigator.pop(context); // Dismiss the loading dialog

      if (response.statusCode == 200) {
        // Parse the JSON data
        final result = json.decode(response.body);

        List<dynamic> dataList = result['childs'];

        if (dataList.length != 0) {
          for (var data in dataList) {
            childIdList.add(data["id"].toString());
            childNameList.add(
                "${data["firstname"].toString()} ${data["lastname"].toString()}");
            childClassList.add(
                "${data["class"].toString()}-${data["section"].toString()}");
            childImageList.add(imgUrl + data["image"].toString());
            childAdmissionNo.add(data["admission_no"].toString());
          }

          showChildList(context);
        } else {
          _showSnackBar(result['errorMsg']);
        }
      } else {
        // Handle error
      }
    } catch (e) {
      Navigator.pop(
          context); // Ensure loading dialog is dismissed in case of error
      print(e.toString());
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDataAsyncValue = ref.watch(decoratorProvider);
    final studentProfile = ref.watch(studentProfileProvider);

    final studentImage = "$domainUrl/${studentProfile?.imgUrl}";
    final admNo = studentProfile?.admissionNo ?? "N/A";

    // ref.invalidate(decoratorProvider);
    final List<DataSet> dataSets = [
      DataSet(
        id: "fees",
        name: AppLocalizations.of(context)!.fees,
        thumbnail: "assets/ic_nav_fees.png",
      ),
      DataSet(
        id: "attendance",
        name: AppLocalizations.of(context)!.attendance,
        thumbnail: "assets/ic_nav_attendance.png",
      ),
      DataSet(
        id: "exams_report_card",
        name: AppLocalizations.of(context)!.exams_report_card,
        thumbnail: "assets/ic_onlineexam.png",
      ),
      DataSet(
        id: "homework",
        name: AppLocalizations.of(context)!.home_work,
        thumbnail: "assets/ic_dashboard_homework.png",
      ),
      DataSet(
        id: "classwork",
        name: AppLocalizations.of(context)!.classwork,
        thumbnail: "assets/ic_dashboard_homework.png",
      ),
      DataSet(
        id: "class_time_table",
        name: AppLocalizations.of(context)!.class_time_table,
        thumbnail: "assets/ic_calender_cross.png",
      ),
      DataSet(
        id: "complaint",
        name: AppLocalizations.of(context)!.complaint,
        thumbnail: "assets/ic_dashboard_homework.png",
      ),
      DataSet(
        id: "lesson_plan",
        name: AppLocalizations.of(context)!.lesson_plan,
        thumbnail: "assets/ic_lessonplan.png",
      ),
      DataSet(
        id: "syllabus_status",
        name: AppLocalizations.of(context)!.syllabus_status,
        thumbnail: "assets/ic_lessonplan.png",
      ),
      DataSet(
        id: "transport_routes",
        name: AppLocalizations.of(context)!.transport_routes,
        thumbnail: "assets/ic_nav_transport.png",
      ),
      DataSet(
        id: "hostel_rooms",
        name: AppLocalizations.of(context)!.hostel_rooms,
        thumbnail: "assets/ic_nav_hostel.png",
      ),
      DataSet(
        id: "live_classes",
        name: AppLocalizations.of(context)!.live_classes,
        thumbnail: "assets/ic_videocam.png",
      ),
      DataSet(
        id: "apply_leave",
        name: AppLocalizations.of(context)!.apply_leave,
        thumbnail: "assets/ic_leave.png",
      ),
      DataSet(
        id: "download_center",
        name: AppLocalizations.of(context)!.download_center,
        thumbnail: "assets/ic_downloadcenter.png",
      ),
      DataSet(
        id: "documents",
        name: AppLocalizations.of(context)!.documents,
        thumbnail: "assets/ic_documents_certificate.png",
      ),
      DataSet(
        id: "library",
        name: AppLocalizations.of(context)!.library,
        thumbnail: "assets/ic_library.png",
      ),
      DataSet(
        id: "online_exam",
        name: AppLocalizations.of(context)!.online_exam,
        thumbnail: "assets/ic_onlineexam.png",
      ),
      DataSet(
        id: "online_class",
        name: AppLocalizations.of(context)!.online_class,
        thumbnail: "assets/ic_onlinecourse.png",
      ),
      DataSet(
        id: "teacher_ratings",
        name: AppLocalizations.of(context)!.teacher_ratings,
        thumbnail: "assets/ic_teacher.png",
      ),
    ];

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey[100],
        appBar: CustomAppBar(
          iconButtonLeading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          titleText: Consumer(
            builder: (context, ref, child) {
              final appLogoUrlAsyncValue = ref.watch(appLogoUrlProvider);

              return appLogoUrlAsyncValue.when(
                data: (url) => Image.network(
                  url, width: 90, // Set your desired width
                  height: 90, // And height
                  // color: Colors.black,
                  fit: BoxFit.contain,
                ),
                loading: () => const PencilLoaderProgressBar(),
                error: (error, stack) => Text('Failed to load logo: $error'),
              );
            },
          ),
          actions: [
            userDataAsyncValue.when(
              data: (Map<String, String> userData) {
                return userData['loginType'] == 'parent' &&
                        userData['hasMultipleChild'] == "true"
                    ? GestureDetector(
                        onTap: () async {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String userId = prefs.getString("userId") ?? "";

                          if (userId == null) {
                            print("User ID is null");
                            return;
                          }

                          Map<String, dynamic> params = {
                            "parent_id": userId,
                          };

                          // Convert params to JSON string
                          String bodyParams = json.encode(params);

                          getStudentsListFromApi(context, bodyParams);
                        },
                        child: const Tooltip(
                          message: "Switch Child",
                          child: Icon(
                            Icons.autorenew, // Round arrows icon
                            color: Colors.black, // Icon color
                            size: 26, // Icon size
                          ),
                        ),
                      )
                    : const SizedBox();
              },
              loading: () => const PencilLoaderProgressBar(),
              error: (error, stack) => Text('Error: $error'),
            ),
            Stack(
              children: [
                IconButton(
                  onPressed: () {
                    ref.read(notificationCountProvider.notifier).reset();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const StudentNotificationScreen()),
                    );
                  },
                  icon: const Icon(Icons.notifications),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final notificationCount =
                        ref.watch(notificationCountProvider);
                    return Positioned(
                      right: 11,
                      top: 11,
                      child: notificationCount > 0
                          ? Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              child: Text(
                                '$notificationCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : const SizedBox.shrink(),
                    );
                  },
                ),
              ],
            )
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              userDataAsyncValue.when(
                data: (Map<String, String> userData) {
                  if (userData['studentName'] != "") {
                    userName = userData['userName']!;
                  } else {
                    userName = userData['userName']!;
                  }

                  return DrawerHeader(
                    decoration: BoxDecoration(
                      border: const Border(
                        bottom: BorderSide(style: BorderStyle.solid, width: 2),
                      ),
                      gradient: Theme.of(context).appGradient,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: userImage,
                            height: 100,
                            width: 100,
                            placeholder: (context, url) => ClipOval(
                              child: Image.asset(
                                'assets/placeholder_user.png',
                                height: 80,
                                width: 80,
                              ),
                            ),
                            errorWidget: (context, url, error) => ClipOval(
                              child: Image.asset(
                                'assets/placeholder_user.png',
                                height: 80,
                                width: 80,
                              ),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(
                            width: 10), // Space between the avatar and text

                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName, // Replace with your dynamic value
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 23),
                                ),
                                userData['loginType'] == 'parent'
                                    ? Text(
                                        "Child-${userData['studentName']}",
                                        overflow: TextOverflow
                                            .clip, // Replace with your dynamic value
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : const SizedBox(),
                                Text(
                                  "${userData['classSection']}",
                                ),
                                userData['loginType'] == 'parent' &&
                                        userData['hasMultipleChild'] == "true"
                                    ? Row(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Switch child", // Dynamic value or localized string
                                                style: TextStyle(),
                                              ),
                                              const SizedBox(width: 5),
                                              IconButton(
                                                onPressed: () async {
                                                  final SharedPreferences
                                                      prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  String userId =
                                                      prefs.getString(
                                                              "userId") ??
                                                          "";

                                                  if (userId == null) {
                                                    print("User ID is null");
                                                    return;
                                                  }

                                                  Map<String, dynamic> params =
                                                      {
                                                    "parent_id": userId,
                                                  };

                                                  // Convert params to JSON string
                                                  String bodyParams =
                                                      json.encode(params);

                                                  getStudentsListFromApi(
                                                      context, bodyParams);
                                                },
                                                icon: Icon(
                                                  Icons
                                                      .swap_horiz, // Example icon
                                                  color: Theme.of(context)
                                                      .iconTheme
                                                      .color, // Use theme for icon color
                                                  size: Theme.of(context)
                                                      .iconTheme
                                                      .size, // Use theme for icon size
                                                ),
                                              )

                                              // Space between text and icon
                                            ],
                                          ),
                                        ],
                                      )
                                    : const SizedBox()
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const PencilLoaderProgressBar(),
                error: (error, stack) => Text('Error: $error'),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: Text(AppLocalizations.of(context)!.home),
                onTap: () {
                  Navigator.pushNamed(context, '/home');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(AppLocalizations.of(context)!.profile),
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: Text(AppLocalizations.of(context)!.about_school),
                onTap: () {
                  Navigator.pushNamed(context, '/about');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(AppLocalizations.of(context)!.settings),
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              // ListTile(
              //   leading: const Icon(Icons.vpn_key),
              //   title: const Text("Change Password"),
              //   onTap: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => const ForgotPasswordScreen()));
              //   },
              // ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(AppLocalizations.of(context)!.logout),
                onTap: () async {
                  // Perform logout logic, then:

                  bool isConnected = await isConnectingToInternet();
                  if (isConnected) {
                    // Perform your API logout call
                    Map<String, dynamic> logoutParams = {
                      "deviceToken": device_token,
                    };

                    // Call the Logout function with the required deviceToken
                    await loginOutApi(context, logoutParams);
                  } else {
                    _showSnackBar("No internet connection");
                  }
                },
              ),
            ],
          ),
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverFillRemaining(
                child: userDataAsyncValue.when(
              data: (Map<String, String> userData) {
                // if (userData['admissionNo'] != "") {
                //   admissionNo = userData['admissionNo']!;
                // } else {
                //   admissionNo = userData['admissionNo']!;
                // }

                // admissionNo = userData['admissionNo']!;

                if (userData['studentName'] != "") {
                  userName = userData['userName']!;
                } else {
                  userName = userData['userName']!;
                }
                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        // decoration: BoxDecoration(
                        //   gradient: Theme.of(context).appGradient,
                        // ),
                        // height: 200,
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // GestureDetector(
                            //     onTap: () {
                            //       showDialog(
                            //         context: context,
                            //         builder: (BuildContext context) {
                            //           return Dialog(
                            //             backgroundColor: Colors.transparent,
                            //             child: PhotoView(
                            //               imageProvider:
                            //                   NetworkImage(userImage),
                            //               backgroundDecoration:
                            //                   const BoxDecoration(
                            //                 color: Colors.transparent,
                            //               ),
                            //               minScale:
                            //                   PhotoViewComputedScale.contained *
                            //                       0.8,
                            //               maxScale:
                            //                   PhotoViewComputedScale.covered *
                            //                       2,
                            //             ),
                            //           );
                            //         },
                            //       );

                            //       // Navigator.push(
                            //       //     context,
                            //       //     MaterialPageRoute(
                            //       //         builder: (context) =>
                            //       //             SharedPreferencesDetailsScreen()));
                            //     },
                            //     child: ClipOval(
                            //       child: CachedNetworkImage(
                            //         imageUrl: userImage,
                            //         height: 100,
                            //         width: 100,
                            //         placeholder: (context, url) => Image.asset(
                            //           'assets/placeholder_user.png',
                            //           height: 90,
                            //           width: 90,
                            //         ),
                            //         errorWidget: (context, url, error) =>
                            //             Image.asset(
                            //           'assets/placeholder_user.png',
                            //           height: 90,
                            //           width: 90,
                            //         ),
                            //         fit: BoxFit.cover,
                            //       ),
                            //     )),
                            // const SizedBox(
                            //   height: 10,
                            // ),

                            loginTypeOfuser == "parent"
                                ? Text(
                                    '${AppLocalizations.of(context)!.welcome} ${userName}!',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  )
                                : const SizedBox(),

                            loginTypeOfuser == "parent"
                                ? const SizedBox(
                                    height: 5,
                                  )
                                : const SizedBox(),

                            // userData['loginType'] == 'parent' &&
                            //         userData['hasMultipleChild'] == "true"
                            //     ? GestureDetector(
                            //         onTap: () async {
                            //           final SharedPreferences prefs =
                            //               await SharedPreferences.getInstance();
                            //           String userId =
                            //               prefs.getString("userId") ?? "";

                            //           if (userId == null) {
                            //             print("User ID is null");
                            //             return;
                            //           }

                            //           Map<String, dynamic> params = {
                            //             "parent_id": userId,
                            //           };

                            //           // Convert params to JSON string
                            //           String bodyParams = json.encode(params);

                            //           getStudentsListFromApi(
                            //               context, bodyParams);
                            //         },
                            //         child: Row(
                            //           mainAxisAlignment:
                            //               MainAxisAlignment.center,
                            //           crossAxisAlignment:
                            //               CrossAxisAlignment.center,
                            //           children: [
                            //             Container(
                            //               padding: const EdgeInsets.symmetric(
                            //                   horizontal: 12, vertical: 8),
                            //               decoration: BoxDecoration(
                            //                 color: Colors.blueAccent
                            //                     .withOpacity(
                            //                         0.1), // Background color
                            //                 borderRadius: BorderRadius.circular(
                            //                     8), // Rounded corners
                            //               ),
                            //               child: const Row(
                            //                 children: [
                            //                   Text(
                            //                     "Switch child", // Dynamic value or localized string
                            //                     style: TextStyle(
                            //                       fontWeight: FontWeight.bold,
                            //                       color: Colors
                            //                           .blueAccent, // Text color
                            //                     ),
                            //                   ),
                            //                   SizedBox(width: 8),
                            //                   Icon(
                            //                     Icons
                            //                         .swap_horiz, // Example icon
                            //                     color: Colors
                            //                         .blueAccent, // Icon color
                            //                     size: 24, // Icon size
                            //                   ),
                            //                 ],
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       )
                            //     : const SizedBox(),
                            loginTypeOfuser == "parent"
                                ? const SizedBox(
                                    height: 2,
                                  )
                                : const SizedBox(
                                    height: 5,
                                  ),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: PhotoView(
                                            imageProvider:
                                                NetworkImage(studentImage),
                                            backgroundDecoration:
                                                const BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                            minScale: PhotoViewComputedScale
                                                    .contained *
                                                0.8,
                                            maxScale:
                                                PhotoViewComputedScale.covered *
                                                    2,
                                          ),
                                        );
                                      },
                                    );

                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             SharedPreferencesDetailsScreen()));
                                  },
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: userImage,
                                      height: 100,
                                      width: 100,
                                      placeholder: (context, url) => ClipOval(
                                        child: Image.asset(
                                          'assets/placeholder_user.png',
                                          height: 80,
                                          width: 80,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          ClipOval(
                                        child: Image.asset(
                                          'assets/placeholder_user.png',
                                          height: 80,
                                          width: 80,
                                        ),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                loginTypeOfuser == "parent"
                                    ? const SizedBox()
                                    : Text(
                                        userName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: userData['loginType'] == 'parent'
                                            ? '${userData['studentName']} : '
                                            : "",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors
                                              .black, // You can change the color to highlight as needed
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '${AppLocalizations.of(context)!.admission_no} ${admNo!} ${userData['classSection'] ?? ''}',
                                        style: const TextStyle(
                                          color: Colors
                                              .black, // Match the color to the theme or as required
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      loginTypeOfuser == "parent"
                          ? const SizedBox(
                              height: 10,
                            )
                          : const SizedBox(
                              height: 5,
                            ),

                      userData['loginType'] == 'parent'
                          ? CarouselSlider(
                              options: CarouselOptions(
                                autoPlay: true,
                                enlargeCenterPage:
                                    false, // Set this to false to use the full width
                                viewportFraction:
                                    1.0, // Ensure each item takes the full width of the screen
                                height: 80, // Set a fixed height for each item
                                autoPlayInterval: const Duration(seconds: 5),
                                autoPlayAnimationDuration:
                                    const Duration(milliseconds: 800),
                                autoPlayCurve: Curves.fastOutSlowIn,
                              ),
                              items: noticeList.isEmpty
                                  ? [
                                      Center(
                                          child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        width: MediaQuery.of(context)
                                            .size
                                            .width, // This makes the container take the full screen width
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.blue.shade900,
                                              Colors.blue.shade600
                                            ], // Gradient colors
                                          ),
                                          border: Border.all(
                                              color: Colors.white,
                                              width:
                                                  2), // Adds white border around the card

                                          // boxShadow: [
                                          //   BoxShadow(
                                          //     color: Colors
                                          //         .black45, // Darker shadow for more elevation effect
                                          //     blurRadius: 20.0,
                                          //     spreadRadius: 0.0,
                                          //     offset: Offset(0,
                                          //         6), // Larger offset for a floating effect
                                          //   )
                                          // ],
                                          borderRadius: BorderRadius.circular(
                                              3), // Rounded corners
                                        ),

                                        child: const Center(
                                          child: Text(
                                            "Notice Board is empty",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ))
                                    ]
                                  : noticeList
                                      .map(
                                        (item) => InkWell(
                                          onTap: () {
                                            // Add your onTap functionality here
                                            Navigator.pushNamed(
                                                context, '/noticeBoard');
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width, // This makes the container take the full screen width
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.blue.shade900,
                                                  Colors.blue.shade600
                                                ], // Gradient colors
                                              ),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width:
                                                      2), // Adds white border around the card

                                              // boxShadow: [
                                              //   BoxShadow(
                                              //     color: Colors
                                              //         .black45, // Darker shadow for more elevation effect
                                              //     blurRadius: 20.0,
                                              //     spreadRadius: 0.0,
                                              //     offset: Offset(0,
                                              //         6), // Larger offset for a floating effect
                                              //   )
                                              // ],
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      3), // Rounded corners
                                            ),
                                            child: noticeList.isEmpty
                                                ? const Center(
                                                    child: Text(
                                                        'No data available',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)))
                                                : Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          softWrap: true,
                                                          item.title,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .white, // White text for better visibility
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10.0),
                                                      Text(
                                                        DateUtilities
                                                            .formatStringDate(
                                                                item.date),
                                                        style: const TextStyle(
                                                          fontSize: 14.0,
                                                          color: Colors
                                                              .white70, // Slightly lighter text for contrast
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            )
                          : const SizedBox(),

                      // Container(
                      //   alignment: Alignment.center,
                      //   // This inner container is the "line" indicating scrollability
                      //   width: 40, // Width of the line
                      //   height: 5, // Height of the line
                      //   margin: const EdgeInsets.only(
                      //       top: 8, bottom: 8), // Margin around the line
                      //   decoration: BoxDecoration(
                      //     color: Colors.black, // Line color
                      //     borderRadius: BorderRadius.circular(
                      //         2.5), // Rounded corners for the line
                      //   ),
                      // ),

                      userData['loginType'] == 'parent'
                          ? ParentsOtherSectionCards(listOfDataSets: dataSets)
                          : Container(
                              // padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(
                                  right: 12,
                                  left: 12,
                                  top: 5), // Margin around the card
                              // decoration: BoxDecoration(
                              //   color: Colors.white, // Card's background color
                              //   borderRadius:
                              //       BorderRadius.circular(10), // Rounded corners
                              //   boxShadow: [
                              //     BoxShadow(
                              //       color:
                              //           Colors.grey.withOpacity(0.5), // Shadow color
                              //       spreadRadius: 5, // Spread radius
                              //       blurRadius: 7, // Blur radius
                              //       offset: const Offset(
                              //           0, 3), // Changes position of shadow
                              //     ),
                              //   ],
                              // ),

                              child: _currentIndex == 0
                                  ? CardSection(
                                      listOfDataSets: elearningAlbumList,
                                    )
                                  : _currentIndex == 1
                                      ? CardSection(
                                          listOfDataSets: academicAlbumList)
                                      : _currentIndex == 2
                                          ? CardSection(
                                              listOfDataSets:
                                                  communicateAlbumList)
                                          : CardSection(
                                              listOfDataSets: otherAlbumList),

                              // Add more sections as needed
                            )
                    ],
                  ),
                );
              },
              loading: () => const PencilLoaderProgressBar(),
              error: (error, stack) => Text('Error: $error'),
            )),
          ],
        ),
        bottomNavigationBar: loginTypeOfuser != "parent"
            ? Padding(
                padding: const EdgeInsets.all(8), // Add bottom padding
                child: Container(
                  height: kBottomNavigationBarHeight + 15,
                  decoration: BoxDecoration(
                    gradient: Theme.of(context).appGradient,
                    borderRadius:
                        const BorderRadius.all(// Add rounded side borders
                            Radius.circular(35)),
                  ),
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    onTap: onTabTapped,
                    currentIndex: _currentIndex,
                    backgroundColor:
                        Colors.transparent, // Make background transparent
                    elevation: 0, // Remove shadow
                    selectedItemColor: const Color.fromARGB(255, 6, 9, 15),
                    unselectedItemColor: const Color.fromARGB(255, 82, 80, 80),
                    selectedFontSize: 16.0,
                    unselectedFontSize: 14.0,
                    selectedIconTheme: const IconThemeData(size: 30),
                    unselectedIconTheme: const IconThemeData(size: 22),

                    items: [
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.computer),
                        label: AppLocalizations.of(context)!.e_learning,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.book),
                        label: AppLocalizations.of(context)!.academics,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.chat),
                        label: AppLocalizations.of(context)!.communication,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.dashboard_customize),
                        label: AppLocalizations.of(context)!.others,
                      ),
                    ],
                    showUnselectedLabels: true,
                  ),
                ),
              )
            : null);
  }
}
