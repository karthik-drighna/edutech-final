class Teacher {
  final String name;
  final String contact;
  final String email;
  final String classTeacherId;
  final String comment;
  final String staffId;
  final int rating;
  final List<Subject> subjects;

  Teacher({
    required this.name,
    required this.contact,
    required this.email,
    required this.classTeacherId,
    required this.comment,
    required this.staffId,
    required this.rating,
    required this.subjects,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    var subjectList = json['subjects'] as List;
    List<Subject> subjects =
        subjectList.map((i) => Subject.fromJson(i)).toList();

    return Teacher(
      name:
          "${json['staff_name']} ${json['staff_surname']} (${json['employee_id']})",
      contact: json['contact_no'] ?? "N/A",
      email: json['email'],
      classTeacherId: json['class_teacher_id'],
      comment: json['comment'],
      staffId: json['staff_id'],
      rating: (json['rate'] is int)
          ? json['rate']
          : int.parse(json['rate']), // Ensure rating is an int
      subjects: subjects,
    );
  }
}

class Subject {
  final String subjectName;
  final String type;
  final String day;
  final String timeFrom;
  final String timeTo;
  final String roomNo;

  Subject({
    required this.subjectName,
    required this.type,
    required this.day,
    required this.timeFrom,
    required this.timeTo,
    required this.roomNo,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectName: json['subject_name'],
      type: json['type'],
      day: json['day'],
      timeFrom: json['time_from'],
      timeTo: json['time_to'],
      roomNo: json['room_no'],
    );
  }
}
