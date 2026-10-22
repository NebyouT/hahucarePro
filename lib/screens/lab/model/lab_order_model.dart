class LabOrderListRes {
  bool status;
  List<LabOrderData> data;
  String message;

  LabOrderListRes({
    this.status = false,
    this.data = const [],
    this.message = "",
  });

  factory LabOrderListRes.fromJson(Map<String, dynamic> json) {
    return LabOrderListRes(
      status: json['status'] is bool ? json['status'] : false,
      data: json['data'] is List
          ? List<LabOrderData>.from(json['data'].map((x) => LabOrderData.fromJson(x)))
          : [],
      message: json['message'] is String ? json['message'] : "",
    );
  }
}

class LabOrderData {
  int id;
  String orderNumber;
  String labName;
  int labId;
  String clinicName;
  String doctorName;
  String patientName;
  int patientId;
  int? encounterId;
  String orderDate;
  String orderType;
  String priority;
  String notes;
  String totalAmount;
  String discountAmount;
  String finalAmount;
  String status;
  String? completedDate;
  List<LabOrderItemData> items;
  String createdAt;
  String updatedAt;

  LabOrderData({
    this.id = 0,
    this.orderNumber = "",
    this.labName = "",
    this.labId = 0,
    this.clinicName = "",
    this.doctorName = "",
    this.patientName = "",
    this.patientId = 0,
    this.encounterId,
    this.orderDate = "",
    this.orderType = "",
    this.priority = "",
    this.notes = "",
    this.totalAmount = "0",
    this.discountAmount = "0",
    this.finalAmount = "0",
    this.status = "",
    this.completedDate,
    this.items = const [],
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory LabOrderData.fromJson(Map<String, dynamic> json) {
    return LabOrderData(
      id: json['id'] is int ? json['id'] : 0,
      orderNumber: json['order_number'] is String ? json['order_number'] : "",
      labName: json['lab_name'] is String ? json['lab_name'] : "",
      labId: json['lab_id'] is int ? json['lab_id'] : 0,
      clinicName: json['clinic_name'] is String ? json['clinic_name'] : "",
      doctorName: json['doctor_name'] is String ? json['doctor_name'] : "",
      patientName: json['patient_name'] is String ? json['patient_name'] : "",
      patientId: json['patient_id'] is int ? json['patient_id'] : 0,
      encounterId: json['encounter_id'] is int ? json['encounter_id'] : null,
      orderDate: json['order_date'] is String ? json['order_date'] : "",
      orderType: json['order_type'] is String ? json['order_type'] : "",
      priority: json['priority'] is String ? json['priority'] : "",
      notes: json['notes'] is String ? json['notes'] : "",
      totalAmount: json['total_amount']?.toString() ?? "0",
      discountAmount: json['discount_amount']?.toString() ?? "0",
      finalAmount: json['final_amount']?.toString() ?? "0",
      status: json['status'] is String ? json['status'] : "",
      completedDate: json['completed_date'] is String ? json['completed_date'] : null,
      items: json['items'] is List
          ? List<LabOrderItemData>.from(json['items'].map((x) => LabOrderItemData.fromJson(x)))
          : [],
      createdAt: json['created_at'] is String ? json['created_at'] : "",
      updatedAt: json['updated_at'] is String ? json['updated_at'] : "",
    );
  }
}

class LabResultFileUrl {
  String url;
  String name;

  LabResultFileUrl({this.url = "", this.name = ""});

  factory LabResultFileUrl.fromJson(Map<String, dynamic> json) {
    return LabResultFileUrl(
      url: json['url'] is String ? json['url'] : "",
      name: json['name'] is String ? json['name'] : "",
    );
  }
}

class LabOrderItemData {
  int id;
  int labOrderId;
  String serviceName;
  String serviceDescription;
  String price;
  String finalPrice;
  String status;
  bool urgentFlag;
  String? clinicalNotes;
  String? sampleType;
  bool fastingRequired;
  String? specialInstructions;
  String? resultFile;
  List<LabResultFileUrl> resultFileUrls;
  String? resultValue;
  String? resultNotes;
  String? technicianNote;
  String? resultUploadedAt;
  String createdAt;
  String updatedAt;

  LabOrderItemData({
    this.id = 0,
    this.labOrderId = 0,
    this.serviceName = "",
    this.serviceDescription = "",
    this.price = "0",
    this.finalPrice = "0",
    this.status = "",
    this.urgentFlag = false,
    this.clinicalNotes,
    this.sampleType,
    this.fastingRequired = false,
    this.specialInstructions,
    this.resultFile,
    this.resultFileUrls = const [],
    this.resultValue,
    this.resultNotes,
    this.technicianNote,
    this.resultUploadedAt,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory LabOrderItemData.fromJson(Map<String, dynamic> json) {
    return LabOrderItemData(
      id: json['id'] is int ? json['id'] : 0,
      labOrderId: json['lab_order_id'] is int ? json['lab_order_id'] : 0,
      serviceName: json['service_name'] is String ? json['service_name'] : "",
      serviceDescription: json['service_description'] is String ? json['service_description'] : "",
      price: json['price']?.toString() ?? "0",
      finalPrice: json['final_price']?.toString() ?? "0",
      status: json['status'] is String ? json['status'] : "",
      urgentFlag: json['urgent_flag'] == true,
      clinicalNotes: json['clinical_notes'] is String ? json['clinical_notes'] : null,
      sampleType: json['sample_type'] is String ? json['sample_type'] : null,
      fastingRequired: json['fasting_required'] == true,
      specialInstructions: json['special_instructions'] is String ? json['special_instructions'] : null,
      resultFile: json['result_file'] is String ? json['result_file'] : null,
      resultFileUrls: json['result_file_urls'] is List
          ? List<LabResultFileUrl>.from(json['result_file_urls'].map((x) => LabResultFileUrl.fromJson(x)))
          : [],
      resultValue: json['result_value'] is String ? json['result_value'] : null,
      resultNotes: json['result_notes'] is String ? json['result_notes'] : null,
      technicianNote: json['technician_note'] is String ? json['technician_note'] : null,
      resultUploadedAt: json['result_uploaded_at'] is String ? json['result_uploaded_at'] : null,
      createdAt: json['created_at'] is String ? json['created_at'] : "",
      updatedAt: json['updated_at'] is String ? json['updated_at'] : "",
    );
  }
}

class LabClinic {
  int id;
  String name;

  LabClinic({this.id = 0, this.name = ""});

  factory LabClinic.fromJson(Map<String, dynamic> json) {
    return LabClinic(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name'] is String ? json['name'] : "",
    );
  }
}

class LabData {
  int id;
  String name;

  LabData({this.id = 0, this.name = ""});

  factory LabData.fromJson(Map<String, dynamic> json) {
    return LabData(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name'] is String ? json['name'] : "",
    );
  }
}

class LabServiceData {
  int id;
  String name;
  String price;
  String? description;
  int? categoryId;

  LabServiceData({
    this.id = 0,
    this.name = "",
    this.price = "0",
    this.description,
    this.categoryId,
  });

  factory LabServiceData.fromJson(Map<String, dynamic> json) {
    return LabServiceData(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name'] is String ? json['name'] : "",
      price: json['price']?.toString() ?? "0",
      description: json['description'] is String ? json['description'] : null,
      categoryId: json['category_id'] is int ? json['category_id'] : null,
    );
  }
}

class LabCategoryData {
  int id;
  String name;
  String? description;

  LabCategoryData({this.id = 0, this.name = "", this.description});

  factory LabCategoryData.fromJson(Map<String, dynamic> json) {
    return LabCategoryData(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name'] is String ? json['name'] : "",
      description: json['description'] is String ? json['description'] : null,
    );
  }
}

class LabDoctorData {
  int id;
  String firstName;
  String lastName;

  LabDoctorData({this.id = 0, this.firstName = "", this.lastName = ""});

  String get fullName => "$firstName $lastName".trim();

  factory LabDoctorData.fromJson(Map<String, dynamic> json) {
    return LabDoctorData(
      id: json['id'] is int ? json['id'] : 0,
      firstName: json['first_name'] is String ? json['first_name'] : "",
      lastName: json['last_name'] is String ? json['last_name'] : "",
    );
  }
}

class LabPatientData {
  int id;
  String firstName;
  String lastName;
  String email;
  String? profileImage;
  String? contactNumber;

  LabPatientData({
    this.id = 0,
    this.firstName = "",
    this.lastName = "",
    this.email = "",
    this.profileImage,
    this.contactNumber,
  });

  String get fullName => "$firstName $lastName".trim();

  factory LabPatientData.fromJson(Map<String, dynamic> json) {
    return LabPatientData(
      id: json['id'] is int ? json['id'] : 0,
      firstName: json['first_name'] is String ? json['first_name'] : "",
      lastName: json['last_name'] is String ? json['last_name'] : "",
      email: json['email'] is String ? json['email'] : "",
      profileImage: json['profile_image'] is String ? json['profile_image'] : null,
      contactNumber: json['contact_number'] is String ? json['contact_number'] : null,
    );
  }
}

class LabCreateOrderResp {
  bool status;
  LabOrderData? data;
  String message;

  LabCreateOrderResp({this.status = false, this.data, this.message = ""});

  factory LabCreateOrderResp.fromJson(Map<String, dynamic> json) {
    return LabCreateOrderResp(
      status: json['status'] is bool ? json['status'] : false,
      data: json['data'] is Map ? LabOrderData.fromJson(json['data']) : null,
      message: json['message'] is String ? json['message'] : "",
    );
  }
}

class LabSimpleListRes {
  bool status;
  List<dynamic> data;
  String message;

  LabSimpleListRes({this.status = false, this.data = const [], this.message = ""});

  factory LabSimpleListRes.fromJson(Map<String, dynamic> json) {
    return LabSimpleListRes(
      status: json['status'] is bool ? json['status'] : false,
      data: json['data'] is List ? json['data'] : [],
      message: json['message'] is String ? json['message'] : "",
    );
  }
}

class LabServiceItem {
  int id;
  String name;
  String description;
  String price;
  int categoryId;
  int labId;
  bool isActive;
  int sortOrder;
  String createdAt;
  String updatedAt;
  Map<String, dynamic>? category;

  LabServiceItem({
    this.id = 0,
    this.name = "",
    this.description = "",
    this.price = "0",
    this.categoryId = 0,
    this.labId = 0,
    this.isActive = true,
    this.sortOrder = 0,
    this.createdAt = "",
    this.updatedAt = "",
    this.category,
  });

  String get categoryName => category != null ? (category!['name'] as String? ?? "") : "";

  factory LabServiceItem.fromJson(Map<String, dynamic> json) {
    return LabServiceItem(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name'] is String ? json['name'] : "",
      description: json['description'] is String ? json['description'] : "",
      price: json['price']?.toString() ?? "0",
      categoryId: json['category_id'] is int ? json['category_id'] : 0,
      labId: json['lab_id'] is int ? json['lab_id'] : 0,
      isActive: json['is_active'] == true,
      sortOrder: json['sort_order'] is int ? json['sort_order'] : 0,
      createdAt: json['created_at'] is String ? json['created_at'] : "",
      updatedAt: json['updated_at'] is String ? json['updated_at'] : "",
      category: json['category'] is Map ? json['category'] : null,
    );
  }
}

class LabServiceListRes {
  bool status;
  List<LabServiceItem> data;
  String message;

  LabServiceListRes({this.status = false, this.data = const [], this.message = ""});

  factory LabServiceListRes.fromJson(Map<String, dynamic> json) {
    return LabServiceListRes(
      status: json['status'] is bool ? json['status'] : false,
      data: json['data'] is List
          ? List<LabServiceItem>.from(json['data'].map((x) => LabServiceItem.fromJson(x)))
          : [],
      message: json['message'] is String ? json['message'] : "",
    );
  }
}

class LabCategoryItem {
  int id;
  String name;
  String description;
  bool isActive;
  int sortOrder;

  LabCategoryItem({
    this.id = 0,
    this.name = "",
    this.description = "",
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory LabCategoryItem.fromJson(Map<String, dynamic> json) {
    return LabCategoryItem(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name'] is String ? json['name'] : "",
      description: json['description'] is String ? json['description'] : "",
      isActive: json['is_active'] == true,
      sortOrder: json['sort_order'] is int ? json['sort_order'] : 0,
    );
  }
}

class LabCategoryListRes {
  bool status;
  List<LabCategoryItem> data;
  String message;

  LabCategoryListRes({this.status = false, this.data = const [], this.message = ""});

  factory LabCategoryListRes.fromJson(Map<String, dynamic> json) {
    return LabCategoryListRes(
      status: json['status'] is bool ? json['status'] : false,
      data: json['data'] is List
          ? List<LabCategoryItem>.from(json['data'].map((x) => LabCategoryItem.fromJson(x)))
          : [],
      message: json['message'] is String ? json['message'] : "",
    );
  }
}
