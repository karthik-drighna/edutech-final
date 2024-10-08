
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/utils/utility.dart';

class CourseModel {
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
  final String courseUrl;
  final String videoId;
  final double price;
  final double discount;
  final String freeCourse;
  final int? viewCount;
  final bool frontSideVisibility;
  final int status;
  final DateTime createdDate;
  final DateTime updatedDate;
  final String classInfo;
  final String name;
  final String surname;
  final String image;
  final String gender;
  final int staffId;
  final String staffEmployeeId;
  final List<Section> sections;
  final String createdStaffName;
  final String createdStaffSurname;
  final String createdStaffEmployeeId;
  final int totalLesson;
  final String totalHourCount;
  final bool paidStatus;
  final int courseProgress;
  final int totalCourseRating;
  final int courseRating;

  CourseModel({
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
    required this.courseUrl,
    required this.videoId,
    required this.price,
    required this.discount,
    required this.freeCourse,
    this.viewCount,
    required this.frontSideVisibility,
    required this.status,
    required this.createdDate,
    required this.updatedDate,
    required this.classInfo,
    required this.name,
    required this.surname,
    required this.image,
    required this.gender,
    required this.staffId,
    required this.staffEmployeeId,
    required this.sections,
    required this.createdStaffName,
    required this.createdStaffSurname,
    required this.createdStaffEmployeeId,
    required this.totalLesson,
    required this.totalHourCount,
    required this.paidStatus,
    required this.courseProgress,
    required this.totalCourseRating,
    required this.courseRating,
  });

  static Future<CourseModel> fromJson(Map<String, dynamic> json) async {
      final basePriceString = await Utility.getString(Constants.currency_price) ?? '1.0';
    final double basePrice = double.tryParse(basePriceString) ?? 1.0;
    final double originalPrice = double.parse(json['price'].toString());
    final double convertedPrice = await Utility.changeAmount(originalPrice, basePrice);

    // Fetch the class name
  String className = json['class'].toString();
  
  // Fetch the section list, map it to section names, and join with commas
  String sectionsFormatted = (json['section'] as List)
      .map((s) => Section.fromJson(s).section)
      .join(', ');
// Combine the class name with the formatted sections
  String classInfo = "$className - ($sectionsFormatted)";

    return CourseModel(
      id: int.parse(json['id']),
      title: json['title'] ?? "",
      slug: json['slug'] ?? "",
      url: json['url'] ?? "",
      description: json['description'] ?? "",
      teacherId: int.parse(json['teacher_id']),

      categoryId: int.parse(json['category_id'].toString()),
      outcomes: json['outcomes'] is List ? List<String>.from(json['outcomes']) : [],
      courseThumbnail: json['course_thumbnail'] ?? "",
      courseProvider: json['course_provider'] ?? "",
      courseUrl: json['course_url'] ?? "",
      videoId: json['video_id'] ?? "",
      price: convertedPrice,
      discount: double.parse(json['discount']?.toString() ?? "0"),
      freeCourse: json['free_course'],
      viewCount: json['view_count'] != null ? int.tryParse(json['view_count']) : null,
      frontSideVisibility: json['front_side_visibility']?.toString().toLowerCase() == 'yes',
      status: int.parse(json['status'].toString()),
      createdDate: json['created_date'] != null ? DateTime.parse(json['created_date']) : DateTime.now(),
      updatedDate: json['updated_date'] != null ? DateTime.parse(json['updated_date']) : DateTime.now(),
      classInfo: classInfo,
      name: json['name'] ?? "",
      surname: json['surname'] ?? "",
      image: json['image'] ?? "",
      gender: json['gender'] ?? "",
      staffId: int.parse(json['staff_id'].toString()),
      staffEmployeeId: json['staff_employee_id'] ?? "",
      sections: (json['section'] as List?)?.map((e) => Section.fromJson(e)).toList() ?? [],
      createdStaffName: json['created_staff_name'] ?? "",
      createdStaffSurname: json['created_staff_surname'] ?? "",
      createdStaffEmployeeId: json['created_staff_employee_id'] ?? "",
      totalLesson: json['total_lesson'],
      totalHourCount:json['total_hour_count']??"",
      paidStatus: json['paidstatus'] == 1,
      courseProgress: json['course_progress'],
      totalCourseRating: json['totalcourserating'],
      courseRating: json['courserating'],
    );
  }
}

class Section {
  final String id;
  final String section;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Section({
    required this.id,
    required this.section,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      section: json['section'],
      isActive: json['is_active'].toString().toLowerCase() == 'yes' || json['is_active'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}
