import 'dart:convert';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/utils/date_format_converter.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart' show parse;
import 'package:flutter/foundation.dart';

class StudentOnlineExamResult extends StatefulWidget {
  final String examId;
  final String onlineExamStudentId;
  const StudentOnlineExamResult(
      {super.key, required this.examId, required this.onlineExamStudentId});

  @override
  State<StudentOnlineExamResult> createState() =>
      _StudentOnlineExamResultState();
}

class _StudentOnlineExamResultState extends State<StudentOnlineExamResult> {
  ExamResult? examResult;

  @override
  void initState() {
    super.initState();
    fetchExamResult(widget.examId, widget.onlineExamStudentId).then((result) {
      setState(() {
        examResult = result;
      });
    }).catchError((error) {
      print('An error occurred: $error');
    });
  }

  Future<ExamResult> fetchExamResult(
      String examId, String onlineExamStudentId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString("apiUrl") ?? "";
    String url = apiUrl + Constants.getOnlineExamResultUrl;

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': Constants.contentType,
        'Client-Service': Constants.clientService,
        'Auth-Key': Constants.authKey,
        'User-ID': prefs.getString(Constants.userId) ?? "",
        'Authorization': prefs.getString("accessToken") ?? "",
      },
      body: jsonEncode({
        'onlineexam_student_id': onlineExamStudentId,
        'exam_id': examId,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> parsedJson = jsonDecode(response.body);
      return ExamResult.fromJson(parsedJson);
    } else {
      throw Exception(
          'Failed to load exam result, status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (examResult == null) {
      return Scaffold(
        appBar: CustomAppBar(titleText: "Exam Result"),
        body: const Center(child: PencilLoaderProgressBar()),
      );
    } else {
      return Scaffold(
        appBar: CustomAppBar(titleText: "Exam Result"),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: ExamSummaryWidget(examDetails: examResult!.examDetails),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  QuestionResult questionResult =
                      examResult!.questionResults[index];
                  return QuestionWidget(
                      questionResult: questionResult,
                      questionNumber: index + 1);
                },
                childCount: examResult!.questionResults.length,
              ),
            ),
          ],
        ),
      );
    }
  }
}

class ExamDetails {
  final String exam;
  final String totalAttempt;
  final String examFrom;
  final String examTo;
  final String duration;
  final String passing;
  final String totalQuestions;
  final String description;
  final String descriptiveQuestions;
  final String correct;
  final String wrong;
  final String notAttempted;
  final String totalExamMarks;
  final String totalScoredMarks;
  final String score;
  final String examRank;

  ExamDetails({
    required this.exam,
    required this.totalAttempt,
    required this.examFrom,
    required this.examTo,
    required this.duration,
    required this.passing,
    required this.totalQuestions,
    required this.description,
    required this.descriptiveQuestions,
    required this.correct,
    required this.wrong,
    required this.notAttempted,
    required this.totalExamMarks,
    required this.totalScoredMarks,
    required this.score,
    required this.examRank,
  });

  factory ExamDetails.fromJson(Map<String, dynamic> json) {
    return ExamDetails(
      exam: json['exam'] ?? 'N/A',
      totalAttempt: json['attempt']?.toString() ?? 'N/A',
      examFrom: json['exam_from'] ?? 'N/A',
      examTo: json['exam_to'] ?? 'N/A',
      duration: json['duration'] ?? 'N/A',
      passing: json['passing_percentage']?.toString() ?? 'N/A',
      totalQuestions: json['total_question']?.toString() ?? 'N/A',
      description: json['description'] ?? 'N/A',
      descriptiveQuestions: json['total_descriptive']?.toString() ?? 'N/A',
      correct: json['correct_ans']?.toString() ?? 'N/A',
      wrong: json['wrong_ans']?.toString() ?? 'N/A',
      notAttempted: json['not_attempted']?.toString() ?? 'N/A',
      totalExamMarks: json['exam_total_marks']?.toString() ?? 'N/A',
      totalScoredMarks: json['exam_total_scored']?.toString() ?? 'N/A',
      score: json['score']?.toString() ?? 'N/A',
      examRank: json['rank']?.toString() ?? 'N/A',
    );
  }
}

class QuestionResult {
  final String question;
  final String subjectName;
  final String subjectCode;
  final String marks;
  final String negMarks;
  final String scoreMarks;
  final String correct;
  final String selectedOption;
  final String aptA;
  final String aptB;
  final String aptC;
  final String aptD;
  final String aptE;

  QuestionResult({
    required this.question,
    required this.subjectName,
    required this.subjectCode,
    required this.marks,
    required this.negMarks,
    required this.scoreMarks,
    required this.correct,
    required this.selectedOption,
    required this.aptA,
    required this.aptB,
    required this.aptC,
    required this.aptD,
    required this.aptE,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
        question: json['question'] ?? 'N/A',
        subjectName: json['subject_name'] ?? 'N/A',
        subjectCode: json['subjects_code'] ?? 'N/A',
        marks: json['marks']?.toString() ?? 'N/A',
        negMarks: json['neg_marks']?.toString() ?? 'N/A',
        scoreMarks: json['score_marks']?.toString() ?? 'N/A',
        correct: json['correct']?.toString() ?? 'N/A',
        selectedOption: json['select_option']?.toString() ?? 'N/A',
        aptA: json['opt_a']?.toString() ?? 'N/A',
        aptB: json['opt_b']?.toString() ?? 'N/A',
        aptC: json['opt_c']?.toString() ?? 'N/A',
        aptD: json['opt_d']?.toString() ?? 'N/A',
        aptE: json['opt_e']?.toString() ?? 'N/A');
  }
}

class ExamResult {
  final ExamDetails examDetails;
  final List<QuestionResult> questionResults;

  ExamResult({
    required this.examDetails,
    required this.questionResults,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    if (json['result'] == null || json['result']['question_result'] == null) {
      throw Exception('Invalid JSON data');
    }
    var examDetailsJson = json['result']['exam'];
    var questionResultsJson = json['result']['question_result'] as List? ?? [];
    List<QuestionResult> questionResults = questionResultsJson
        .map((questionJson) => QuestionResult.fromJson(questionJson))
        .toList();
    ExamDetails examDetails = ExamDetails.fromJson(examDetailsJson);

    return ExamResult(
      examDetails: examDetails,
      questionResults: questionResults,
    );
  }
}

class ExamSummaryWidget extends StatelessWidget {
  final ExamDetails examDetails;

  const ExamSummaryWidget({Key? key, required this.examDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Online Exam Result',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Exam', examDetails.exam),
            _buildInfoRow('Total Attempt', examDetails.totalAttempt),
            _buildInfoRow('Exam From',
                DateUtilities.formatStringDate(examDetails.examFrom)),
            _buildInfoRow(
                'Exam To', DateUtilities.formatStringDate(examDetails.examTo)),
            _buildInfoRow('Duration', examDetails.duration),
            _buildInfoRow('Passing (%)', examDetails.passing),
            _buildInfoRow('Total Questions', examDetails.totalQuestions),
            _buildInfoRow('Description', examDetails.description),
            _buildInfoRow(
                'Descriptive Questions', examDetails.descriptiveQuestions),
            _buildInfoRow('Correct', examDetails.correct),
            _buildInfoRow('Wrong', examDetails.wrong),
            _buildInfoRow('Not Attempted', examDetails.notAttempted),
            _buildInfoRow('Total Exam Marks', examDetails.totalExamMarks),
            _buildInfoRow('Total Scored Marks', examDetails.totalScoredMarks),
            _buildInfoRow('Score (%)', examDetails.score),
            // Uncomment if exam rank is needed
            // _buildInfoRow('Exam Rank', examDetails.examRank),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class QuestionWidget extends StatelessWidget {
  final QuestionResult questionResult;
  final int questionNumber;

  const QuestionWidget({
    Key? key,
    required this.questionResult,
    required this.questionNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var document = parse(questionResult.question);
    String parsedString =
        document.body!.text; // Extracting the text content from the HTML

    IconData iconCorrect = Icons.check_circle_outline;
    IconData iconIncorrect = Icons.highlight_off;
    Color colorCorrect = Colors.green;
    Color colorIncorrect = Colors.red;

    bool isCorrect;
    if (questionResult.correct.isNotEmpty &&
        questionResult.correct.length > 5) {
      if (questionResult.selectedOption.startsWith('[') &&
          questionResult.selectedOption.endsWith(']')) {
        List<String> selectedOptionsList = questionResult.selectedOption
            .substring(1, questionResult.selectedOption.length - 1)
            .split(', ')
            .map((s) => s.trim())
            .toList();
        List<String> correctAnswerList = questionResult.correct
            .substring(1, questionResult.correct.length - 1)
            .split(', ')
            .map((s) => s.trim())
            .toList();

        selectedOptionsList.sort();
        correctAnswerList.sort();

        isCorrect = listEquals(selectedOptionsList, correctAnswerList);
      } else {
        isCorrect = false;
      }
    } else {
      isCorrect = questionResult.selectedOption == questionResult.correct;
    }

    bool isSelected = questionResult.selectedOption.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(17.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Q.$questionNumber",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            parsedString,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Subject: ${questionResult.subjectName} (${questionResult.subjectCode})',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          questionResult.aptA != ""
              ? const Text(
                  "option A",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : const SizedBox(),
          questionResult.aptA != ""
              ? Html(data: questionResult.aptA)
              : const SizedBox(),
          questionResult.aptB != ""
              ? const Text(
                  "option B",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : const SizedBox(),
          questionResult.aptB != ""
              ? Html(data: questionResult.aptB)
              : const SizedBox(),
          questionResult.aptC != ""
              ? const Text(
                  "option C",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : const SizedBox(),
          questionResult.aptC != ""
              ? Html(data: questionResult.aptC)
              : const SizedBox(),
          questionResult.aptD != ""
              ? const Text(
                  "option D",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : const SizedBox(),
          questionResult.aptD != ""
              ? Html(data: questionResult.aptD)
              : const SizedBox(),
          questionResult.aptE != ""
              ? const Text(
                  "option E",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : const SizedBox(),
          questionResult.aptE != ""
              ? Html(data: questionResult.aptE)
              : const SizedBox(),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Correct Answer: ${questionResult.correct}",
            style: const TextStyle(fontSize: 14, color: Colors.green),
          ),
          const SizedBox(height: 8),
          Text(
            "Selected Answer: ${questionResult.selectedOption}",
            style: TextStyle(
              fontSize: 14,
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          isSelected
              ? Row(
                  children: [
                    Icon(
                      isCorrect ? iconCorrect : iconIncorrect,
                      color: isCorrect ? colorCorrect : colorIncorrect,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCorrect ? "Correct" : "Incorrect",
                      style: TextStyle(
                          color: isCorrect ? colorCorrect : colorIncorrect),
                    ),
                  ],
                )
              : const Text("Not selected/not Attempted"),
          const SizedBox(height: 8),
          Column(
            children: [
              Row(
                children: [
                  Text(
                      "Marks: ${isCorrect ? "1" : "0"}/${questionResult.marks}"),
                  if (questionResult.negMarks.isNotEmpty)
                    Text("  Negative: ${questionResult.negMarks}"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
