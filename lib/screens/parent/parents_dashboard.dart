// import 'dart:convert';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:drighna_ed_tech/main.dart';
// import 'package:drighna_ed_tech/models/album1.dart';
// import 'package:drighna_ed_tech/models/notice_board_model.dart';
// import 'package:drighna_ed_tech/provider/app_logo_provider.dart';
// import 'package:drighna_ed_tech/provider/notification_count_provider.dart';
// import 'package:drighna_ed_tech/provider/user_data_provider.dart';
// import 'package:drighna_ed_tech/screens/forgot_password_screen.dart';
// import 'package:drighna_ed_tech/screens/login_screen.dart';
// import 'package:drighna_ed_tech/screens/students/student_attendance.dart';
// import 'package:drighna_ed_tech/screens/students/student_exam.dart';
// import 'package:drighna_ed_tech/screens/students/student_fees.dart';
// import 'package:drighna_ed_tech/screens/students/student_notification_screen.dart';
// import 'package:drighna_ed_tech/screens/take_url_screen.dart';
// import 'package:drighna_ed_tech/utils/constants.dart';
// import 'package:drighna_ed_tech/utils/date_format_converter.dart';
// import 'package:drighna_ed_tech/widgets/notice_board_card.dart';
// import 'package:drighna_ed_tech/widgets/parents_other_section_cards.dart';
// import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
// import 'package:drighna_ed_tech/widgets/snackbar_message.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// class ParentsDashboard extends ConsumerStatefulWidget {
//   const ParentsDashboard({super.key});

//   @override
//   ConsumerState<ParentsDashboard> createState() => _ParentsDashboardState();
// }

// class _ParentsDashboardState extends ConsumerState<ParentsDashboard> {
//   String userName = '';
//   String admissionNo = '';
//   String userImage = '';
//   String classSection = '';
//   String studentName = '';
//   String primaryColor = '';
//   String secondaryColor = '';
//   List<String> childIdList = [];
//   List<String> childNameList = [];
//   List<String> childClassList = [];
//   List<String> childImageList = [];
//   List<String> childAdmissionNo = [];

//   List<Album1> communicateAlbumList = [];
//   List<Album1> elearningAlbumList = [];
//   List<Album1> academicAlbumList = [];
//   List<Album1> otherAlbumList = [];

//   List<NoticeBoardModel> noticeList = [];
//   bool isLoading = true;
//   String langCode = "";

//   List<Widget> studentData = [];
//   int _currentIndex = 0;
//   void onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   String device_token =
//       "e1WORCOlR--HLjQnIA4_g2:APA91bE_znn-7UUCpOzGxwpQG3WCGxdT22Yroy0A1_nejuwlDFIGfQ4U32N0Rj38m5QK1GSYM94oUJ5gvP2FJAzOXtpkKVAwiwJ0xo6hv3JnAlRa_smUjsmGCGy4bgkpM23-hx6IuVK7";
//   String domainUrl = '';

//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   void initState() {
//     super.initState();
//     // _loadAppLogo();
//     prepareDataOfprofile();
//     getNoticeBoardDataFromApi();
//   }

//   Future<void> getNoticeBoardDataFromApi() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String apiUrl = prefs.getString('apiUrl') ?? '';
//     String loginType = prefs.getString('loginType') ?? '';
//     String userId = prefs.getString('userId') ?? '';
//     String accessToken = prefs.getString('accessToken') ?? '';

//     final bodyParams = {
//       "type": loginType,
//     };

//     final url = Uri.parse('$apiUrl${Constants.getNotificationsUrl}');

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Client-Service': Constants.clientService,
//           'Auth-Key': Constants.authKey,
//           'User-ID': userId,
//           'Authorization': accessToken,
//         },
//         body: json.encode(bodyParams),
//       );

//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);

//         // String success = jsonResponse['success'];
//         // if (success == 1) {
//         //   setState(() {
//         //     isLoading = false;
//         //   });

//         List<dynamic> dataArray = jsonResponse['data'];

//         print("*****notice board data>>>>>>>>" + dataArray.toString());

//         for (int i = 0; i < dataArray.length; i++) {
//           NoticeBoardModel notice = NoticeBoardModel.fromJson(dataArray[i]);
//           noticeList.add(notice);
//         }
//         setState(() {
//           isLoading = false;
//         });
//         // else {
//         //   setState(() {
//         //     isLoading = false;
//         //   });
//         //   // Handle unsuccessful response
//         // }
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         // Handle other status codes
//       }
//     } catch (error) {
//       setState(() {
//         isLoading = false;
//       });
//       print("Error: $error");
//     }
//   }

//   void _showSnackBar(String message, Color color) {
//     SnackbarUtil.showSnackBar(
//       context,
//       message,
//       duration: 3,
//       backgroundColor: color,
//     );
//   }

//   Future<void> prepareDataOfprofile() async {
//     if (await isConnectingToInternet()) {
//       final prefs = await SharedPreferences.getInstance();
//       String apiUrl = prefs.getString("apiUrl") ?? "";

//       userName = prefs.getString(Constants.userName) ?? "";
//       userImage = prefs.getString(Constants.userImage) ?? "";
//       domainUrl = prefs.getString(Constants.appDomain) ?? "";
//       final body = jsonEncode({
//         "student_id": prefs.getString("studentId"),
//       });
//       ref
//           .read(studentProfileProvider.notifier)
//           .fetchStudentProfile(apiUrl, body);

//       String userId = prefs.getString("userId") ?? "";

//       Map<String, dynamic> params = {
//         "parent_id": userId,
//       };

//       // Convert params to JSON string
//       String bodyParams = json.encode(params);

//       getChilddetails(bodyParams);
//     } else {
//       print("No internet connection");
//     }
//   }

//   getChilddetails(bodyParams) async {
//     print("**********>>>>>>>>>Inside getStudentsListFromApi");
//     childIdList.clear();
//     childNameList.clear();
//     childClassList.clear();
//     childImageList.clear();
//     childAdmissionNo.clear();

//     // Fetch URL and headers from SharedPreferences
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     String apiUrl = prefs.getString('apiUrl') ?? "";
//     String parentsStudentsList = Constants.parent_getStudentList;
//     String userId = prefs.getString('userId') ?? "";
//     String accessToken = prefs.getString('accessToken') ?? "";
//     String imgUrl = prefs.getString(Constants.imagesUrl) ?? "";
//     String student_id = prefs.getString(Constants.studentId) ?? "";

//     // Assuming Constants are replaced with actual constants values
//     String url = apiUrl + parentsStudentsList;

//     print("***************>>>>>>>>>>" + url);

//     Map<String, String> headers = {
//       "Client-Service": Constants.clientService, // Adjust accordingly
//       "Auth-Key": Constants.authKey, // Adjust accordingly
//       "Content-Type": "application/json",
//       "User-ID": userId,
//       "Authorization": accessToken,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: headers,
//         body: bodyParams,
//       );

//       // Navigator.pop(context); // Dismiss the loading dialog

//       if (response.statusCode == 200) {
//         // Parse the JSON data
//         final result = json.decode(response.body);

//         print("*******list of children>>>>>" + result.toString());

//         List<dynamic> dataList = result['childs'];

//         print("******************>>>>>>>" + dataList.toString());

//         if (dataList.length != 0) {
//           for (var data in dataList) {
//             print("student data??????????*********" + data.toString());

//             // childIdList.add(data["id"].toString());
//             // childNameList.add(
//             //     "${data["firstname"].toString()} ${data["lastname"].toString()}");
//             // childClassList.add(
//             //     "${data["class"].toString()}-${data["section"].toString()}");
//             // childImageList.add(data["image"].toString());
//             // childAdmissionNo.add(data["admission_no"].toString());

//             bool slectedChildColor = student_id == data['id'];
//             setState(() {
//               studentData.add(InkWell(
//                 onTap: () {
//                   handleChildCardTap(
//                       data['id'],
//                       "${data["firstname"].toString()} ${data["lastname"].toString()}",
//                       "${data["class"].toString()}-${data["section"].toString()}",
//                       imgUrl + data["image"].toString(),
//                       data["admission_no"].toString(),
//                       data['class_id'].toString(),
//                       data['section_id']
//                           .toString()); // Pass any relevant data to the handler
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: slectedChildColor
//                           ? [Colors.blue.shade900, Colors.blue.shade600]
//                           : [Colors.transparent, Colors.transparent],

//                       // Example gradient colors
//                     ),
//                     // color:
//                     //     slectedChildColor ? Colors.blueAccent : Colors.white,
//                     border: slectedChildColor
//                         ? Border.all(color: Colors.black, width: 2)
//                         : Border.all(color: Colors.grey, width: 1),
//                     borderRadius: BorderRadius.circular(
//                         20), // Adjust the radius as necessary
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               imgUrl + data["image"].toString() != null
//                                   ? Image.network(
//                                       imgUrl + data["image"].toString(),
//                                       height: 40,
//                                       width: 40,
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (BuildContext context,
//                                           Object exception,
//                                           StackTrace? stackTrace) {
//                                         return Icon(
//                                           Icons.person,
//                                           color: Colors.grey[300],
//                                         ); // If the image fails to load
//                                       },
//                                       loadingBuilder: (BuildContext context,
//                                           Widget child,
//                                           ImageChunkEvent? loadingProgress) {
//                                         if (loadingProgress == null)
//                                           return child;
//                                         return const SizedBox(
//                                           height: 30,
//                                           width: 30,
//                                           child: Center(
//                                               child: PencilLoaderProgressBar()),
//                                         );
//                                       },
//                                     )
//                                   : const CircleAvatar(
//                                       child: Text(
//                                           "not set")), // Default image if URL is null

//                               const SizedBox(
//                                 width: 10,
//                               ),

//                               Flexible(
//                                 child: Text(
//                                   "${data["firstname"]} ${data["lastname"]}",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 15,
//                                       color: slectedChildColor
//                                           ? Colors.white
//                                           : Colors.grey[800]),
//                                   softWrap: true,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(
//                             height: 5,
//                           ),

//                           Text(
//                             "Class:  ${data["class"]}-${data["section"]}",
//                             style: TextStyle(
//                                 color: slectedChildColor
//                                     ? Colors.white
//                                     : Colors.grey[800]),
//                           ),
//                           Text(
//                             "Admission No: ${data["admission_no"]}",
//                             style: TextStyle(
//                                 color: slectedChildColor
//                                     ? Colors.white
//                                     : Colors.grey[800]),
//                           ),

//                           // SizedBox(height: 10),
//                         ]),
//                   ),
//                 ),
//               ));
//             });
//           }

//           print(
//               "*************************>>>>>>>>>>" + childNameList.toString());

//           // showChildList(context);
//         } else {
//           SnackbarUtil.showSnackBar(context, result['errorMsg']);
//         }
//       } else {
//         // Handle error
//         print('Server error: ${response.body}');
//       }
//     } catch (e) {
//       Navigator.pop(
//           context); // Ensure loading dialog is dismissed in case of error
//       print(e.toString());
//       // Handle error
//     }
//   }

//   Future<void> getStudentsListFromApi(
//       BuildContext context, String bodyParams) async {
//     print("**********>>>>>>>>>Inside getStudentsListFromApi");
//     childIdList.clear();
//     childNameList.clear();
//     childClassList.clear();
//     childImageList.clear();
//     childAdmissionNo.clear();

//     // Fetch URL and headers from SharedPreferences
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     String apiUrl = prefs.getString('apiUrl') ?? "";
//     String parentsStudentsList = Constants.parent_getStudentList;
//     String userId = prefs.getString('userId') ?? "";
//     String accessToken = prefs.getString('accessToken') ?? "";
//     String imgUrl = prefs.getString(Constants.imagesUrl) ?? "";

//     // Assuming Constants are replaced with actual constants values
//     String url = apiUrl + parentsStudentsList;

//     print("***************>>>>>>>>>>" + url);

//     Map<String, String> headers = {
//       "Client-Service": Constants.clientService, // Adjust accordingly
//       "Auth-Key": Constants.authKey, // Adjust accordingly
//       "Content-Type": "application/json",
//       "User-ID": userId,
//       "Authorization": accessToken,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: headers,
//         body: bodyParams,
//       );

//       // Navigator.pop(context); // Dismiss the loading dialog

//       if (response.statusCode == 200) {
//         // Parse the JSON data
//         final result = json.decode(response.body);

//         print("*******list of children>>>>>" + result.toString());

//         List<dynamic> dataList = result['childs'];

//         print("******************>>>>>>>" + dataList.toString());

//         if (dataList.length != 0) {
//           for (var data in dataList) {
//             childIdList.add(data["id"].toString());
//             childNameList.add(
//                 "${data["firstname"].toString()} ${data["lastname"].toString()}");
//             childClassList.add(
//                 "${data["class"].toString()}-${data["section"].toString()}");
//             childImageList.add(imgUrl + data["image"].toString());
//             childAdmissionNo.add(data["admission_no"].toString());
//           }

//           print(
//               "*************************>>>>>>>>>>" + childNameList.toString());

//           showChildList(context);
//         } else {
//           SnackbarUtil.showSnackBar(context, result['errorMsg']);
//           // _showSnackBar(result['errorMsg']);
//         }
//       } else {
//         // Handle error
//         print('Server error: ${response.body}');
//       }
//     } catch (e) {
//       Navigator.pop(
//           context); // Ensure loading dialog is dismissed in case of error
//       print(e.toString());
//       // Handle error
//     }
//   }

//   void showChildList(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           height: 300,
//           color: Colors.white,
//           child: Column(
//             children: <Widget>[
//               Container(
//                 // color:Color(0xFF9E9E9E),
//                 color: Theme.of(context)
//                     .secondaryHeaderColor, // Change this to your secondary color
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: <Widget>[
//                     const Expanded(
//                       child: Padding(
//                         padding: EdgeInsets.all(16.0),
//                         child: Text(
//                           'Child List',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             // set text style as per your design
//                           ),
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () {
//                         setState(() {
//                           Navigator.pop(context);
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: childNameList
//                       .length, // Assume childNameList is a list of strings
//                   itemBuilder: (BuildContext context, int index) {
//                     return Card(
//                       color: Colors.white,
//                       elevation: 10,
//                       child: ListTile(
//                         leading: childImageList[index] != null
//                             ? Image.network(
//                                 childImageList[index],
//                                 height: 30,
//                                 width: 30,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (BuildContext context,
//                                     Object exception, StackTrace? stackTrace) {
//                                   // If the image fails to load, you can return an error image or icon
//                                   return const Icon(Icons.person);
//                                 },
//                                 loadingBuilder: (BuildContext context,
//                                     Widget child,
//                                     ImageChunkEvent? loadingProgress) {
//                                   if (loadingProgress == null) return child;
//                                   return const SizedBox(
//                                     height:
//                                         30, // Match the Image.network height
//                                     width: 30, // Match the Image.network width
//                                     child: Center(
//                                       child: PencilLoaderProgressBar(),
//                                     ),
//                                   );
//                                 },
//                               )

//                             // Replace with the appropriate image provider
//                             : const CircleAvatar(
//                                 child: Text("not set"),
//                               ), // Default image
//                         title: Text(
//                           childNameList[index],
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         subtitle: Text(childClassList[index]),
//                         onTap: () async {
//                           final SharedPreferences prefs =
//                               await SharedPreferences.getInstance();
//                           prefs.setString(
//                               Constants.admission_no, childAdmissionNo[index]);
//                           await prefs.setBool(Constants.isLoggegIn, true);

//                           await prefs.setString(
//                               Constants.classSection, childClassList[index]);

//                           await prefs.setString(
//                               Constants.studentId, childIdList[index]);
//                           await prefs.setString(
//                               "studentName", childNameList[index]);
//                           // await prefs.setString('selectedChild', jsonEncode(children[0]));

//                           SnackbarUtil.showSnackBar(
//                             context,
//                             "Showing results for ${childNameList[index]}",
//                             duration: 3,
//                             backgroundColor: Colors.green,
//                           );

//                           ref.invalidate(
//                               decoratorProvider); //trigger the provider

//                           print("******student I now is>>>>>>>>>>>>>>" +
//                               prefs.getString(Constants.studentId).toString());

//                           Navigator.of(context).pushReplacement(MaterialPageRoute(
//                               builder: (_) =>
//                                   const ParentsDashboard())); // Adjust as needed
//                         },
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showNotification() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Notice'),
//           content: const Text('This functionality is yet to be added.'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Closes the dialog
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void prepareData() async {
//     if (await isConnectingToInternet()) {
//       final prefs = await SharedPreferences.getInstance();
//       String apiUrl = prefs.getString("apiUrl") ?? "";

//       userName = prefs.getString(Constants.userName) ?? "";
//       domainUrl = prefs.getString(Constants.appDomain) ?? "";
//       final body = jsonEncode({
//         "student_id": prefs.getString("studentId"),
//       });
//       ref
//           .read(studentProfileProvider.notifier)
//           .fetchStudentProfile(apiUrl, body);
//     } else {
//       print("No internet connection");
//     }
//   }

//   Future<bool> isConnectingToInternet() async {
//     var connectivityResult = await Connectivity().checkConnectivity();
//     if (connectivityResult == ConnectivityResult.mobile ||
//         connectivityResult == ConnectivityResult.wifi) {
//       return true;
//     }
//     return false;
//   }

//   Future<void> loginOutApi(BuildContext context, logoutParams) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     String apiUrl = prefs.getString("apiUrl") ?? "";
//     String logoutUrl = apiUrl + Constants.logoutUrl; // Your logout endpoint
//     Map<String, String> headers = {
//       "Client-Service": Constants.clientService,
//       "Auth-Key": Constants.authKey,
//       "Content-Type": "application/json",
//       "User-ID": prefs.getString("userId") ?? "",
//       "Authorization": prefs.getString("accessToken") ?? "",
//     };

//     // Log the logout details as a JSON string
//     print("Logout Details==${jsonEncode(logoutParams)}");

//     // Step 2: Perform the logout request
//     try {
//       final response = await http.post(
//         Uri.parse(logoutUrl),
//         headers: headers,
//         body: jsonEncode(logoutParams),
//       );

//       if (response.statusCode == 200) {
//         final result = json.decode(response.body);
//         if (result["status"] == "1") {
//           await prefs.setBool("isLoggedIn", false);
//           String schoolDomain = prefs.getString("schoolDomain") ?? "";

//           getDataFromApi(schoolDomain);

//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(
//                 builder: (context) =>
//                     const LoginScreen()), // Navigate to the LoginScreen
//             (Route<dynamic> route) => false,
//           );
//         } else {
//           _showSnackBar("status is 0", Colors.red);
//         }
//       } else {
//         _showSnackBar("status code is not 200", Colors.red);
//       }
//     } catch (e) {
//       _showSnackBar("Error occured $e", Colors.red);
//     }
//   }

//   Future<void> getDataFromApi(String url) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//        String schoolAppDomain = prefs.getString("schoolAppDomain")??"";
//     prefs.clear();
//     // if (!domain.endsWith("/")) {
//     //   domain += "/";
//     // }
//     // String url = domain + "app";
//     // print("domain+app>>>>>>>>>>" + url);

//     prefs.setString("schoolDomain", url);
  
//       prefs.setString("schoolAppDomain", schoolAppDomain);
    
//     prefs.setString(Constants.appDomain, schoolAppDomain);

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           "Content-Type": Constants.contentType,
//           "Client-Service": Constants.clientService,
//           "Auth-Key": Constants.authKey,
//         },
//       );

//       if (response.statusCode == 200) {
//         final result = json.decode(response.body);
//         await _processResponse(result);
//       } else {
//         _showSnackBar('Invalid Domain.', Colors.red);

//         // ScaffoldMessenger.of(context)
//         //     .showSnackBar(const SnackBar(content: Text('Invalid Domain.')));
//       }
//     } catch (e) {
//       langCode = "";

//       _showSnackBar('An error occurred: $e', Colors.red);

//       // ScaffoldMessenger.of(context)
//       //     .showSnackBar(SnackBar(content: Text('An error occurred: $e')));
//     } finally {}
//   }

//   Future<void> _processResponse(Map<String, dynamic> result) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isUrlTaken', true);
//     await prefs.setString('apiUrl', result['url']);
//     await prefs.setString('imagesUrl', result['site_url']);

//     await prefs.setString(Constants.app_ver, result["app_ver"]);
//     String appLogo = result["site_url"] +
//         "uploads/school_content/logo/app_logo/" +
//         result["app_logo"];
//     await prefs.setString(Constants.appLogo, appLogo);

//     String secColour = result["app_secondary_color_code"];
//     String primaryColour = result["app_primary_color_code"];
//     if (secColour.length == 7 && primaryColour.length == 7) {
//       await prefs.setString(Constants.secondaryColour, secColour);
//       await prefs.setString(Constants.primaryColour, primaryColour);
//     } else {
//       await prefs.setString(
//           Constants.secondaryColour, Constants.defaultSecondaryColour);
//       await prefs.setString(
//           Constants.primaryColour, Constants.defaultPrimaryColour);
//     }

//     langCode = result["lang_code"];
//     await prefs.setString(Constants.langCode, langCode);

//     if (!langCode.isEmpty) {
//       //  setLocale(langCode);
//     }

//     final isMaintenanceMode = result['maintenance_mode'] == "1";
//     await prefs.setBool('maintenance_mode', isMaintenanceMode);

//     if (isMaintenanceMode) {
//       showMaintenanceMessage();
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//       );
//     }
//   }

//   // void _showSnackBar(String message, Color color) {
//   //   SnackbarUtil.showSnackBar(
//   //     context,
//   //     message,
//   //     duration: 3,
//   //     backgroundColor: color,
//   //   );
//   // }

//   void showMaintenanceMessage() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Maintenance"),
//           content: const Text("The app is currently under maintenance."),
//           actions: <Widget>[
//             TextButton(
//               child: const Text("OK"),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userDataAsyncValue = ref.watch(decoratorProvider);
//     final studentProfile = ref.watch(studentProfileProvider);

//     final List<DataSet> dataSets = [
//       DataSet(name: "Fees", thumbnail: "assets/ic_nav_fees.png"),
//       DataSet(name: "Attendance", thumbnail: "assets/ic_nav_attendance.png"),
//       DataSet(name: "Exams", thumbnail: "assets/ic_onlineexam.png"),
//       DataSet(name: "Homework", thumbnail: "assets/ic_dashboard_homework.png"),

//       DataSet(name: "Classwork", thumbnail: "assets/ic_dashboard_homework.png"),

//       DataSet(
//           name: "Time Table",
//           thumbnail: "assets/ic_calender_cross.png"),
//       DataSet(name: "Behaviour Records", thumbnail: "assets/ic_dashboard_homework.png"),

//       DataSet(name: "Lesson Plans", thumbnail: "assets/ic_lessonplan.png"),
//       DataSet(name: "Syllabus Status", thumbnail: "assets/ic_lessonplan.png"),
//       DataSet(
//           name: "Transport routes", thumbnail: "assets/ic_nav_transport.png"),
//       DataSet(name: "Hostel Rooms", thumbnail: "assets/ic_nav_hostel.png"),
//       DataSet(name: "Live Classes", thumbnail: "assets/ic_videocam.png"),
//       DataSet(name: "Apply Leave", thumbnail: "assets/ic_leave.png"),
//       DataSet(
//           name: "Download Center", thumbnail: "assets/ic_downloadcenter.png"),
//       DataSet(
//           name: "Documents", thumbnail: "assets/ic_documents_certificate.png"),
//       DataSet(name: "Library", thumbnail: "assets/ic_library.png"),
//       DataSet(name: "Online Exam", thumbnail: "assets/ic_onlineexam.png"),

//       DataSet(name: "Online class", thumbnail: "assets/ic_onlinecourse.png"),

//       DataSet(name: "Teacher Ratings", thumbnail: "assets/ic_teacher.png"),

//       // Add more datasets here
//     ];

//     // final fatherImage = "$domainUrl/${studentProfile?.fatherPic}";

//     // print("*******fatherImage>>>>>>>>>>>>>" + fatherImage.toString());
//     print("*******userImage>>>>>>>>>>>>>" + userImage.toString());

//     return Scaffold(
//         backgroundColor: Colors.white,
//         key: _scaffoldKey,
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.menu, color: Colors.white),
//             onPressed: () => _scaffoldKey.currentState?.openDrawer(),
//           ),
//           title: Consumer(
//             builder: (context, ref, child) {
//               final appLogoUrlAsyncValue = ref.watch(appLogoUrlProvider);

//               return appLogoUrlAsyncValue.when(
//                 data: (url) => Image.network(
//                   url,
//                   width: 100, // Set your desired width
//                   height: 100, // And height
//                   fit: BoxFit.contain,
//                 ),
//                 loading: () => const PencilLoaderProgressBar(),
//                 error: (error, stack) => Text('Failed to load logo: $error'),
//               );
//             },
//           ),
//           centerTitle: true,
//           // backgroundColor: Colors
//           //     .black, // This can be left to maintain the AppBar's overall background if not fully covered by the gradient
//           elevation: 0, // Remove shadow
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//                 border:
//                     Border(bottom: BorderSide(width: 1, color: Colors.white)),
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.deepPurple,
//                     Colors.blue,
//                     Colors.black
//                   ], // Example gradient colors
//                 ),
//                 color: Colors.blue),
//           ),
//           actions: [
//             Stack(
//               children: [
//                 IconButton(
//                   onPressed: () {
//                     ref.read(notificationCountProvider.notifier).reset();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => StudentNotificationScreen()),
//                     );
//                   },
//                   icon:
//                       const Icon(Icons.notifications, color: Color(0xFFFFD700)),
//                 ),
//                 Consumer(
//                   builder: (context, ref, child) {
//                     final notificationCount =
//                         ref.watch(notificationCountProvider);
//                     return Positioned(
//                       right: 11,
//                       top: 11,
//                       child: notificationCount > 0
//                           ? Container(
//                               padding: const EdgeInsets.all(2),
//                               decoration: BoxDecoration(
//                                 color: Colors.red,
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               constraints: const BoxConstraints(
//                                 minWidth: 14,
//                                 minHeight: 14,
//                               ),
//                               child: Text(
//                                 '$notificationCount',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 8,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             )
//                           : const SizedBox.shrink(),
//                     );
//                   },
//                 ),
//               ],
//             )
//           ],
//           bottom: PreferredSize(
//             preferredSize:
//                 const Size.fromHeight(4.0), // Set the height of the line
//             child: Container(
//               height: 1.0, // Height of the line
//               color: Colors.grey, // Color of the line
//             ),
//           ),
//         ),
//         drawer: Drawer(
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: <Widget>[
//               userDataAsyncValue.when(
//                 data: (Map<String, String> userData) {
//                   if (userData['studentName'] != "") {
//                     userName = userData['userName']!;
//                   } else {
//                     userName = userData['userName']!;
//                   }

//                   return DrawerHeader(
//                     decoration: const BoxDecoration(
//                       border: Border(
//                           bottom: BorderSide(
//                               width: 2,
//                               style: BorderStyle.solid,
//                               color: Colors
//                                   .white)), // Set the border color as needed
//                       gradient: LinearGradient(
//                         // Define the gradient colors
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           Colors.blue,
//                           Colors.black
//                         ], // Example gradient colors
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         ClipOval(
//                           child: CachedNetworkImage(
//                             imageUrl: userImage,
//                             height: 100,
//                             width: 100,
//                             placeholder: (context, url) => ClipOval(
//                               child: Image.asset(
//                                 'assets/placeholder_user.png',
//                                 height: 80,
//                                 width: 80,
//                               ),
//                             ),
//                             errorWidget: (context, url, error) => ClipOval(
//                               child: Image.asset(
//                                 'assets/placeholder_user.png',
//                                 height: 80,
//                                 width: 80,
//                               ),
//                             ),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         const SizedBox(
//                             width: 10), // Space between the avatar and text
//                         Expanded(
//                           child: SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   userName, // Replace with your dynamic value
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 23,
//                                     color: Colors
//                                         .white, // Adjust the text color to match your theme
//                                   ),
//                                 ),
//                                 userData['loginType'] == 'parent'
//                                     ? Text(
//                                         "Child-${userData['studentName']}",
//                                         overflow: TextOverflow
//                                             .clip, // Handle text overflow
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors
//                                               .white, // Adjust the text color to match your theme
//                                         ),
//                                       )
//                                     : const SizedBox(),
//                                 Text(
//                                   "${userData['classSection']}",
//                                   style: const TextStyle(
//                                     color: Colors
//                                         .white, // Adjust the text color to match your theme
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//                 loading: () => const PencilLoaderProgressBar(),
//                 error: (error, stack) => Text('Error: $error'),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.home),
//                 title: Text(AppLocalizations.of(context)!.home),
//                 onTap: () {
//                   Navigator.pushNamed(context, '/parentDashboard');
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.person),
//                 title: Text(AppLocalizations.of(context)!.profile),
//                 onTap: () {
//                   Navigator.pushNamed(context, '/profile');
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.info),
//                 title: Text(AppLocalizations.of(context)!.about_school),
//                 onTap: () {
//                   Navigator.pushNamed(context, '/about');
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.settings),
//                 title: Text(AppLocalizations.of(context)!.settings),
//                 onTap: () {
//                   Navigator.pushNamed(context, '/settings');
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.logout),
//                 title: Text(AppLocalizations.of(context)!.logout),
//                 onTap: () async {
//                   // Perform logout logic, then:

//                   bool isConnected = await isConnectingToInternet();
//                   if (isConnected) {
//                     // Perform your API logout call
//                     Map<String, dynamic> logoutParams = {
//                       "deviceToken": device_token,
//                     };

//                     // Call the Logout function with the required deviceToken
//                     await loginOutApi(context, logoutParams);
//                   } else {
//                     _showSnackBar("No internet connection", Colors.red);
//                   }
//                 },
//               ),
//               // ListTile(
//               //   leading: const Icon(Icons.vpn_key),
//               //   title: Text("Change Password"),
//               //   onTap: () {
//               //     Navigator.push(
//               //         context,
//               //         MaterialPageRoute(
//               //             builder: (context) => ForgotPasswordScreen()));
//               //   },
//               // ),
//             ],
//           ),
//         ),
//         body: ListView(children: [
//           Padding(
//               padding:
//                   const EdgeInsets.only(top: 4.0, right: 5, left: 5, bottom: 8),
//               child: Container(
//                 decoration: BoxDecoration(
//                     border: Border.all(width: 2, color: Colors.black),
//                     borderRadius: BorderRadius.circular(
//                         20), // Rounded corners with a radius of 20
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(
//                             0.5), // Shadow color with some transparency
//                         spreadRadius: 5,
//                         blurRadius: 7,
//                         offset: const Offset(0, 3), // Position of shadow
//                       ),
//                     ],
//                     color: Colors.grey[100]
//                     // gradient: LinearGradient(
//                     //   begin: Alignment.topLeft,
//                     //   end: Alignment.bottomRight,
//                     //   colors: [
//                     //     Colors.blue,
//                     //     Colors.black
//                     //   ], // Gradient colors from blue to black
//                     // ),
//                     ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(right: 10.0),
//                         child: Container(
//                           width: 170,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 8.0),
//                                 child: ClipOval(
//                                   child: CachedNetworkImage(
//                                     imageUrl: userImage,
//                                     height: 100,
//                                     width: 100,
//                                     placeholder: (context, url) => ClipOval(
//                                       child: Image.asset(
//                                         'assets/placeholder_user.png',
//                                         height: 80,
//                                         width: 80,
//                                       ),
//                                     ),
//                                     errorWidget: (context, url, error) =>
//                                         ClipOval(
//                                       child: Image.asset(
//                                         'assets/placeholder_user.png',
//                                         height: 80,
//                                         width: 80,
//                                       ),
//                                     ),
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text(
//                                   userName, // Replace with your dynamic value
//                                   textAlign: TextAlign.center,
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 23,
//                                       color: Colors.black),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       studentData.length > 1
//                           ? const Icon(
//                               Icons.swap_vert,
//                               size: 30,
//                             )
//                           : const SizedBox(),
//                       Expanded(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: studentData,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               )),
//           const SizedBox(
//             height: 10,
//           ),
//           CarouselSlider(
//             options: CarouselOptions(
//               autoPlay: true,
//               enlargeCenterPage:
//                   false, // Set this to false to use the full width
//               viewportFraction:
//                   1.0, // Ensure each item takes the full width of the screen
//               height: 80, // Set a fixed height for each item
//               autoPlayInterval: const Duration(seconds: 3),
//               autoPlayAnimationDuration: const Duration(milliseconds: 800),
//               autoPlayCurve: Curves.fastOutSlowIn,
//             ),
//             items: noticeList.isEmpty
//                 ? [
//                     Center(
//                         child: Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 20),
//                       width: MediaQuery.of(context)
//                           .size
//                           .width, // This makes the container take the full screen width
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             Colors.blue.shade900,
//                             Colors.blue.shade600
//                           ], // Gradient colors
//                         ),
//                         border: Border.all(
//                             color: Colors.white,
//                             width: 2), // Adds white border around the card

//                         // boxShadow: [
//                         //   BoxShadow(
//                         //     color: Colors
//                         //         .black45, // Darker shadow for more elevation effect
//                         //     blurRadius: 20.0,
//                         //     spreadRadius: 0.0,
//                         //     offset: Offset(0,
//                         //         6), // Larger offset for a floating effect
//                         //   )
//                         // ],
//                         borderRadius:
//                             BorderRadius.circular(3), // Rounded corners
//                       ),

//                       child: const Center(
//                         child: Text(
//                           "Notice Board is empty",
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 17,
//                               color: Colors.white),
//                         ),
//                       ),
//                     ))
//                   ]
//                 : noticeList
//                     .map(
//                       (item) => InkWell(
//                         onTap: () {
//                           // Add your onTap functionality here
//                           Navigator.pushNamed(context, '/noticeBoard');
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(horizontal: 20),
//                           width: MediaQuery.of(context)
//                               .size
//                               .width, // This makes the container take the full screen width
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                               colors: [
//                                 Colors.blue.shade900,
//                                 Colors.blue.shade600
//                               ], // Gradient colors
//                             ),
//                             border: Border.all(
//                                 color: Colors.white,
//                                 width: 2), // Adds white border around the card

//                             // boxShadow: [
//                             //   BoxShadow(
//                             //     color: Colors
//                             //         .black45, // Darker shadow for more elevation effect
//                             //     blurRadius: 20.0,
//                             //     spreadRadius: 0.0,
//                             //     offset: Offset(0,
//                             //         6), // Larger offset for a floating effect
//                             //   )
//                             // ],
//                             borderRadius:
//                                 BorderRadius.circular(3), // Rounded corners
//                           ),
//                           child: noticeList.isEmpty
//                               ? const Center(
//                                   child: Text('No data available',
//                                       style: TextStyle(color: Colors.white)))
//                               : Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       item.title,
//                                       style: const TextStyle(
//                                         fontSize: 18.0,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors
//                                             .white, // White text for better visibility
//                                       ),
//                                     ),
//                                     const SizedBox(height: 10.0),
//                                     Text(
//                                       DateUtilities.formatStringDate(item.date),
//                                       style: const TextStyle(
//                                         fontSize: 14.0,
//                                         color: Colors
//                                             .white70, // Slightly lighter text for contrast
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                         ),
//                       ),
//                     )
//                     .toList(),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           ParentsOtherSectionCards(listOfDataSets: dataSets),
//         ]));
//   }

//   Future<void> handleChildCardTap(
//       id, name, classSection, stdImage, admNo, classId, sectionId) async {
//     if (await isConnectingToInternet()) {
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.setString(Constants.admission_no, admNo);
//       await prefs.setBool(Constants.isLoggegIn, true);

//       await prefs.setString(Constants.classSection, classSection);

//       await prefs.setString(Constants.studentId, id);

//       await prefs.setString(Constants.classId, classId);
//       await prefs.setString(Constants.sectionId, sectionId);

//       await prefs.setString("studentName", name);
//       // await prefs.setString('selectedChild', jsonEncode(children[0]));

//       SnackbarUtil.showSnackBar(
//         context,
//         "Showing results for ${name}",
//         duration: 3,
//         backgroundColor: Colors.green,
//       );

//       ref.invalidate(decoratorProvider); //trigger the provider

//       print("******student I now is>>>>>>>>>>>>>>" +
//           prefs.getString(Constants.studentId).toString());
//       setState(() {
//         studentData.clear();
//         prepareDataOfprofile();
//       });

//       // Navigator.of(context).pushReplacement(
//       //     MaterialPageRoute(builder: (_) => const ParentsDashboard()));
//     } else {
//       print("No internet connection");
//     }
//     // Adjust as needed
//   }
// }
