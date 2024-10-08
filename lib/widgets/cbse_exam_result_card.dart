
import 'package:drighna_ed_tech/models/cbse_exam_model.dart';
import 'package:flutter/material.dart';

class CBSEExamResultCard extends StatelessWidget {
  final CbseExamModel cbseExam;

  const CBSEExamResultCard({super.key, required this.cbseExam});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: ${cbseExam.name}'),
            Text('Total Marks: ${cbseExam.examTotalMarks}'),
            Text('Percentage: ${cbseExam.examPercentage}'),
            Text('Grade: ${cbseExam.examGrade}'),
            Text('Rank: ${cbseExam.examRank}'),
            Text('Obtain Marks: ${cbseExam.examObtainMarks}'),
            const Divider(),
            const Text('Subjects:'),
            ...cbseExam.subjects.map((subject) => Text(subject.subjectName)).toList(),
          ],
        ),
      ),
    );
  }
}