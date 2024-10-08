class AttendanceData {
  DateTime date;
  String type; // present, absent, etc.
  String? name;
  String? code;
  String? timeFrom;
  String? timeTo;
  String? roomNo;
  String? remark;

  AttendanceData({
    required this.date,
    required this.type,
    this.name,
    this.code,
    this.timeFrom,
    this.timeTo,
    this.roomNo,
    this.remark,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      date: DateTime.parse(json['date']),
      type: json['type'],
      name: json['name'],
      code: json['code'],
      timeFrom: json['timeFrom'],
      timeTo: json['timeTo'],
      roomNo: json['roomNo'],
      remark: json['remark'],
    );
  }
}
