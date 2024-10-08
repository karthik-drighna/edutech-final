class LeaveApplication {
  final String applyDate;
  final String fromDate;
  final String toDate;
  final String reason;
  final String status;
  final String id;
  final String approveDate;
  final String documentFile;

  LeaveApplication(
      {required this.applyDate,
      required this.fromDate,
      required this.toDate,
      required this.reason,
      required this.status,
      required this.id,
      required this.approveDate,
      required this.documentFile});

  // We'll use this factory method inside the UI building code directly
  static LeaveApplication fromJson(Map<String, dynamic> json) {
    return LeaveApplication(
        applyDate: json['apply_date'],
        fromDate: json['from_date'],
        toDate: json['to_date'],
        reason: json['reason'] ?? 'No reason provided',
        status: json['status'].toString(),
        approveDate: json['approve_date'] ?? "",
        id: json['id'].toString(),
        documentFile: json['docs']);
  }
}
