class VideoModel {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final String videoLink;
  final String thumbnailPath;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.videoLink,
    required this.thumbnailPath,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      createdBy: "${json['name']} ${json['surname']} (${json['employee_id']})",
      videoLink: json['video_link'],
      thumbnailPath: json['thumb_path'] + json['thumb_name'],
    );
  }
}
