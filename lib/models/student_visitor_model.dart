class Visitor {
  final String name;
  final String purpose;
  final String idProof;
  final int numberOfPeople;
  final String date;
  final String inTime;
  final String outTime;
  final String note;
  final String meetingWith;
  final String createdAt;
  final String contact;

  Visitor({
    required this.name,
    required this.purpose,
    required this.idProof,
    required this.numberOfPeople,
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.note,
    required this.meetingWith,
    required this.createdAt,
    required this.contact,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      name: json['name'],
      purpose: json['purpose'],
      idProof: json['id_proof'],
      numberOfPeople:
          int.tryParse(json['no_of_people']?.toString() ?? '0') ?? 0,
      date: json['date'],
      inTime: json['in_time'],
      outTime: json['out_time'],
      note: json['note'],
      meetingWith: json['meeting_with'],
      createdAt: json['created_at'],
      contact: json['contact'] ?? '',
    );
  }
}
