class FeesData {
  int payMethod;
  List<StudentDueFee> studentDueFee;
  GrandFee grandFee;

  FeesData({required this.payMethod, required this.studentDueFee, required this.grandFee});

  factory FeesData.fromJson(Map<String, dynamic> json) => FeesData(
        payMethod: json['pay_method'],
        studentDueFee: List<StudentDueFee>.from(json['student_due_fee'].map((x) => StudentDueFee.fromJson(x))),
        grandFee: GrandFee.fromJson(json['grand_fee']),
      );
}

class StudentDueFee {
  String id;
  bool isSystem;
  String studentSessionId;
  String feeSessionGroupId;
  String amount;
  bool isActive;
  String createdAt;
  String name;
  List<Fee> fees;

  StudentDueFee({
    required this.id,
    required this.isSystem,
    required this.studentSessionId,
    required this.feeSessionGroupId,
    required this.amount,
    required this.isActive,
    required this.createdAt,
    required this.name,
    required this.fees,
  });

  factory StudentDueFee.fromJson(Map<String, dynamic> json) => StudentDueFee(
        id: json['id'],
        isSystem: json['is_system'] == "1",
        studentSessionId: json['student_session_id'],
        feeSessionGroupId: json['fee_session_group_id'],
        amount: json['amount'],
        isActive: json['is_active'] == "no",
        createdAt: json['created_at'],
        name: json['name'],
        fees: List<Fee>.from(json['fees'].map((x) => Fee.fromJson(x))),
      );
}

class Fee {
  String id;
  bool isSystem;
  String studentSessionId;
  String feeSessionGroupId;
  String amount;
  bool isActive;
  String createdAt;
  String feeGroupsFeetypeId;
  String fineAmount;
  String dueDate;
  String feeGroupsId;
  String name;
  String feetypeId;
  String code;
  String type;
  String studentFeesDepositeId;
  String amountDetail;
  int totalAmountPaid;
  int totalAmountDiscount;
  int totalAmountFine;
  String totalAmountDisplay;
  String totalAmountRemaining;
  String status;
  int feesFineAmount;

  Fee({
    required this.id,
    required this.isSystem,
    required this.studentSessionId,
    required this.feeSessionGroupId,
    required this.amount,
    required this.isActive,
    required this.createdAt,
    required this.feeGroupsFeetypeId,
    required this.fineAmount,
    required this.dueDate,
    required this.feeGroupsId,
    required this.name,
    required this.feetypeId,
    required this.code,
    required this.type,
    required this.studentFeesDepositeId,
    required this.amountDetail,
    required this.totalAmountPaid,
    required this.totalAmountDiscount,
    required this.totalAmountFine,
    required this.totalAmountDisplay,
    required this.totalAmountRemaining,
    required this.status,
    required this.feesFineAmount,
  });

  factory Fee.fromJson(Map<String, dynamic> json) => Fee(
        id: json['id'],
        isSystem: json['is_system'] == "1",
        studentSessionId: json['student_session_id'],
        feeSessionGroupId: json['fee_session_group_id'],
        amount: json['amount'],
        isActive: json['is_active'] == "no",
        createdAt: json['created_at'],
        feeGroupsFeetypeId: json['fee_groups_feetype_id'],
        fineAmount: json['fine_amount'],
        dueDate: json['due_date'],
        feeGroupsId: json['fee_groups_id'],
        name: json['name'],
        feetypeId: json['feetype_id'],
        code: json['code'],
        type: json['type'],
        studentFeesDepositeId: json['student_fees_deposite_id'],
        amountDetail: json['amount_detail'],
        totalAmountPaid: int.tryParse(json['total_amount_paid'].toString()) ?? 0,
        totalAmountDiscount: int.tryParse(json['total_amount_discount'].toString()) ?? 0,
        totalAmountFine: int.tryParse(json['total_amount_fine'].toString()) ?? 0,
        totalAmountDisplay: json['total_amount_display'],
        totalAmountRemaining: json['total_amount_remaining'],
        status: json['status'],
        feesFineAmount: int.tryParse(json['fees_fine_amount'].toString()) ?? 0,
  );
}

class GrandFee {
  String amount;
  int amountDiscount;
  int amountFine;
  int amountPaid;
  String amountRemaining;
  int feeFine;

  GrandFee({
    required this.amount,
    required this.amountDiscount,
    required this.amountFine,
    required this.amountPaid,
    required this.amountRemaining,
    required this.feeFine,
  });

  factory GrandFee.fromJson(Map<String, dynamic> json) => GrandFee(
        amount: json['amount'].toString(),
        amountDiscount: int.tryParse(json['amount_discount'].toString()) ?? 0,
        amountFine: int.tryParse(json['amount_fine'].toString()) ?? 0,
        amountPaid: int.tryParse(json['amount_paid'].toString()) ?? 0,
        amountRemaining: json['amount_remaining'].toString(),
        feeFine: int.tryParse(json['fee_fine'].toString()) ?? 0,
  );
}
