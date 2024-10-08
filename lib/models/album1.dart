class Album1 {
  String name;
  String thumbnail;
  String value;

  Album1({required this.name, required this.thumbnail, required this.value});

  // Method to convert a Dart object into a Map. Useful for encoding data
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'thumbnail': thumbnail,
      'value': value,
    };
  }

  // Constructor to create an Album1 object from a Map. Useful for decoding data
  factory Album1.fromJson(Map<String, dynamic> json) {
    return Album1(
      name: json['name'],
      thumbnail: json['thumbnail'],
      value: json['value'],
    );
  }
}
