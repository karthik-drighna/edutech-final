import 'package:drighna_ed_tech/models/student_visitor_model.dart';
import 'package:drighna_ed_tech/utils/date_format_converter.dart';
import 'package:flutter/material.dart';

class VisitorCard extends StatelessWidget {
  final Visitor visitor;

  const VisitorCard({super.key, required this.visitor});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              visitor.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Purpose', visitor.purpose),
            _buildInfoRow('Phone', visitor.contact),
            _buildInfoRow('ID Proof', visitor.idProof),
            _buildInfoRow(
                'Number of People', visitor.numberOfPeople.toString()),
            _buildInfoRow('Date', DateUtilities.formatStringDate(visitor.date)),
            _buildInfoRow('In Time', visitor.inTime),
            _buildInfoRow('Out Time', visitor.outTime),
            _buildInfoRow('Note', visitor.note),
            _buildInfoRow('Meeting With', visitor.meetingWith),
            _buildInfoRow('Created At',
                DateUtilities.formatStringDate(visitor.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 30.0),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
