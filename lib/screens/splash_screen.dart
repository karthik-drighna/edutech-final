import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drighna_ed_tech/screens/admin_webview/admin_webView.dart';
import 'package:drighna_ed_tech/screens/students/dashboard.dart';
import 'package:drighna_ed_tech/screens/take_url_screen.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'students/student_fees.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialization();
  }

  Future<void> _initialization() async {
    await _checkInternetConnection();
    await _checkInitialScreen();
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: ListTile(
            // leading: CircularProgressIndicator(),
            title: Text(
              'No internet connection! Waiting for connection...',
              style: TextStyle(color: Colors.black),
            ),
          ),
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          elevation: 0,
        ),
      );
      await Future.delayed(const Duration(seconds: 5));
      await _checkInternetConnection();
    }
  }

  Future<void> _checkInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final isUrlTaken = prefs.getBool('isUrlTaken') ?? false;
    final isLoggedin = prefs.getBool(Constants.isLoggegIn) ?? false;
    final isLock = prefs.getBool(Constants.isLock) ?? false;
    final loginType = prefs.getString(Constants.loginType) ?? "";
    final apiUrl =
        prefs.getString(Constants.apiUrl) ?? Constants.domain + "/api/";

    if (isUrlTaken) {
      await _checkMaintenanceMode(apiUrl, isLoggedin, isLock, loginType);
    } else {
      _navigateToTakeUrlScreen();
    }
  }

  Future<void> _checkMaintenanceMode(
      String apiUrl, bool isLoggedin, bool isLock, String loginType) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl" + Constants.getMaintenanceModeStatusUrl),
        headers: {
          'Client-Service': Constants.clientService,
          'Auth-Key': Constants.authKey,
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final maintenanceMode = result['maintenance_mode'] == '1';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('maintenance_mode', maintenanceMode);

        if (!maintenanceMode) {
          _navigateBasedOnLoginStatus(isLoggedin, isLock, loginType);
        } else {
          _showMaintenanceMessage();
        }
      } else {
        // Handle the error or retry
        debugPrint("Received non-200 status code: ${response.statusCode}");
      }
    } catch (e) {
      // Handle the exception, you could retry or show an error message
      debugPrint("Exception caught while checking maintenance mode: $e");
    }
  }

  void _navigateBasedOnLoginStatus(
      bool isLoggedin, bool isLock, String loginType) async {
    final prefs = await SharedPreferences.getInstance();
    final isAdminLogin = prefs.getBool('AdminLogin') ?? false;

    if (isAdminLogin) {
      _navigateToAdminWebview();
    } else if (isLoggedin) {
      if (isLock) {
        _navigateToStudentFees();
      } else {
        if (loginType == 'student') {
          _navigateToNewDashboard();
        } else if (loginType == 'parent') {
          _navigateToParentDashboard();
        }
      }
    } else {
      _navigateToLoginScreen();
    }
  }

  void _navigateToTakeUrlScreen() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => TakeUrlScreen()));
  }

  void _navigateToNewDashboard() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()));
  }

  void _navigateToParentDashboard() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()));
  }

  void _navigateToLoginScreen() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _navigateToStudentFees() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => StudentFees()));
  }

  void _navigateToAdminWebview() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => AdminWebview(
            url: "https://edutech.drighna.com/gauthenticate/login")));
  }

  void _showMaintenanceMessage() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img_login_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: PencilLoaderProgressBar(),
        ),
      ),
    );
  }
}
