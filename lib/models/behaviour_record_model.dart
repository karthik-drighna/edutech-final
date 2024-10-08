class BehaviorRecord {
  final String title;
  final String point;
  final String description;
  final String id;
  final String createdAt;
  final String studentId;
  final String firstName;
  final String middleName;
  final String lastName;
  final String admissionNo;
  final String session;
  final String staffName;
  final String staffSurname;
  final String staffEmployeeId;
  final String roleName;
  final String roleId;
  final int commentCount;

  BehaviorRecord({
    required this.title,
    required this.point,
    required this.description,
    required this.id,
    required this.createdAt,
    required this.studentId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.admissionNo,
    required this.session,
    required this.staffName,
    required this.staffSurname,
    required this.staffEmployeeId,
    required this.roleName,
    required this.roleId,
    required this.commentCount,
  });

  factory BehaviorRecord.fromJson(Map<String, dynamic> json) {
    return BehaviorRecord(
      title: json['title'] ?? '',
      point: json['point'] ?? '',
      description: json['description'] ?? '',
      id: json['id'] ?? '',
      createdAt: json['created_at'] ?? '',
      studentId: json['student_id'] ?? '',
      firstName: json['firstname'] ?? '',
      middleName: json['middlename'] ?? '',
      lastName: json['lastname'] ?? '',
      admissionNo: json['admission_no'] ?? '',
      session: json['session'] ?? '',
      staffName: json['staff_name'] ?? '',
      staffSurname: json['staff_surname'] ?? '',
      staffEmployeeId: json['staff_employee_id'] ?? '',
      roleName: json['role_name'] ?? '',
      roleId: json['role_id'] ?? '',
      commentCount: json['comment_count'] ?? 0,
    );
  }
}
