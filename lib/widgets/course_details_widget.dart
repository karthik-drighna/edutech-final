import 'package:drighna_ed_tech/models/course_details.dart';
import 'package:flutter/material.dart';

class CourseDetailsSectionWidget extends StatelessWidget {
  final Sections section;
  final int index;

  const CourseDetailsSectionWidget(
      {super.key, required this.section, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Row(
          children: [
            Text("Section " + index.toString() + ":"),
            Flexible(
                child: Text(
              section.sectionTitle,
              softWrap: true,
            )),
          ],
        ),
        children: section.lessonQuizzes.map((lessonQuiz) {
         

          // Check the type and decide what to display
          return ListTile(
            leading: Icon(lessonQuiz.type == "lesson"
                ? Icons.play_circle_fill
                : Icons.question_mark),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lessonQuiz.type,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(lessonQuiz.type == "quiz"
                    ? lessonQuiz.quizTitle
                    : lessonQuiz.lessonTitle),
              ],
            ),
            trailing: lessonQuiz.type == "lesson"
                ? Text(lessonQuiz.lessonType == "video"
                    ? "${lessonQuiz.duration}"
                    : '')
                : null,
            onTap: () {
              // Implement your onTap functionality here
            },
          );
        }).toList(),
      ),
    );
  }
}
