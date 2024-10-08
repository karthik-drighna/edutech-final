class AboutSchoolData {
  final String name;
  final String address;
  final String email;
  final String phone;
  final String schoolCode;
  final String currentSession;
  final String sessionStartMonth;
  final String imageUrl;

  AboutSchoolData({
    required this.name,
    required this.address,
    required this.email,
    required this.phone,
    required this.schoolCode,
    required this.currentSession,
    required this.sessionStartMonth,
    required this.imageUrl,
  });

  factory AboutSchoolData.fromJson(Map<String, dynamic> json) {
    return AboutSchoolData(
      name: json['name'] ?? "",
      address: json['address'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      schoolCode: json['dise_code'] ?? "",
      currentSession: json['session'] ?? "",
      sessionStartMonth: json['start_month_name'] ?? "",
      imageUrl: json['image'] ?? "",
    );
  }
}
