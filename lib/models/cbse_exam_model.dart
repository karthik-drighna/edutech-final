class CbseExamModel {
  String name;
  int examTotalMarks;
  int examPercentage;
  String examGrade;
  String examRank;
  int examObtainMarks;
  List<SubjectModel> subjects;

  CbseExamModel({
    required this.name,
    required this.examTotalMarks,
    required this.examPercentage,
    required this.examGrade,
    required this.examRank,
    required this.examObtainMarks,
    required this.subjects,
  });

  factory CbseExamModel.fromJson(Map<String, dynamic> json) {
    var subjectsList = json['subjects'] as List;
    List<SubjectModel> subjectList = subjectsList.map((i) => SubjectModel.fromJson(i)).toList();

    return CbseExamModel(
      name: json['name'],
      examTotalMarks: json['exam_total_marks'] ?? 0,
      examPercentage: json['exam_percentage'] ?? 0,
      examGrade: json['exam_grade'] ?? '',
      examRank: json['exam_rank'] ?? '',
      examObtainMarks: json['exam_obtain_marks'] ?? 0,
      subjects: subjectList,
    );
  }
}

class SubjectModel {
  String subjectName;
  String subjectCode;
  List<ExamAssismentModel> assessments;

  SubjectModel({
    required this.subjectName,
    required this.subjectCode,
    required this.assessments,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    var assessmentsList = json['exam_assessments'] as List;
    List<ExamAssismentModel> assessmentList = assessmentsList.map((e) => ExamAssismentModel.fromJson(e)).toList();

    return SubjectModel(
      subjectName: json['subject_name'],
      subjectCode: json['subject_code'],
      assessments: assessmentList,
    );
  }
}

class ExamAssismentModel {
  String name;
  String marks;

  ExamAssismentModel({
    required this.name,
    required this.marks,
  });

  factory ExamAssismentModel.fromJson(Map<String, dynamic> json) {
    return ExamAssismentModel(
      name: json['cbse_exam_assessment_type_name'] ?? '',
      marks: json['marks'] ?? '',
    );
  }
}
