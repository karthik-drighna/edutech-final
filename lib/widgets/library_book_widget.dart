import 'package:drighna_ed_tech/models/library_book_model.dart';
import 'package:flutter/material.dart';
import 'package:drighna_ed_tech/utils/date_format_converter.dart';

class LibraryBookIssuedCard extends StatelessWidget {
  final IssuedBook book;

  const LibraryBookIssuedCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                const Icon(Icons.book, color: Colors.blueAccent, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    book.bookTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Text(
                  book.isReturned ? 'Returned' : 'Not Returned',
                  style: TextStyle(
                    color: book.isReturned ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildInfoRow('Author', book.author),
            _buildInfoRow('Book No.', book.bookNo),
            _buildInfoRow(
                'Issue Date', DateUtilities.formatStringDate(book.issueDate)),
            _buildInfoRow(
                'Return Date', DateUtilities.formatStringDate(book.returnDate)),
            _buildInfoRow(
                'Due Date', DateUtilities.formatStringDate(book.dueReturnDate)),
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
          const SizedBox(width: 5.0),
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
