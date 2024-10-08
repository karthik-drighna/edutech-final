class ReportCardData {
  final String exam;
  final double percentage;
  final String division;
  final String grade;
  final String resultStatus;
  final int rank;
  final double grandTotal;
  final double totalMaxMarks;
  final List<SubjectResult> subjectResults;

  ReportCardData({
    required this.exam,
    required this.percentage,
    required this.division,
    required this.grade,
    required this.resultStatus,
    required this.rank,
    required this.grandTotal,
    required this.totalMaxMarks,
    required this.subjectResults,
  });

  factory ReportCardData.fromJson(Map<String, dynamic> json) {
    var subjectResultsList = json['subject_result'] as List;
    List<SubjectResult> subjectResults =
        subjectResultsList.map((i) => SubjectResult.fromJson(i)).toList();

    return ReportCardData(
      exam: json['exam'],
      percentage: double.parse(json['percentage'].toString()),
      division: json['division'],
      grade: json['exam_grade'],
      resultStatus: json['exam_result_status'],
      rank: int.parse(json['rank'].toString()),
      grandTotal: double.parse(json['total_get_marks'].toString()),
      totalMaxMarks: double.parse(json['total_max_marks'].toString()),
      subjectResults: subjectResults,
    );
  }
}

class SubjectResult {
  final String name;
  final String code;
  final double getMarks;
  final double maxMarks;
  final String minMarks;
  final String examGrade;
  final String note;

  SubjectResult({
    required this.name,
    required this.code,
    required this.getMarks,
    required this.maxMarks,
    required this.minMarks,
    required this.examGrade,
    required this.note,
  });

  factory SubjectResult.fromJson(Map<String, dynamic> json) {
    return SubjectResult(
      name: json['name'],
      code: json['code'],
      getMarks: double.parse(json['get_marks'].toString()),
      maxMarks: double.parse(json['max_marks'].toString()),
      minMarks: json['min_marks'].toString(),
      examGrade: json['exam_grade'],
      note: json['note'] ?? '',
    );
  }
}
