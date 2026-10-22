import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import '../../network/network_utils.dart';
import '../../utils/api_end_points.dart';
import '../../utils/app_common.dart';
import 'model/lab_order_model.dart';

class LabController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isOrderLoading = false.obs;
  Rx<Future<RxList<LabOrderData>>> labOrdersFuture = Future(() => RxList<LabOrderData>()).obs;
  RxList<LabOrderData> labOrders = RxList();

  RxList<LabClinic> clinics = RxList();
  RxList<LabData> labs = RxList();
  RxList<LabCategoryData> categories = RxList();
  RxList<LabServiceData> services = RxList();
  RxList<LabDoctorData> doctors = RxList();
  RxList<LabPatientData> patients = RxList();

  RxBool isWorklistLoading = false.obs;
  Rx<Future<RxList<LabOrderData>>> worklistFuture = Future(() => RxList<LabOrderData>()).obs;
  RxList<LabOrderData> worklist = RxList();
  RxString worklistStatusFilter = ''.obs;

  @override
  void onInit() async {
    await Future.wait([getLabOrders(), getWorklist(showLoader: false)]);
    super.onInit();
  }

  Future<void> getLabOrders({bool showLoader = true, String? status}) async {
    if (showLoader) isLoading(true);
    try {
      labOrdersFuture(Future(() async {
        final res = LabOrderListRes.fromJson(
          await handleResponse(
            await buildHttpResponse(
              APIEndPoints.labGetOrders + (status != null ? "?status=$status" : ""),
            ),
          ),
        );
        labOrders(res.data);
        return labOrders;
      }));
    } catch (e) {
      log('Error fetching lab orders: $e');
    } finally {
      if (showLoader) isLoading(false);
    }
  }

  Future<void> getWorklist({bool showLoader = true, String? status, String? search, String? dateFrom, String? dateTo}) async {
    if (showLoader) isWorklistLoading(true);
    worklistStatusFilter(status ?? '');
    try {
      worklistFuture(Future(() async {
        final params = <String>[];
        if (status != null && status.isNotEmpty) params.add("status=$status");
        if (search != null && search.isNotEmpty) params.add("search=${Uri.encodeQueryComponent(search)}");
        if (dateFrom != null && dateFrom.isNotEmpty) params.add("date_from=$dateFrom");
        if (dateTo != null && dateTo.isNotEmpty) params.add("date_to=$dateTo");
        String url = APIEndPoints.labWorklist;
        if (params.isNotEmpty) url += "?${params.join('&')}";
        final res = LabOrderListRes.fromJson(
          await handleResponse(await buildHttpResponse(url)),
        );
        worklist(res.data);
        return worklist;
      }));
    } catch (e) {
      log('Error fetching worklist: $e');
    } finally {
      if (showLoader) isWorklistLoading(false);
    }
  }

  Future<LabCreateOrderResp> uploadResult({
    required int orderId,
    required List<String> filePaths,
    String? technicianNote,
  }) async {
    if (!isLoggedIn.value) throw 'Not authenticated';

    final multiPartRequest = await getMultiPartRequest(
      '${APIEndPoints.labUploadResult}/$orderId',
    );

    for (int i = 0; i < filePaths.length; i++) {
      multiPartRequest.files.add(
        await http.MultipartFile.fromPath('result_files[$i]', filePaths[i]),
      );
    }

    if (technicianNote != null && technicianNote.isNotEmpty) {
      multiPartRequest.fields['technician_note'] = technicianNote;
    }

    multiPartRequest.headers.addAll(buildHeaderTokens());

    Completer<LabCreateOrderResp> completer = Completer();

    await sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        final res = LabCreateOrderResp.fromJson(jsonDecode(data));
        if (res.status) {
          await getWorklist(showLoader: false, status: worklistStatusFilter.value);
        }
        completer.complete(res);
      },
      onError: (error) {
        completer.completeError(error);
      },
    );

    return completer.future;
  }

  Future<void> fetchClinics() async {
    try {
      final res = LabSimpleListRes.fromJson(
        await handleResponse(await buildHttpResponse(APIEndPoints.labGetClinics)),
      );
      clinics(res.data.map((e) => LabClinic.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      log('Error fetching clinics: $e');
    }
  }

  Future<void> fetchLabsByClinic(int clinicId) async {
    try {
      final res = LabSimpleListRes.fromJson(
        await handleResponse(await buildHttpResponse("${APIEndPoints.labGetLabsByClinic}/$clinicId")),
      );
      labs(res.data.map((e) => LabData.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      log('Error fetching labs: $e');
    }
  }

  Future<void> fetchCategoriesByLab(int labId) async {
    try {
      final res = LabSimpleListRes.fromJson(
        await handleResponse(await buildHttpResponse("${APIEndPoints.labGetCategoriesByLab}/$labId")),
      );
      categories(res.data.map((e) => LabCategoryData.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      log('Error fetching categories: $e');
    }
  }

  Future<void> fetchServicesByLab(int labId) async {
    try {
      final res = LabSimpleListRes.fromJson(
        await handleResponse(await buildHttpResponse("${APIEndPoints.labGetServicesByLab}/$labId")),
      );
      services(res.data.map((e) => LabServiceData.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      log('Error fetching services: $e');
    }
  }

  Future<void> fetchServicesByCategory(int categoryId) async {
    try {
      final res = LabSimpleListRes.fromJson(
        await handleResponse(await buildHttpResponse("${APIEndPoints.labGetServicesByCategory}/$categoryId")),
      );
      services(res.data.map((e) => LabServiceData.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      log('Error fetching services: $e');
    }
  }

  Future<void> fetchDoctorsByClinic(int clinicId) async {
    try {
      final res = LabSimpleListRes.fromJson(
        await handleResponse(await buildHttpResponse("${APIEndPoints.labGetDoctorsByClinic}/$clinicId")),
      );
      doctors(res.data.map((e) => LabDoctorData.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      log('Error fetching doctors: $e');
    }
  }

  Future<void> fetchPatients() async {
    try {
      final res = LabSimpleListRes.fromJson(
        await handleResponse(await buildHttpResponse(APIEndPoints.labGetPatients)),
      );
      patients(res.data.map((e) => LabPatientData.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      log('Error fetching patients: $e');
    }
  }

  // ─── Lab Service Management ───────────────────────────────────────────

  RxBool isServicesLoading = false.obs;
  Rx<Future<RxList<LabServiceItem>>> servicesFuture = Future(() => RxList<LabServiceItem>()).obs;
  RxList<LabServiceItem> labServiceItems = RxList();
  RxList<LabCategoryItem> labCategories = RxList();

  Future<void> fetchServices() async {
    isServicesLoading(true);
    try {
      servicesFuture(Future(() async {
        final res = LabServiceListRes.fromJson(
          await handleResponse(await buildHttpResponse(APIEndPoints.labServices)),
        );
        labServiceItems(res.data);
        return labServiceItems;
      }));
    } catch (e) {
      log('Error fetching services: $e');
    } finally {
      isServicesLoading(false);
    }
  }

  Future<void> fetchCategories() async {
    try {
      final res = LabCategoryListRes.fromJson(
        await handleResponse(await buildHttpResponse(APIEndPoints.labCategories)),
      );
      labCategories(res.data);
    } catch (e) {
      log('Error fetching categories: $e');
    }
  }

  Future<void> createService({
    required String name,
    String? description,
    required String price,
    required int categoryId,
    int? labId,
    bool isActive = true,
  }) async {
    try {
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.labServices,
          method: HttpMethodType.POST,
          request: {
            'name': name,
            'description': description ?? "",
            'price': price,
            'category_id': categoryId,
            if (labId != null) 'lab_id': labId,
            'is_active': isActive,
          },
        ),
      );
      await fetchServices();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateService({
    required int id,
    required String name,
    String? description,
    required String price,
    required int categoryId,
    bool isActive = true,
  }) async {
    try {
      await handleResponse(
        await buildHttpResponse(
          '${APIEndPoints.labServices}/$id',
          method: HttpMethodType.POST,
          request: {
            'name': name,
            'description': description ?? "",
            'price': price,
            'category_id': categoryId,
            'is_active': isActive,
          },
        ),
      );
      await fetchServices();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteService(int id) async {
    try {
      await handleResponse(
        await buildHttpResponse(
          '${APIEndPoints.labServices}/$id',
          method: HttpMethodType.DELETE,
        ),
      );
      await fetchServices();
    } catch (e) {
      rethrow;
    }
  }

  // ─── Lab Category Management ────────────────────────────────────────

  RxBool isCategoryLoading = false.obs;

  Future<void> createCategory({
    required String name,
    String? description,
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    isCategoryLoading(true);
    try {
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.labCategories,
          method: HttpMethodType.POST,
          request: {
            'name': name,
            'description': description ?? "",
            'sort_order': sortOrder,
            'is_active': isActive,
          },
        ),
      );
      await fetchCategories();
    } catch (e) {
      rethrow;
    } finally {
      isCategoryLoading(false);
    }
  }

  Future<void> updateCategory({
    required int id,
    required String name,
    String? description,
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    isCategoryLoading(true);
    try {
      await handleResponse(
        await buildHttpResponse(
          '${APIEndPoints.labCategories}/$id',
          method: HttpMethodType.POST,
          request: {
            'name': name,
            'description': description ?? "",
            'sort_order': sortOrder,
            'is_active': isActive,
          },
        ),
      );
      await fetchCategories();
    } catch (e) {
      rethrow;
    } finally {
      isCategoryLoading(false);
    }
  }

  Future<void> deleteCategory(int id) async {
    isCategoryLoading(true);
    try {
      await handleResponse(
        await buildHttpResponse(
          '${APIEndPoints.labCategories}/$id',
          method: HttpMethodType.DELETE,
        ),
      );
      await fetchCategories();
    } catch (e) {
      rethrow;
    } finally {
      isCategoryLoading(false);
    }
  }

  Future<LabCreateOrderResp> createLabOrder({
    required int clinicId,
    required int labId,
    required int patientId,
    required int doctorId,
    required String orderType,
    required String priority,
    String? notes,
    required List<int> serviceIds,
  }) async {
    isOrderLoading(true);
    try {
      final res = LabCreateOrderResp.fromJson(
        await handleResponse(
          await buildHttpResponse(
            APIEndPoints.labCreateOrder,
            method: HttpMethodType.POST,
            request: {
              'clinic_id': clinicId,
              'lab_id': labId,
              'patient_id': patientId,
              'doctor_id': doctorId,
              'order_type': orderType,
              'priority': priority,
              'notes': notes ?? "",
              'services': serviceIds,
            },
          ),
        ),
      );
      return res;
    } catch (e) {
      rethrow;
    } finally {
      isOrderLoading(false);
    }
  }
}
