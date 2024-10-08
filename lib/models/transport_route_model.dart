class TransportRoute {
  final String routeTitle;
  final String vehicleNumber;
  final String vehicleModel;
  final String driverName;
  final String driverContact;
  final String driverLicence;
  final String made;
  final String vehiclePhoto;
  final List<PickupPoint> pickupPoints;

  TransportRoute({
    required this.routeTitle,
    required this.vehicleNumber,
    required this.vehicleModel,
    required this.driverName,
    required this.driverContact,
    required this.driverLicence,
    required this.made,
    required this.vehiclePhoto,
    required this.pickupPoints,
  });
  factory TransportRoute.fromJson(
      Map<String, dynamic> json, List<PickupPoint> pickupPoints) {
    return TransportRoute(
      routeTitle: json['route_title'] ?? '',
      vehicleNumber: json['vehicle_no'] ?? '',
      vehicleModel: json['vehicle_model'] ?? '',
      driverName: json['driver_name'] ?? '',
      driverContact: json['driver_contact'] ?? '',
      driverLicence: json['driver_licence'] ?? '',
      made: json['manufacture_year'] ?? '',
      vehiclePhoto: json['vehicle_photo'] ?? '',
      pickupPoints: pickupPoints,
    );
  }
}

class PickupPoint {
  final String id;
  final String pickupPoint;
  final String destinationDistance;
  final String pickupTime;

  PickupPoint({
    required this.id,
    required this.pickupPoint,
    required this.destinationDistance,
    required this.pickupTime,
  });

  factory PickupPoint.fromJson(Map<String, dynamic> json) {
    return PickupPoint(
      id: json['id'].toString(),
      pickupPoint: json['pickup_point'] ?? '',
      destinationDistance: json['destination_distance'] ?? '',
      pickupTime: json['pickup_time'] ?? '',
    );
  }
}
