
class Sections {
  final String id;
  final String sectionTitle;
  final List<LessonQuiz> lessonQuizzes;

  Sections({
    required this.id,
    required this.sectionTitle,
    required this.lessonQuizzes,
  });

  factory Sections.fromJson(Map<String, dynamic> json) {
    var list = json['lesson_quiz'] as List;
    List<LessonQuiz> lessonQuizList =
        list.map((i) => LessonQuiz.fromJson(i)).toList();

    return Sections(
      id: json['id'].toString(),
      sectionTitle: json['section_title'].toString(),
      lessonQuizzes: lessonQuizList,
    );
  }
}

class LessonQuiz {
  final String id;
  final String lessonTitle;
  final String lessonType;
  final String duration;
  final String type;
  final String quizTitle;

  LessonQuiz({
    required this.id,
    required this.lessonTitle,
    required this.lessonType,
    required this.duration,
    required this.type,
    required this.quizTitle,
  });

  factory LessonQuiz.fromJson(Map<String, dynamic> json) {
    return LessonQuiz(
        id: json['id'].toString(),
        lessonTitle: json['lesson_title'].toString(),
        lessonType: json['lesson_type'].toString(),
        duration: json['duration'].toString(),
        type: json['type'] ?? "",
        quizTitle: json['quiz_title'].toString());
  }
}