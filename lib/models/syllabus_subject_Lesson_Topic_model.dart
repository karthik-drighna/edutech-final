
class SyllabusSubjectModel {
  int id;
  String name;
  int total;
  int totalComplete;
  List<TopicModelForLessonTopic> topics;

  SyllabusSubjectModel({
    required this.id,
    required this.name,
    required this.total,
    required this.totalComplete,
    required this.topics,
  });

  factory SyllabusSubjectModel.fromJson(Map<String, dynamic> json) {
    return SyllabusSubjectModel(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      total: int.parse(json['total'].toString()),
      totalComplete: int.parse(json['total_complete'].toString()),
      topics: (json['topics'] as List)
          .map((topicJson) => TopicModelForLessonTopic.fromJson(topicJson))
          .toList(),
    );
  }
}

class TopicModelForLessonTopic {
  int id;
  String name;
  int status; // Assuming 0 for incomplete, 1 for complete
  String? completeDate;

  TopicModelForLessonTopic({
    required this.id,
    required this.name,
    required this.status,
    this.completeDate,
  });

  factory TopicModelForLessonTopic.fromJson(Map<String, dynamic> json) {
    return TopicModelForLessonTopic(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      status: int.parse(json['status'].toString()),
      completeDate: json['complete_date'],
    );
  }
}
