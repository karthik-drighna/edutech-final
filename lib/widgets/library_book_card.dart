import 'package:drighna_ed_tech/models/library_book_model.dart';
import 'package:drighna_ed_tech/utils/date_format_converter.dart';
import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.book, color: Colors.blueAccent, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Author', book.author),
            _buildInfoRow('Subject', book.subject),
            _buildInfoRow('Publisher', book.publisher),
            _buildInfoRow('Rack No', book.rackNo),
            _buildInfoRow('Qty', book.quantity.toString()),
            _buildInfoRow('Cost', '₹${book.cost}'),
            _buildInfoRow(
                'Post Date',
                DateUtilities.formatStringDate(
                    book.postDate.toString())), // Ensure this is a String
            if (book.description.isNotEmpty)
              _buildInfoRow('Description', book.description),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
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
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
