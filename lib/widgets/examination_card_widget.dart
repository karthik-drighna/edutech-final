import 'package:flutter/material.dart';
import 'package:drighna_ed_tech/models/exam_model.dart';
import 'package:drighna_ed_tech/screens/students/StudentReportCard_ExamListResult.dart';
import 'package:drighna_ed_tech/screens/students/student_exam_schedule.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExaminationCard extends StatelessWidget {
  final Examination exam;

  const ExaminationCard({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners for the card
      ),
      elevation: 5,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.exam ?? '', // Exam title
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple, // Custom color for the text
                  ),
                ),
                Text(exam.description)
              ],
            ),
            const SizedBox(height: 8),

            // Text(
            //   'Date: ${exam.date}', // Display exam date, ensure you have a date field in your model
            //   style: TextStyle(
            //     color: Colors.grey[600],
            //     fontSize: 16,
            //   ),
            // ),
            // SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  context,
                  title: AppLocalizations.of(context)!.exam_schedule,
                  color: Colors.blue,
                  icon: Icons.schedule,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentExamSchedule(
                        examGroupId: exam.examGroupClassBatchExamId,
                      ),
                    ),
                  ),
                ),
                _buildButton(
                  context,
                  title: AppLocalizations.of(context)!.exam_result,
                  color: Colors.green,
                  icon: Icons.bar_chart,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentReportCardScreen(
                        examGroupId: exam.examGroupClassBatchExamId,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String title,
      required Color color,
      required IconData icon,
      required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20), // Icon for the button
      label: Text(title),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white, // Text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
