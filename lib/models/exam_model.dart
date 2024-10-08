class Examination {
  final String id;
  final String examGroupClassBatchExamId;
  final String studentId;
  final String studentSessionId;
  final String? rollNo;
  final String? teacherRemark;
  final String rank;
  final String isActive;
  final String createdAt;
  final String? updatedAt;
  final String exam;
  final String description;
  final String examActive;
  final String resultPublish;

  Examination({
    required this.id,
    required this.examGroupClassBatchExamId,
    required this.studentId,
    required this.studentSessionId,
    this.rollNo,
    this.teacherRemark,
    required this.rank,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    required this.exam,
    required this.description,
    required this.examActive,
    required this.resultPublish,
  });

  factory Examination.fromJson(Map<String, dynamic> json) {
    return Examination(
      id: json['id'],
      examGroupClassBatchExamId: json['exam_group_class_batch_exam_id'],
      studentId: json['student_id'],
      studentSessionId: json['student_session_id'],
      rollNo: json['roll_no'],
      teacherRemark: json['teacher_remark'],
      rank: json['rank'],
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      exam: json['exam'],
      description: json['description'],
      examActive: json['exam_active'],
      resultPublish: json['result_publish'],
    );
  }
}
