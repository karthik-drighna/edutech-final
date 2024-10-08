class Section {
  final String id;
  final String sectionTitle;
  final String title;
  final List<LessonQuiz> lessonQuizzes;

  Section(
      {required this.id,
      required this.sectionTitle,
      required this.lessonQuizzes,
      required this.title});

  factory Section.fromJson(Map<String, dynamic> json) {
    var list = json['lesson_quiz'] as List;
    List<LessonQuiz> lessonQuizList =
        list.map((i) => LessonQuiz.fromJson(i)).toList();

    return Section(
        id: json['id'].toString(),
        sectionTitle: json['section_title'].toString(),
        lessonQuizzes: lessonQuizList,
        title: json['title'].toString());
  }
}

class LessonQuiz {
  final String id;
  final String lessonTitle;
  final String lessonType;
  final String duration;
  final String type;
  final String quizTitle;
  final String lessonId;
  final String courseSectionId;
  final String attatchmentFile;
  final int quizStatus;
  final String summary;
  int progress; // make mutable
  final String videoUrl;

  LessonQuiz({
    required this.id,
    required this.lessonTitle,
    required this.lessonType,
    required this.duration,
    required this.type,
    required this.quizTitle,
    required this.lessonId,
    required this.courseSectionId,
    required this.attatchmentFile,
    required this.quizStatus,
    required this.progress,
    required this.videoUrl,
    required this.summary,
  });

  void toggleProgress() {
    progress = progress == 1 ? 0 : 1;
  }

  factory LessonQuiz.fromJson(Map<String, dynamic> json) {
    return LessonQuiz(
        id: json['id'].toString(),
        lessonTitle: json['lesson_title'] ?? "",
        lessonType: json['lesson_type'] ?? "",
        duration: json['duration'] ?? "",
        type: json['type'] ?? "",
        quizTitle: json['quiz_title'] ?? "",
        lessonId: json['lesson_id'],
        courseSectionId: json['course_section_id'],
        quizStatus: json["quiz_status"],
        progress: json['progress'],
        summary: json['summary'],
        attatchmentFile: json['attachment'].toString(),
        videoUrl: json['video_url'] ?? "");
  }
}
