import 'package:drighna_ed_tech/utils/date_format_converter.dart';
import 'package:flutter/material.dart';

class ExamSubjectCard extends StatelessWidget {
  final String subjectName;
  final String subjectCode;
  final String date;
  final String roomNumber;
  final String startTime;
  final String duration;
  final String maxMarks;
  final String minMarks;
  final String creditHours;

  const ExamSubjectCard({
    Key? key,
    required this.subjectName,
    required this.subjectCode,
    required this.date,
    required this.roomNumber,
    required this.startTime,
    required this.duration,
    required this.maxMarks,
    required this.minMarks,
    required this.creditHours,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$subjectName ($subjectCode)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            InformationRow(
                label: 'Date', value: DateUtilities.formatStringDate(date)),
            InformationRow(label: 'Room No.', value: roomNumber),
            InformationRow(label: 'Start Time', value: startTime),
            InformationRow(label: 'Duration', value: duration),
            InformationRow(label: 'Max Marks', value: maxMarks),
            InformationRow(label: 'Min Marks', value: minMarks),
            InformationRow(label: 'Credit Hours', value: creditHours),
          ],
        ),
      ),
    );
  }
}

class InformationRow extends StatelessWidget {
  final String label;
  final String value;

  const InformationRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
