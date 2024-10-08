class StudentProfile {
  final String name;
  final String admissionNo;
  final String rollNo;
  final String? behaviourScore;
  final String classInfo;
  final String imgUrl;
  final String barcodeUrl;
  final String pickupPointName;
  final String routePickupPointId;
  final String transportFees;
  final String parentAppKey;
  final String vehrouteId;
  final String routeId;
  final String vehicleId;
  final String routeTitle;
  final String vehicleNo;
  final String roomNo;
  final String driverName;
  final String driverContact;
  final String vehicleModel;
  final String manufactureYear;
  final String driverLicence;
  final String vehiclePhoto;
  final String hostelId;
  final String hostelName;
  final String roomTypeId;
  final String roomType;
  final String hostelRoomId;
  final String studentSessionId;
  final String feesDiscount;
  final String classId;
  final String sectionId;
  final String admissionDate;
  final String firstName;
  final String middleName;
  final String lastName;
  final String mobileNo;
  final String email;
  final String state;
  final String city;
  final String pincode;
  final String note;
  final String religion;
  final String cast;
  final String houseName;
  final String dob;
  final String currentAddress;
  final String previousSchool;
  final String guardianIs;
  final String parentId;
  final String permanentAddress;
  final String categoryId;
  final String category;
  final String adharNo;
  final String samagraId;
  final String bankAccountNo;
  final String bankName;
  final String ifscCode;
  final String guardianName;
  final String fatherPic;
  final String height;
  final String weight;
  final String measurementDate;
  final String motherPic;
  final String guardianPic;
  final String guardianRelation;
  final String guardianPhone;
  final String guardianAddress;
  final String isActive;
  final String createdAt;
  final String updatedAt;
  final String fatherName;
  final String fatherPhone;
  final String bloodGroup;
  final String schoolHouseId;
  final String fatherOccupation;
  final String motherName;
  final String motherPhone;
  final String motherOccupation;
  final String guardianOccupation;
  final String gender;
  final String rte;
  final String guardianEmail;
  final String username;
  final String password;
  final String disReason;
  final String disNote;
  final String disableAt;
  final String currencyName;
  final String symbol;
  final String basePrice;
  final String currencyId;
  final String sessionId;
  final String session;

  // Constructor with all fields
  StudentProfile({
    required this.name,
    required this.admissionNo,
    required this.rollNo,
    this.behaviourScore,
    required this.classInfo,
    required this.imgUrl,
    required this.barcodeUrl,
    required this.pickupPointName,
    required this.routePickupPointId,
    required this.transportFees,
    required this.parentAppKey,
    required this.vehrouteId,
    required this.routeId,
    required this.vehicleId,
    required this.routeTitle,
    required this.vehicleNo,
    required this.roomNo,
    required this.driverName,
    required this.driverContact,
    required this.vehicleModel,
    required this.manufactureYear,
    required this.driverLicence,
    required this.vehiclePhoto,
    required this.hostelId,
    required this.hostelName,
    required this.roomTypeId,
    required this.roomType,
    required this.hostelRoomId,
    required this.studentSessionId,
    required this.feesDiscount,
    required this.classId,
    required this.sectionId,
    required this.admissionDate,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.mobileNo,
    required this.email,
    required this.state,
    required this.city,
    required this.pincode,
    required this.note,
    required this.religion,
    required this.cast,
    required this.houseName,
    required this.dob,
    required this.currentAddress,
    required this.previousSchool,
    required this.guardianIs,
    required this.parentId,
    required this.permanentAddress,
    required this.categoryId,
    required this.category,
    required this.adharNo,
    required this.samagraId,
    required this.bankAccountNo,
    required this.bankName,
    required this.ifscCode,
    required this.guardianName,
    required this.fatherPic,
    required this.height,
    required this.weight,
    required this.measurementDate,
    required this.motherPic,
    required this.guardianPic,
    required this.guardianRelation,
    required this.guardianPhone,
    required this.guardianAddress,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.fatherName,
    required this.fatherPhone,
    required this.bloodGroup,
    required this.schoolHouseId,
    required this.fatherOccupation,
    required this.motherName,
    required this.motherPhone,
    required this.motherOccupation,
    required this.guardianOccupation,
    required this.gender,
    required this.rte,
    required this.guardianEmail,
    required this.username,
    required this.password,
    required this.disReason,
    required this.disNote,
    required this.disableAt,
    required this.currencyName,
    required this.symbol,
    required this.basePrice,
    required this.currencyId,
    required this.sessionId,
    required this.session,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    var studentResult = json['student_result'];
    return StudentProfile(
      name: '${studentResult['firstname']} ${studentResult['lastname']}',
      admissionNo: studentResult['admission_no'] ?? "N/A",
      rollNo: studentResult['roll_no'] ?? "N/A",
      behaviourScore: studentResult['behaviou_score']?.toString() ?? "N/A",
      classInfo:
          '${studentResult['class']} - ${studentResult['section']} (${studentResult['session']})',
      imgUrl: studentResult['image'] ?? "N/A",
      barcodeUrl: studentResult['barcode'] ?? "N/A",
      pickupPointName: studentResult['pickup_point_name'] ?? "N/A",
      routePickupPointId: studentResult['route_pickup_point_id'] ?? "N/A",
      transportFees: studentResult['transport_fees'] ?? "N/A",
      parentAppKey: studentResult['parent_app_key'] ?? "N/A",
      vehrouteId: studentResult['vehroute_id'] ?? "N/A",
      routeId: studentResult['route_id'] ?? "N/A",
      vehicleId: studentResult['vehicle_id'] ?? "N/A",
      routeTitle: studentResult['route_title'] ?? "N/A",
      vehicleNo: studentResult['vehicle_no'] ?? "N/A",
      roomNo: studentResult['room_no'] ?? "N/A",
      driverName: studentResult['driver_name'] ?? "N/A",
      driverContact: studentResult['driver_contact'] ?? "N/A",
      vehicleModel: studentResult['vehicle_model'] ?? "N/A",
      manufactureYear: studentResult['manufacture_year'] ?? "N/A",
      driverLicence: studentResult['driver_licence'] ?? "N/A",
      vehiclePhoto: studentResult['vehicle_photo'] ?? "N/A",
      hostelId: studentResult['hostel_id'] ?? "N/A",
      hostelName: studentResult['hostel_name'] ?? "N/A",
      roomTypeId: studentResult['room_type_id'] ?? "N/A",
      roomType: studentResult['room_type'] ?? "N/A",
      hostelRoomId: studentResult['hostel_room_id'] ?? "N/A",
      studentSessionId: studentResult['student_session_id'] ?? "N/A",
      feesDiscount: studentResult['fees_discount'] ?? "N/A",
      classId: studentResult['class_id'] ?? "N/A",
      sectionId: studentResult['section_id'] ?? "N/A",
      admissionDate: studentResult['admission_date'] ?? "N/A",
      firstName: studentResult['firstname'] ?? "N/A",
      middleName: studentResult['middlename'] ?? "N/A",
      lastName: studentResult['lastname'] ?? "N/A",
      mobileNo: studentResult['mobileno'] ?? "N/A",
      email: studentResult['email'] ?? "N/A",
      state: studentResult['state'] ?? "N/A",
      city: studentResult['city'] ?? "N/A",
      pincode: studentResult['pincode'] ?? "N/A",
      note: studentResult['note'] ?? "N/A",
      religion: studentResult['religion'] ?? "N/A",
      cast: studentResult['cast'] ?? "N/A",
      houseName: studentResult['house_name'] ?? "N/A",
      dob: studentResult['dob'] ?? "N/A",
      currentAddress: studentResult['current_address'] ?? "N/A",
      previousSchool: studentResult['previous_school'] ?? "N/A",
      guardianIs: studentResult['guardian_is'] ?? "N/A",
      parentId: studentResult['parent_id'] ?? "N/A",
      permanentAddress: studentResult['permanent_address'] ?? "N/A",
      categoryId: studentResult['category_id'] ?? "N/A",
      category: studentResult['category'] ?? "N/A",
      adharNo: studentResult['adhar_no'] ?? "N/A",
      samagraId: studentResult['samagra_id'] ?? "N/A",
      bankAccountNo: studentResult['bank_account_no'] ?? "N/A",
      bankName: studentResult['bank_name'] ?? "N/A",
      ifscCode: studentResult['ifsc_code'] ?? "N/A",
      guardianName: studentResult['guardian_name'] ?? "N/A",
      fatherPic: studentResult['father_pic'] ?? "N/A",
      height: studentResult['height'] ?? "N/A",
      weight: studentResult['weight'] ?? "N/A",
      measurementDate: studentResult['measurement_date'] ?? "N/A",
      motherPic: studentResult['mother_pic'] ?? "N/A",
      guardianPic: studentResult['guardian_pic'] ?? "N/A",
      guardianRelation: studentResult['guardian_relation'] ?? "N/A",
      guardianPhone: studentResult['guardian_phone'] ?? "N/A",
      guardianAddress: studentResult['guardian_address'] ?? "N/A",
      isActive: studentResult['is_active'] ?? "N/A",
      createdAt: studentResult['created_at'] ?? "N/A",
      updatedAt: studentResult['updated_at'] ?? "N/A",
      fatherName: studentResult['father_name'] ?? "N/A",
      fatherPhone: studentResult['father_phone'] ?? "N/A",
      bloodGroup: studentResult['blood_group'] ?? "N/A",
      schoolHouseId: studentResult['school_house_id'] ?? "N/A",
      fatherOccupation: studentResult['father_occupation'] ?? "N/A",
      motherName: studentResult['mother_name'] ?? "N/A",
      motherPhone: studentResult['mother_phone'] ?? "N/A",
      motherOccupation: studentResult['mother_occupation'] ?? "N/A",
      guardianOccupation: studentResult['guardian_occupation'] ?? "N/A",
      gender: studentResult['gender'] ?? "N/A",
      rte: studentResult['rte'] ?? "N/A",
      guardianEmail: studentResult['guardian_email'] ?? "N/A",
      username: studentResult['username'] ?? "N/A",
      password: studentResult['password'] ?? "N/A",
      disReason: studentResult['dis_reason'] ?? "N/A",
      disNote: studentResult['dis_note'] ?? "N/A",
      disableAt: studentResult['disable_at'] ?? "N/A",
      currencyName: studentResult['currency_name'] ?? "N/A",
      symbol: studentResult['symbol'] ?? "N/A",
      basePrice: studentResult['base_price'] ?? "N/A",
      currencyId: studentResult['currency_id'] ?? "N/A",
      sessionId: studentResult['session_id'] ?? "N/A",
      session: studentResult['session'] ?? "N/A",
    );
  }
}
