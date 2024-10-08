import 'dart:convert';

import 'package:drighna_ed_tech/models/notice_board_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/notice_board_card.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentNoticeBoard extends StatefulWidget {
  const StudentNoticeBoard({super.key});

  @override
  _StudentNoticeBoardState createState() => _StudentNoticeBoardState();
}

class _StudentNoticeBoardState extends State<StudentNoticeBoard> {
  List<NoticeBoardModel> noticeList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getDataFromApi();
  }

  Future<void> getDataFromApi() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.notice_board,
      ),
      body: isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : noticeList.isEmpty
              ? const Center(child: Text('No data available'))
              : ListView.builder(
                  itemCount: noticeList.length,
                  itemBuilder: (context, index) {
                    return NoticeBoardCard(notice: noticeList[index]);
                  },
                ),
    );
  }
}
