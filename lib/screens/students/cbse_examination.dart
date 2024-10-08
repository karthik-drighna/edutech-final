import 'package:drighna_ed_tech/screens/students/student_cbseExamination_results.dart';
import 'package:drighna_ed_tech/screens/students/student_cbseExamination_time_table.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';


class CbseExamination extends StatelessWidget {
  const CbseExamination({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "CBSE Examination",
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CBSE Examination", // Exam title
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple, // Custom color for the text
                  ),
                ),
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
                  title: 'Exam Timetable',
                  color: Colors.blue,
                  icon: Icons.schedule,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CbseExaminationTimeTableScreen(),
                    ),
                  ),
                ),
                _buildButton(
                  context,
                  title: 'CBSE Exam Result',
                  color: Colors.green,
                  icon: Icons.bar_chart,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CbseExaminationResultsScreen(),
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
