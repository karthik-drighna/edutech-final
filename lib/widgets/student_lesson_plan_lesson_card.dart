import 'package:drighna_ed_tech/models/lesson_plan_models.dart';
import 'package:flutter/material.dart';

class LessonCard extends StatelessWidget {
  final LessonModel lesson;

  const LessonCard({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.name,
              // style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 8.0),
            Text(
              "Completed: ${lesson.totalComplete} / Total: ${lesson.total}",
            ),
            const Divider(),
            ...lesson.topics.map((topic) => ListTile(
                  title: Text(topic.name),
                  trailing: Icon(
                    topic.status == 1 ? Icons.check_circle : Icons.cancel,
                    color: topic.status == 1 ? Colors.green : Colors.red,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
