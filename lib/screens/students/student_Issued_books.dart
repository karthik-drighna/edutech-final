import 'dart:convert';
import 'package:drighna_ed_tech/models/library_book_model.dart';
import 'package:drighna_ed_tech/screens/students/student_library.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/library_book_widget.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentLibraryBookIssued extends StatefulWidget {
  const StudentLibraryBookIssued({super.key});

  @override
  _StudentLibraryBookIssuedState createState() =>
      _StudentLibraryBookIssuedState();
}

class _StudentLibraryBookIssuedState extends State<StudentLibraryBookIssued> {
  List issuedBooksData = []; // This should be a list of IssuedBook
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchIssuedBooks();
  }

  Future<void> fetchIssuedBooks() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('studentId') ?? '';
    final apiUrl = prefs.getString('apiUrl') ?? '';
    final url = "$apiUrl${Constants.getLibraryBookIssuedListUrl}";

    final headers = {
      "Client-Service": Constants.clientService,
      "Auth-Key": Constants.authKey,
      "Content-Type": "application/json",
      "User-ID": prefs.getString('userId') ?? '',
      "Authorization": prefs.getString('accessToken') ?? '',
    };

    final body = json.encode({
      "studentId": studentId,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          issuedBooksData = data;

          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.library_books_issued,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentLibraryBook()));
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 18),
              child: Row(
                children: [
                  Icon(
                    Icons.book,
                  ),
                  Text("Book")
                ],
              ),
            ),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : issuedBooksData.isEmpty
              ? const Center(child: Text('No books found'))
              : RefreshIndicator(
                  onRefresh: fetchIssuedBooks,
                  child: ListView.builder(
                    itemCount: issuedBooksData.length,
                    itemBuilder: (context, index) {
                      final bookJson = issuedBooksData[index];
                      final book = IssuedBook.fromJson(
                          bookJson); // Create IssuedBook object from JSON

                      return LibraryBookIssuedCard(
                          book: book); // Use the new custom widget
                    },
                  ),
                ),
    );
  }
}
