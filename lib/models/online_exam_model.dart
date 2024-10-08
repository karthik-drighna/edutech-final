
class Question {
  final String id;
  final String question;
  final double marks;
  final double negMarks;
  final String questionType; // Assuming you have this field in your JSON

  Question({
    required this.id,
    required this.question,
    required this.marks,
    required this.negMarks,
    required this.questionType, // Don't forget to initialize this in your constructor
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      marks: double.tryParse(json['marks'].toString()) ?? 0.0,
      negMarks: double.tryParse(json['neg_marks'].toString()) ?? 0.0,
      questionType: json['question_type'], // Make sure to parse this from JSON
    );
  }
}
