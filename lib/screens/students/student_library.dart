import 'dart:convert';
import 'package:drighna_ed_tech/models/library_book_model.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/library_book_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:drighna_ed_tech/utils/constants.dart';

class StudentLibraryBook extends StatefulWidget {
  @override
  _StudentLibraryBookState createState() => _StudentLibraryBookState();
}

class _StudentLibraryBookState extends State<StudentLibraryBook> {
  List books = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String url = "$apiUrl${Constants.getLibraryBookListUrl}";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Client-Service": Constants.clientService,
          "Auth-Key": Constants.authKey,
          "Content-Type": "application/json",
          "User-ID": prefs.getString('userId') ?? '',
          "Authorization": prefs.getString('accessToken') ?? '',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List<dynamic> bookArray = data['data'];

        setState(() {
          books = bookArray.map((item) => Book.fromJson(item)).toList();

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // Handle server error
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle network error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Library Books',
      ),
      body: isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : books.isEmpty
              ? const Center(child: Text('No books found'))
              : RefreshIndicator(
                  onRefresh: fetchBooks,
                  child: ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      var book = books[index];
                      return BookCard(book: book);
                    },
                  ),
                ),
    );
  }
}
