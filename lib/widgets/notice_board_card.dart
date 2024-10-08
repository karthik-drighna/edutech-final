import 'package:drighna_ed_tech/utils/date_format_converter.dart';
import 'package:flutter/material.dart';
import 'package:drighna_ed_tech/models/notice_board_model.dart';
import 'package:flutter_html/flutter_html.dart';

class NoticeBoardCard extends StatelessWidget {
  final NoticeBoardModel notice;

  const NoticeBoardCard({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notice.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Html(data: notice.message),
            const SizedBox(height: 20),
            _buildInfoRow(
              icon: Icons.event,
              label: 'Published Date',
              value: DateUtilities.formatStringDate(notice.publishDate),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.schedule,
              label: 'Notice Date',
              value: DateUtilities.formatStringDate(notice.date),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Created By',
              value: notice.createdBy,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
