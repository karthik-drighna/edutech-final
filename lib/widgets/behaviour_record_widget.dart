
import 'package:drighna_ed_tech/utils/date_format_converter.dart';
import 'package:flutter/material.dart';
import 'package:drighna_ed_tech/models/behaviour_record_model.dart';

class BehaviorRecordWidget extends StatelessWidget {
  final BehaviorRecord behaviorRecord;

  const BehaviorRecordWidget({Key? key, required this.behaviorRecord})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  behaviorRecord.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                // Builder(
                //   builder: (innerContext) => IconButton(
                //     onPressed: () {
                //       Navigator.push(
                //         innerContext,
                //         MaterialPageRoute(
                //           builder: (context) => BehaviourComment(id: behaviorRecord.id),
                //         ),
                //       );
                //     },
                //     icon: const Icon(Icons.message_rounded),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${DateUtilities.formatDateTimeString(behaviorRecord.createdAt) }',
            ),
            const SizedBox(height: 4),
            Text(
              'Point: ${behaviorRecord.point}',
            ),
            const SizedBox(height: 4),
            Text(
              'Description: ${behaviorRecord.description}',
            ),
            const SizedBox(height: 4),
            Text(
              'Assigned By: ${behaviorRecord.staffName}',
            ),
          ],
        ),
      ),
    );
  }
}
