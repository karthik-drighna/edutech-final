class NoticeBoardModel {
  final String id;
  final String title;
  final String publishDate;
  final String date;
  final String attachment;
  final String message;
  final String createdBy;
  final String employeeId; // Change type to String

  NoticeBoardModel({
    required this.id,
    required this.title,
    required this.publishDate,
    required this.date,
    required this.attachment,
    required this.message,
    required this.createdBy,
    required this.employeeId, // Change type to String
  });

  factory NoticeBoardModel.fromJson(Map<String, dynamic> json) {
    return NoticeBoardModel(
      id: json['id'],
      title: json['title'],
      publishDate: json['publish_date'],
      date: json['date'],
      attachment: json['attachment'],
      message: json['message'],
      createdBy: json['created_by'],
      employeeId: json['employee_id'],
    );
  }
}
