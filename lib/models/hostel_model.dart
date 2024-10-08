
class Hostel {
  final String id, hostelName, roomType, roomNo, noOfBed, costPerBed, assign;

  Hostel({
    required this.id,
    required this.hostelName,
    required this.roomType,
    required this.roomNo,
    required this.noOfBed,
    required this.costPerBed,
    required this.assign,
  });

  factory Hostel.fromJson(Map<String, dynamic> json) {
    return Hostel(
      id: json['id'].toString(),
      hostelName: json['hostel_name'],
      roomType: json['room_type'],
      roomNo: json['room_no'],
      noOfBed: json['no_of_bed'].toString(),
      costPerBed: json['cost_per_bed'].toString(),
      assign: json['assign'].toString(),
    );
  }
}