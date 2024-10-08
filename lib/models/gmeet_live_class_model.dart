class LiveClass {
  final int id;
  final String title;
  final String date;
  final int duration;
  final String className;
  final String section;
  final String staffName;
  final String staffSurname;
  final String staffRole;
  final String description;
  final String joinUrl;
  final String status; // Added status field

  LiveClass({
    required this.id,
    required this.title,
    required this.date,
    required this.duration,
    required this.className,
    required this.section,
    required this.staffName,
    required this.staffSurname,
    required this.staffRole,
    required this.description,
    required this.joinUrl,
    required this.status, // Added status to constructor
  });

  factory LiveClass.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse(json['id'].toString()) ?? 0;
    final duration = int.tryParse(json['duration'].toString()) ?? 0;
    // Assuming status is stored as a String in your JSON
    final status = json['status'].toString();

    return LiveClass(
      id: id,
      title: json['title'],
      date: json['date'],
      duration: duration,
      className: json['class'],
      section: json['section'],
      staffName: json['staff_name'],
      staffSurname: json['staff_surname'],
      staffRole: json['staff_role'],
      description: json['description'],
      joinUrl: json['url'],
      status: status, // Set the status
    );
  }
}
