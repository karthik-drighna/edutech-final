class SyllabusSubject {
  final int id;
  final int subjectGroupId;
  final int classSectionId;
  final int sessionId;
  final String? description;
  final int isActive;
  final String createdAt;
  final String? updatedAt;
  final String name;
  final int subjectId;
  final int subjectGroupSubjectId;
  final String subjectName;
  final String subjectCode;
  final int total;
  final int totalComplete;

  SyllabusSubject({
    required this.id,
    required this.subjectGroupId,
    required this.classSectionId,
    required this.sessionId,
    this.description,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    required this.name,
    required this.subjectId,
    required this.subjectGroupSubjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.total,
    required this.totalComplete,
  });

  factory SyllabusSubject.fromJson(Map<String, dynamic> json) {
    return SyllabusSubject(
      id: int.parse(json['id'].toString()),
      subjectGroupId: int.parse(json['subject_group_id'].toString()),
      classSectionId: int.parse(json['class_section_id'].toString()),
      sessionId: int.parse(json['session_id'].toString()),
      description: json['description'],
      isActive: int.parse(json['is_active'].toString()),
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'],
      name: json['name'].toString(),
      subjectId: int.parse(json['subject_id'].toString()),
      subjectGroupSubjectId:
          int.parse(json['subject_group_subject_id'].toString()),
      subjectName: json['subject_name'].toString(),
      subjectCode: json['subject_code'].toString(),
      total: int.parse(json['total'].toString()),
      totalComplete: int.parse(json['total_complete'].toString()),
    );
  }
}
