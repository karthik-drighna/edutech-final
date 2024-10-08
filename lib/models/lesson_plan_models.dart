
class Subject {
  final String name;
  final String timeFrom;
  final String timeTo;
  final String subjectId;

  Subject(
      {required this.name,
      required this.timeFrom,
      required this.timeTo,
      required this.subjectId});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      name: json['name'] as String,
      timeFrom: json['time_from'] as String,
      timeTo: json['time_to'] as String,
      subjectId: json['subject_syllabus_id'] as String,
    );
  }
}

class LessonModel {
  final int id;
  final int sessionId;
  final int subjectGroupId;
  final int classSectionId;
  final String name;
  final DateTime createdAt;
  final int total;
  final int totalComplete;
  final List<TopicModel> topics;

  LessonModel({
    required this.id,
    required this.sessionId,
    required this.subjectGroupId,
    required this.classSectionId,
    required this.name,
    required this.createdAt,
    required this.total,
    required this.totalComplete,
    required this.topics,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    var topicJson = json['topics'] as List;
    List<TopicModel> topics =
        topicJson.map((i) => TopicModel.fromJson(i)).toList();

    return LessonModel(
      id: int.parse(json['id'].toString()),
      sessionId: int.parse(json['session_id'].toString()),
      subjectGroupId: int.parse(json['subject_group_subject_id'].toString()),
      classSectionId:
          int.parse(json['subject_group_class_sections_id'].toString()),
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      total: int.parse(json['total'].toString()),
      totalComplete: int.parse(json['total_complete'].toString()),
      topics: topics,
    );
  }
}

class TopicModel {
  final int id;
  final int sessionId;
  final int lessonId;
  final String name;
  final int status;
  final DateTime? completeDate;
  final DateTime createdAt;

  TopicModel({
    required this.id,
    required this.sessionId,
    required this.lessonId,
    required this.name,
    required this.status,
    this.completeDate,
    required this.createdAt,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: int.parse(json['id'].toString()),
      sessionId: int.parse(json['session_id'].toString()),
      lessonId: int.parse(json['lesson_id'].toString()),
      name: json['name'],
      status: int.parse(json['status'].toString()),
      completeDate: json['complete_date'] != "0000-00-00"
          ? DateTime.parse(json['complete_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

