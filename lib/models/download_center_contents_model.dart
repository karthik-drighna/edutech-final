class Assignment {
  final String id;
  final String title;
  final String description;
  final String shareDate;
  final String validUpto;
  final String sharedBy;
  final String uploadDate;
  final String videoUrl;
  final List<Attachment> attachments;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.shareDate,
    required this.validUpto,
    required this.sharedBy,
    required this.uploadDate,
    required this.attachments,
    required this.videoUrl
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
  var list = json['upload_contents'] as List;
  List<Attachment> attachmentsList = list.map((i) => Attachment.fromJson(i)).toList();

  String videoUrl = '';
  if (attachmentsList.isNotEmpty) {
    // Assuming the first attachment contains the video URL
    videoUrl = attachmentsList.first.vidUrl;
  }

  return Assignment(
    id: json['id'].toString(),
    title: json['title']?? '',
    description: json['description'] ?? '', // Provide a default empty string
    shareDate: json['share_date']?? '',
    validUpto: json['valid_upto']??'',
    sharedBy: "${json['name']} ${json['surname']}".trim(),
    uploadDate: json['created_at']??'',
    videoUrl: videoUrl,
    attachments: attachmentsList,
  );
}

}

class Attachment {
  final String realName;
  final String thumbPath;
  final String dirPath;
  final String imgName;
  final String thumbName;
  
  final String fileType;
  final String vidUrl;
  final String vidTitle;

  Attachment({
    required this.realName,
    required this.thumbPath,
    required this.dirPath,
    required this.imgName,
    required this.thumbName,
    required this.fileType,
    required this.vidUrl,
    required this.vidTitle,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      realName: json['real_name'],
      thumbPath: json['thumb_path'],
      dirPath: json['dir_path'],
      imgName: json['img_name'],
      thumbName: json['thumb_name'],
      fileType: json['file_type'],
      vidUrl: json['vid_url'],
      vidTitle: json['vid_title'],
    );
  }
}
