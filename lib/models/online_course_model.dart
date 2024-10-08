
import 'dart:convert';

class CourseDetail {
  final int id;
  final String title;
  final String slug;
  final String url;
  final String description;
  final int teacherId;
  final int categoryId;
  final List<String> outcomes;
  final String courseThumbnail;
  final String courseProvider;
  final String?
      courseUrl; // nullable because the provided JSON value is an empty string
  final String? videoId; // nullable for the same reason
  final double price;
  final double discount;
  final bool isFree;
  final int? viewCount; // nullable because the provided JSON value is null
  final bool frontSideVisibility;
  final int status;
  final int createdBy;
  final DateTime createdDate;
  final DateTime updatedDate;
  final int classSectionsId;
  final String className;
  final String name;
  final String?
      surname; // nullable because the provided JSON value is an empty string
  final String image;
  final String gender;
  final String section;
  final int classId;
  final int sectionId;
  final String totalHour;
  final int lessonCount;
  final int quizCount;

  CourseDetail({
    required this.id,
    required this.title,
    required this.slug,
    required this.url,
    required this.description,
    required this.teacherId,
    required this.categoryId,
    required this.outcomes,
    required this.courseThumbnail,
    required this.courseProvider,
    this.courseUrl,
    this.videoId,
    required this.price,
    required this.discount,
    required this.isFree,
    this.viewCount,
    required this.frontSideVisibility,
    required this.status,
    required this.createdBy,
    required this.createdDate,
    required this.updatedDate,
    required this.classSectionsId,
    required this.className,
    required this.name,
    this.surname,
    required this.image,
    required this.gender,
    required this.section,
    required this.classId,
    required this.sectionId,
    required this.totalHour,
    required this.lessonCount,
    required this.quizCount,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    return CourseDetail(
      id: int.parse(json['id'] as String),
      title: json['title'] as String,
      slug: json['slug'] as String,
      url: json['url'] as String,
      description: json['description'] as String,
      teacherId: int.parse(json['teacher_id'] as String),
      categoryId: int.parse(json['category_id'] as String),
      outcomes: (jsonDecode(json['outcomes'] as String) as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      courseThumbnail: json['course_thumbnail'] as String,
      courseProvider: json['course_provider'] as String,
      courseUrl: json['course_url'] as String?,
      videoId: json['video_id'] as String?,
      price: double.parse(json['price'] as String),
      discount: double.parse(json['discount'] as String),
      isFree: (json['free_course'] as String) == '1',
      viewCount: json['view_count'] as int?,
      frontSideVisibility: (json['front_side_visibility'] as String) == 'yes',
      status: int.parse(json['status'] as String),
      createdBy: int.parse(json['created_by'] as String),
      createdDate: DateTime.parse(json['created_date'] as String),
      updatedDate: DateTime.parse(json['updated_date'] as String),
      classSectionsId: int.parse(json['class_sections_id'] as String),
      className: json['class'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      image: json['image'] as String,
      gender: json['gender'] as String,
      section: json['section'] as String,
      classId: int.parse(json['class_id'] as String),
      sectionId: int.parse(json['section_id'] as String),
      totalHour: json['total_hour'] as String,
      lessonCount: json['lesson_count'] as int,
      quizCount: json['quiz_count'] as int,
    );
  }
}

class Section{
  final String id;
  final String sectionTitle;
  final List<LessonQuiz> lessonQuizzes;

  Section(
      {required this.id,
      required this.sectionTitle,
      required this.lessonQuizzes});

  factory Section.fromJson(Map<String, dynamic> json) {
    var list = json['lesson_quiz'] as List;
    List<LessonQuiz> lessonQuizList =
        list.map((i) => LessonQuiz.fromJson(i)).toList();

    return Section(
      id: json['id'],
      sectionTitle: json['section_title'],
      lessonQuizzes: lessonQuizList,
    );
  }
}

class LessonQuiz {
  final String lessonTitle;
  final String quizTitle;
  final String type;
  final String duration;
  final String quizId;

  LessonQuiz({
    required this.lessonTitle,
    required this.quizTitle,
    required this.type,
    required this.duration,
    required this.quizId,
  });

  factory LessonQuiz.fromJson(Map<String, dynamic> json) {
    return LessonQuiz(
      lessonTitle: json['lesson_title'] ?? '', // Provide a default empty string
      quizTitle: json['quiz_title'] ?? '',
      type: json['type'] ?? '',
      duration: json['duration'] ?? '',
      quizId: json['quiz_id'] ?? '',
    );
  }
}