import 'dart:convert';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool isStudent = true; // Default to 'Student'
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  void forgotPassword() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final String apiUrl =
        prefs.getString(Constants.apiUrl) ?? ""; // Replace with actual URL
    final String siteUrl = prefs.getString(Constants.imagesUrl) ?? "";

    String url = apiUrl + Constants.forgotPasswordUrl;
    final String email = emailController.text.trim();
    final String userType = isStudent ? "student" : "parent";

    final Map<String, String> headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": "application/json",
    };

    final Map<String, dynamic> body = {
      "email": email,
      "usertype": userType.toLowerCase().trim(),
      "site_url": siteUrl, // Replace with actual site URL
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        SnackbarUtil.showSnackBar(
          context,
          result['message'],
          backgroundColor: Colors.green,
        );
      } else {
        final result = json.decode(response.body);

        SnackbarUtil.showSnackBar(
          context,
          result['message'],
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      SnackbarUtil.showSnackBar(
        context,
        'An error occurred: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img_login_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 30,
                          offset:
                              const Offset(0, 10), // changes position of shadow
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  )),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _userTypeButton(context, 'I am Student', true),
                  const SizedBox(width: 20), // Spacing between buttons
                  _userTypeButton(context, 'I am Parent', false),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: ElevatedButton(
                  onPressed: () {
                    forgotPassword();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 141, 127, 10)),
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SUBMIT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userTypeButton(BuildContext context, String text, bool forStudent) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isStudent = forStudent;
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: isStudent == forStudent
            ? const Color.fromARGB(255, 141, 127, 10)
            : Colors.grey[300],
        backgroundColor: isStudent == forStudent
            ? const Color.fromARGB(255, 141, 127, 10)
            : Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rectangular shape
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isStudent == forStudent
              ? Colors.white
              : Colors.black, // Text color based on selection
        ),
      ),
    );
  }
}
