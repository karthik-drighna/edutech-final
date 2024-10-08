class IssuedBook {
  final String bookTitle;
  final String author;
  final String bookNo;
  final String issueDate;
  final String returnDate;
  final String dueReturnDate;
  final bool isReturned;

  IssuedBook({
    required this.bookTitle,
    required this.author,
    required this.bookNo,
    required this.issueDate,
    required this.returnDate,
    required this.dueReturnDate,
    required this.isReturned,
  });

  factory IssuedBook.fromJson(Map<String, dynamic> json) {
    return IssuedBook(
      bookTitle: json['book_title'],
      author: json['author'],
      bookNo: json['book_no'],
      issueDate: json['issue_date'],
      returnDate: json['return_date'] ?? '', // Handle null return date
      dueReturnDate: json['due_return_date'],
      isReturned: json['is_returned'] == "1", // Assuming 1 means true
    );
  }
}

class Book {
  final String id;
  final String title;
  final String subject;
  final String rackNo;
  final String author;
  final String publisher;
  final int quantity;
  final double cost;
  final String description;
  final String? postDate;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.quantity,
    required this.cost,
    required this.description,
    required this.subject,
    required this.rackNo,
    this.postDate,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'].toString(),
      title: json['book_title'] ?? 'No title',
      author: json['author'] ?? 'Unknown',
      publisher: json['publish'] ?? 'Unknown',
      quantity: int.tryParse(json['qty'].toString()) ?? 0,
      cost: double.tryParse(json['perunitcost'].toString()) ?? 0.0,
      description: json['description'] ?? '',
      subject: json['subject'].toString(),
      rackNo: json['rack_no'].toString(),
      postDate: json['postdate']??"",
    );
  }
}

