// homework_model.dart
class HomeworkModel {
    final String id;
    final String marksObtained;
  final String title;
  final String status;
  final String homeworkDate;
  final String submissionDate;
  final String createdBy;
  final String evaluatedBy;
  final String evaluationDate;
  final double marks;
  final String note;
  final String description;
  final String homeworkDocument;

  HomeworkModel({
    
    required this.id,
    required this.title,
    required this.status,
    required this.homeworkDate,
    required this.submissionDate,
    required this.createdBy,
    required this.evaluatedBy,
    required this.evaluationDate,
    required this.marks,
    required this.note,
    required this.description,
    required this.marksObtained,
    required this.homeworkDocument
  });
}
