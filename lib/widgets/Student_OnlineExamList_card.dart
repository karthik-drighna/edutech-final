import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

enum ExamState { showStartExam, showViewResult, showSubmitted, showNeither }

ExamState determineExamState(
    bool isQuiz,
    bool isAttempted,
    bool isActive,
    bool isParent,
    String status,
    bool withinTimeFrame,
    bool maxAttemptsReached,
    bool publishResult) {
  if (status == "closed") {
    return ExamState.showViewResult;
  }
  if (isParent) {
    if (publishResult || (isQuiz && isAttempted)) {
      return ExamState.showViewResult;
    } else {
      return ExamState.showNeither;
    }
  } else if (!isAttempted && withinTimeFrame) {
    return ExamState.showStartExam;
  } else if (publishResult || (isAttempted && isQuiz)) {
    return ExamState.showViewResult;
  } else if (isAttempted) {
    return ExamState.showSubmitted;
  } else {
    return ExamState.showNeither;
  }
}

class ExamListCard extends StatefulWidget {
  final Map<String, dynamic> examData;
  final String status;
  final VoidCallback? onStartPressed;
  final VoidCallback? onViewResultPressed;
  final bool isParent;

  const ExamListCard({
    Key? key,
    required this.examData,
    required this.status,
    this.onStartPressed,
    this.onViewResultPressed,
    required this.isParent,
  }) : super(key: key);

  @override
  State<ExamListCard> createState() => _ExamListCardState();
}

class _ExamListCardState extends State<ExamListCard> {
  @override
  void initState() {
    super.initState();
  }

  String getAnswerWordLimit(dynamic value) {
    return value == "-1" ? "No Limit" : value.toString();
  }

  String formatDateTime(String dateTimeStr) {
    DateFormat originalFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateFormat newFormat = DateFormat('dd/MM/yyyy hh:mm a');
    DateTime dateTime = originalFormat.parse(dateTimeStr);
    return newFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    bool isQuiz = widget.examData['is_quiz'] == "1";
    bool isAttempted = widget.examData['is_attempted'] == "1";
    bool isActive = widget.examData['is_active'] == "1";
    bool withinTimeFrame = checkIfWithinTimeFrame(
        widget.examData['exam_from'], widget.examData['exam_to']);
    bool maxAttemptsReached = widget.examData['attempt'].toString() ==
        widget.examData['counter'].toString();
    bool publishResult = widget.examData['publish_result'] == "1";
    String answerWordLimit =
        getAnswerWordLimit(widget.examData['answer_word_count'].toString());

    final ExamState state = determineExamState(
        isQuiz,
        isAttempted,
        isActive,
        widget.isParent,
        widget.status,
        withinTimeFrame,
        maxAttemptsReached,
        publishResult);

    Widget getSpecificButton() {
      switch (state) {
        case ExamState.showStartExam:
          return ElevatedButton(
            onPressed: widget.onStartPressed,
            child: const Text(
              'Start Exam',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        case ExamState.showViewResult:
          return ElevatedButton(
            onPressed: widget.onViewResultPressed,
            child: const Text(
              'View',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        case ExamState.showSubmitted:
          return const Text(
            "Exam got submitted",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          );
        case ExamState.showNeither:
          return const SizedBox.shrink();
        default:
          return const SizedBox.shrink();
      }
    }

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.examData['exam'] ?? 'No Exam Name',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                getSpecificButton(),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            _buildInfoRow(
                'Exam From', formatDateTime(widget.examData['exam_from'])),
            _buildInfoRow(
                'Exam To', formatDateTime(widget.examData['exam_to'])),
            _buildInfoRow('Total Attempt', widget.examData['attempt']),
            _buildInfoRow('Attempted', widget.examData['counter']),
            _buildInfoRow('Duration', widget.examData['duration']),
            _buildInfoRow(
                'Status',
                widget.examData['publish_result'] == "1"
                    ? 'Result Published'
                    : 'Available'),
            _buildInfoRow('Quiz', isQuiz ? 'Yes' : 'No'),
            _buildInfoRow(
                'Passing (%)', '${widget.examData['passing_percentage']}'),
            _buildInfoRow('Descriptive Questions',
                '${widget.examData['total_descriptive']}'),
            _buildInfoRow(
                'Total Questions', '${widget.examData['total_question']}'),
            _buildInfoRow('Answer Word Limit', answerWordLimit),
            const SizedBox(height: 10),
            const Text(
              'Description',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            Html(
              data: widget.examData['description'] ?? 'No description provided',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, dynamic value) {
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
            value.toString(),
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  bool checkIfWithinTimeFrame(String? startTime, String? endTime) {
    if (startTime == null || endTime == null) {
      return false;
    }

    DateFormat sdf = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime startDateTime = sdf.parse(startTime);
    DateTime endDateTime = sdf.parse(endTime);
    DateTime now = DateTime.now();

    return now.isAfter(startDateTime) && now.isBefore(endDateTime);
  }
}
