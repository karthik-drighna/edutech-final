import 'package:drighna_ed_tech/models/syllabus_subject_model.dart';
import 'package:drighna_ed_tech/screens/students/student_syllabus_lesson.dart';
import 'package:flutter/material.dart';

class SyllabusCard extends StatelessWidget {
  final SyllabusSubject? subject;

  const SyllabusCard({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    if (subject == null) {
      return const Center(child: Text("No data found"));
    } else {
      return Card(
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${subject!.subjectName.toUpperCase()} ${subject!.subjectCode}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${(subject!.totalComplete / subject!.total * 100).toStringAsFixed(0)}% Completed',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: subject!.total > 0
                    ? subject!.totalComplete / subject!.total
                    : 0,
                backgroundColor: Colors.grey[300],
                color: Colors.blue,
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentSyllabusLesson(
                                subject: subject!,
                              )));
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.topic_outlined, color: Colors.deepPurple),
                    SizedBox(width: 5),
                    Text(
                      "Lesson Topic",
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
