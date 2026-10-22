class EncounterLabOrderListRes {
  bool status;
  List<EncounterLabOrder> data;
  String message;

  EncounterLabOrderListRes({this.status = false, this.data = const [], this.message = ""});

  factory EncounterLabOrderListRes.fromJson(Map<String, dynamic> json) {
    return EncounterLabOrderListRes(
      status: json['status'] is bool ? json['status'] : false,
      data: json['data'] is List
          ? List<EncounterLabOrder>.from(json['data'].map((x) => EncounterLabOrder.fromJson(x)))
          : [],
      message: json['message'] is String ? json['message'] : "",
    );
  }
}

class EncounterLabOrder {
  int id;
  String orderNumber;
  String? labName;
  String status;
  String orderDate;
  String notes;
  List<EncounterLabOrderItem> labOrderItems;

  EncounterLabOrder({
    this.id = 0,
    this.orderNumber = "",
    this.labName,
    this.status = "",
    this.orderDate = "",
    this.notes = "",
    this.labOrderItems = const [],
  });

  factory EncounterLabOrder.fromJson(Map<String, dynamic> json) {
    return EncounterLabOrder(
      id: json['id'] is int ? json['id'] : 0,
      orderNumber: json['order_number'] is String ? json['order_number'] : "",
      labName: json['lab'] is Map ? (json['lab']['name'] as String? ?? "") : (json['lab_name'] is String ? json['lab_name'] : ""),
      status: json['status'] is String ? json['status'] : "",
      orderDate: json['order_date'] is String ? json['order_date'] : (json['created_at'] is String ? json['created_at'] : ""),
      notes: json['notes'] is String ? json['notes'] : "",
      labOrderItems: json['lab_order_items'] is List
          ? List<EncounterLabOrderItem>.from(json['lab_order_items'].map((x) => EncounterLabOrderItem.fromJson(x)))
          : (json['items'] is List
              ? List<EncounterLabOrderItem>.from((json['items'] as List).map((x) => EncounterLabOrderItem.fromJson(x is Map<String, dynamic> ? x : {})))
              : []),
    );
  }
}

class EncounterLabOrderItem {
  int id;
  String serviceName;
  String price;
  String status;
  String? resultFile;
  String? technicianNote;
  String? resultUploadedAt;

  EncounterLabOrderItem({
    this.id = 0,
    this.serviceName = "",
    this.price = "0",
    this.status = "",
    this.resultFile,
    this.technicianNote,
    this.resultUploadedAt,
  });

  factory EncounterLabOrderItem.fromJson(Map<String, dynamic> json) {
    return EncounterLabOrderItem(
      id: json['id'] is int ? json['id'] : 0,
      serviceName: json['service_name'] is String ? json['service_name'] : (json['test_name'] is String ? json['test_name'] : ""),
      price: json['price']?.toString() ?? "0",
      status: json['status'] is String ? json['status'] : "",
      resultFile: json['result_file'] is String ? json['result_file'] : null,
      technicianNote: json['technician_note'] is String ? json['technician_note'] : null,
      resultUploadedAt: json['result_uploaded_at'] is String ? json['result_uploaded_at'] : null,
    );
  }
}

class EncounterLabCreateResp {
  bool status;
  String message;

  EncounterLabCreateResp({this.status = false, this.message = ""});

  factory EncounterLabCreateResp.fromJson(Map<String, dynamic> json) {
    return EncounterLabCreateResp(
      status: json['status'] is bool ? json['status'] : false,
      message: json['message'] is String ? json['message'] : "",
    );
  }
}

class MedicalCertificateListRes {
  bool status;
  List<MedicalCertificateItem> data;
  String message;

  MedicalCertificateListRes({this.status = false, this.data = const [], this.message = ""});

  factory MedicalCertificateListRes.fromJson(Map<String, dynamic> json) {
    return MedicalCertificateListRes(
      status: json['status'] is bool ? json['status'] : false,
      data: json['data'] is List
          ? List<MedicalCertificateItem>.from(json['data'].map((x) => MedicalCertificateItem.fromJson(x)))
          : [],
      message: json['message'] is String ? json['message'] : "",
    );
  }
}

class MedicalCertificateItem {
  int id;
  String certificateNumber;
  String certificateType;
  String issueDate;
  String startDate;
  String endDate;
  int durationDays;
  String diagnosis;
  String reason;
  String? recommendations;
  String? notes;
  String status;
  bool isPrinted;
  String? printedAt;
  String createdAt;

  MedicalCertificateItem({
    this.id = 0,
    this.certificateNumber = "",
    this.certificateType = "",
    this.issueDate = "",
    this.startDate = "",
    this.endDate = "",
    this.durationDays = 0,
    this.diagnosis = "",
    this.reason = "",
    this.recommendations,
    this.notes,
    this.status = "issued",
    this.isPrinted = false,
    this.printedAt,
    this.createdAt = "",
  });

  factory MedicalCertificateItem.fromJson(Map<String, dynamic> json) {
    return MedicalCertificateItem(
      id: json['id'] is int ? json['id'] : 0,
      certificateNumber: json['certificate_number'] is String ? json['certificate_number'] : "",
      certificateType: json['certificate_type'] is String ? json['certificate_type'] : "",
      issueDate: json['issue_date'] is String ? json['issue_date'] : "",
      startDate: json['start_date'] is String ? json['start_date'] : "",
      endDate: json['end_date'] is String ? json['end_date'] : "",
      durationDays: json['duration_days'] is int ? json['duration_days'] : 0,
      diagnosis: json['diagnosis'] is String ? json['diagnosis'] : "",
      reason: json['reason'] is String ? json['reason'] : "",
      recommendations: json['recommendations'] is String ? json['recommendations'] : null,
      notes: json['notes'] is String ? json['notes'] : null,
      status: json['status'] is String ? json['status'] : "issued",
      isPrinted: json['is_printed'] == true,
      printedAt: json['printed_at'] is String ? json['printed_at'] : null,
      createdAt: json['created_at'] is String ? json['created_at'] : "",
    );
  }

  String get typeLabel {
    switch (certificateType) {
      case 'medical_leave': return 'Medical Leave';
      case 'fitness': return 'Fitness';
      case 'recovery': return 'Recovery';
      default: return certificateType;
    }
  }
}

class MedicalCertificateCreateResp {
  bool status;
  MedicalCertificateItem? data;
  String message;

  MedicalCertificateCreateResp({this.status = false, this.data, this.message = ""});

  factory MedicalCertificateCreateResp.fromJson(Map<String, dynamic> json) {
    return MedicalCertificateCreateResp(
      status: json['status'] is bool ? json['status'] : false,
      data: json['data'] is Map ? MedicalCertificateItem.fromJson(json['data']) : null,
      message: json['message'] is String ? json['message'] : "",
    );
  }
}

class EncounterReferralListRes {
  bool status;
  List<EncounterReferralItem> data;
  String message;

  EncounterReferralListRes({this.status = false, this.data = const [], this.message = ""});

  factory EncounterReferralListRes.fromJson(Map<String, dynamic> json) {
    return EncounterReferralListRes(
      status: json['status'] is bool ? json['status'] : false,
      data: json['data'] is List
          ? List<EncounterReferralItem>.from(json['data'].map((x) => EncounterReferralItem.fromJson(x)))
          : [],
      message: json['message'] is String ? json['message'] : "",
    );
  }
}

class EncounterReferralItem {
  int id;
  String? referredByDoctorName;
  String? referredToDoctorName;
  String reason;
  String? notes;
  String status;
  String referralDate;
  String referralCode;
  String createdAt;

  EncounterReferralItem({
    this.id = 0,
    this.referredByDoctorName,
    this.referredToDoctorName,
    this.reason = "",
    this.notes,
    this.status = "pending",
    this.referralDate = "",
    this.referralCode = "",
    this.createdAt = "",
  });

  factory EncounterReferralItem.fromJson(Map<String, dynamic> json) {
    return EncounterReferralItem(
      id: json['id'] is int ? json['id'] : 0,
      referredByDoctorName: json['referred_by_doctor'] is Map ? (json['referred_by_doctor']['full_name'] ?? json['referred_by_doctor']['first_name'])?.toString() ?? "" : (json['referred_by_name'] is String ? json['referred_by_name'] : ""),
      referredToDoctorName: json['referred_to_doctor'] is Map ? (json['referred_to_doctor']['full_name'] ?? json['referred_to_doctor']['first_name'])?.toString() ?? "" : (json['referred_to_name'] is String ? json['referred_to_name'] : ""),
      reason: json['reason'] is String ? json['reason'] : "",
      notes: json['notes'] is String ? json['notes'] : null,
      status: json['status'] is String ? json['status'] : "pending",
      referralDate: json['referral_date'] is String ? json['referral_date'] : "",
      referralCode: json['referral_code'] is String ? json['referral_code'] : "",
      createdAt: json['created_at'] is String ? json['created_at'] : "",
    );
  }
}

class EncounterReferralCreateResp {
  bool status;
  EncounterReferralItem? data;
  String message;

  EncounterReferralCreateResp({this.status = false, this.data, this.message = ""});

  factory EncounterReferralCreateResp.fromJson(Map<String, dynamic> json) {
    return EncounterReferralCreateResp(
      status: json['status'] is bool ? json['status'] : false,
      data: json['data'] is Map ? EncounterReferralItem.fromJson(json['data']) : null,
      message: json['message'] is String ? json['message'] : "",
    );
  }
}
