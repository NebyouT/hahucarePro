import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kivicare_clinic_admin/components/app_scaffold.dart';
import 'package:kivicare_clinic_admin/components/loader_widget.dart';
import 'package:kivicare_clinic_admin/main.dart';
import 'package:kivicare_clinic_admin/utils/colors.dart';
import 'package:kivicare_clinic_admin/utils/common_base.dart';
import 'package:kivicare_clinic_admin/utils/empty_error_state_widget.dart';
import 'package:kivicare_clinic_admin/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_clinic_admin/api/core_apis.dart';
import 'package:kivicare_clinic_admin/screens/Encounter/model/encounter_lab_order_model.dart';
import 'package:kivicare_clinic_admin/screens/Encounter/model/encounters_list_model.dart';
import 'package:kivicare_clinic_admin/utils/app_common.dart';
import 'package:kivicare_clinic_admin/screens/lab/model/lab_order_model.dart';
import 'package:kivicare_clinic_admin/utils/api_end_points.dart';
import 'package:kivicare_clinic_admin/network/network_utils.dart';

class EncounterLabScreen extends StatelessWidget {
  const EncounterLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final encounterData = Get.arguments as EncounterElement;
    final controller = Get.put(_EncounterLabController(encounterData));
    controller.loadOrders();

    return GetBuilder<_EncounterLabController>(
      builder: (c) => AppScaffoldNew(
        appBartitleText: "Lab Orders",
        hasLeadingWidget: true,
        isLoading: c.isLoading,
        appBarVerticalSize: Get.height * 0.12,
        actions: [
          IconButton(
            onPressed: () => _showCreateSheet(context, c, encounterData),
            icon: const Icon(Icons.add_circle_outline, color: white),
          ).visible(c.showCreateBtn),
        ],
        body: Obx(() {
          if (c.isLoading.value && c.orders.isEmpty) return const LoaderWidget();
          if (c.errorMsg.value.isNotEmpty) {
            return NoDataWidget(
              title: c.errorMsg.value,
              imageWidget: const ErrorStateWidget(),
              onRetry: () => c.loadOrders(),
              retryText: locale.value.reload,
            ).center();
          }
          if (c.orders.isEmpty) {
            return NoDataWidget(
              title: "No lab orders",
              imageWidget: const EmptyStateWidget(),
              onRetry: () => c.loadOrders(),
              retryText: locale.value.reload,
            ).center();
          }
          return AnimatedListView(
            itemCount: c.orders.length,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemBuilder: (_, i) => _LabOrderCard(order: c.orders[i]),
          );
        }),
      ),
    );
  }

  void _showCreateSheet(BuildContext context, _EncounterLabController c, EncounterElement encounterData) {
    final formKey = GlobalKey<FormState>();
    int? selectedLabId;
    List<int> selectedServices = [];
    final notesCont = TextEditingController();

    List<LabData> labs = [];
    List<LabServiceData> services = [];
    bool labsLoaded = false;
    bool servicesLoading = false;

    Future<void> loadLabs() async {
      try {
        final res = LabSimpleListRes.fromJson(
          await handleResponse(await buildHttpResponse("${APIEndPoints.labGetLabsByClinic}/${encounterData.clinicId}")),
        );
        labs = res.data.map((e) => LabData.fromJson(e as Map<String, dynamic>)).toList();
        labsLoaded = true;
      } catch (e) {
        log("loadLabs err: $e");
      }
    }

    Future<void> loadServices(int labId) async {
      servicesLoading = true;
      try {
        final res = LabSimpleListRes.fromJson(
          await handleResponse(await buildHttpResponse("${APIEndPoints.labGetServicesByLab}/$labId")),
        );
        services = res.data.map((e) => LabServiceData.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        log("loadServices err: $e");
      } finally {
        servicesLoading = false;
      }
    }

    loadLabs();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
              height: MediaQuery.of(ctx).size.height * 0.7,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(child: Container(width: 40, height: 4, decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(2), color: Colors.grey[300]))),
                      16.height,
                      Text("Create Lab Order", style: boldTextStyle(size: 18)),
                      16.height,
                      Text("Patient: ${encounterData.userName}", style: primaryTextStyle(size: 13)),
                      12.height,
                      DropdownButtonFormField<int>(
                        initialValue: selectedLabId,
                        decoration: inputDecoration(context, labelText: "Select Lab"),
                        hint: Text(labsLoaded && labs.isEmpty ? "No labs available" : "Choose lab"),
                        items: labs.map((lab) => DropdownMenuItem(value: lab.id, child: Text(lab.name))).toList(),
                        onChanged: (v) {
                          setSheetState(() {
                            selectedLabId = v;
                            services = [];
                            selectedServices.clear();
                          });
                          if (v != null) {
                            loadServices(v).then((_) => setSheetState(() {}));
                          }
                        },
                        validator: (v) => v == null ? "Required" : null,
                      ),
                      12.height,
                      if (selectedLabId != null)
                        servicesLoading
                            ? const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2)))
                            : services.isEmpty
                                ? Text("No services available", style: secondaryTextStyle(size: 12, color: Colors.grey))
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Select Services", style: boldTextStyle(size: 13)),
                                      8.height,
                                      ...services.map((svc) {
                                        final sel = selectedServices.contains(svc.id);
                                        return CheckboxListTile(
                                          title: Text(svc.name, style: primaryTextStyle(size: 13)),
                                          subtitle: Text("\$${svc.price}", style: secondaryTextStyle(size: 11)),
                                          value: sel,
                                          contentPadding: EdgeInsets.zero,
                                          controlAffinity: ListTileControlAffinity.leading,
                                          onChanged: (v) {
                                            setSheetState(() {
                                              if (v == true) {
                                                selectedServices.add(svc.id);
                                              } else {
                                                selectedServices.remove(svc.id);
                                              }
                                            });
                                          },
                                        );
                                      }),
                                      if (selectedServices.isEmpty && services.isNotEmpty)
                                        Text("Select at least one service", style: secondaryTextStyle(size: 11, color: Colors.red)),
                                    ],
                                  ),
                      12.height,
                      AppTextField(
                        controller: notesCont,
                        textFieldType: TextFieldType.MULTILINE,
                        maxLines: 3,
                        decoration: inputDecoration(context, labelText: "Clinical Notes", hintText: "Optional notes"),
                      ),
                      16.height,
                      SizedBox(
                        width: Get.width,
                        child: AppButton(
                          textStyle: boldTextStyle(color: Colors.white),
                          text: "Submit Order",
                          color: appColorPrimary,
                          onTap: () async {
                            if (!(formKey.currentState?.validate() ?? false)) return;
                            if (selectedServices.isEmpty) { toast("Select at least one service"); return; }
                            try {
                              await CoreServiceApis.createEncounterLabOrder(
                                encounterId: encounterData.id,
                                clinicId: encounterData.clinicId,
                                labId: selectedLabId!,
                                patientId: encounterData.userId,
                                doctorId: encounterData.doctorId,
                                notes: notesCont.text.trim(),
                                services: selectedServices,
                              );
                              toast("Lab order created");
                              if (ctx.mounted) Navigator.pop(ctx);
                              c.loadOrders();
                            } catch (e) { toast("Error: $e"); }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _EncounterLabController extends GetxController {
  final EncounterElement _data;
  _EncounterLabController(this._data);

  RxBool isLoading = false.obs;
  RxList<EncounterLabOrder> orders = RxList();
  RxString errorMsg = ''.obs;
  bool get showCreateBtn => !loginUserData.value.userRole.contains(EmployeeKeyConst.receptionist);

  Future<void> loadOrders() async {
    isLoading(true);
    errorMsg('');
    try {
      orders(await CoreServiceApis.getEncounterLabOrders(_data.id));
    } catch (e) {
      log("loadOrders err: $e");
      errorMsg(e.toString());
    } finally {
      isLoading(false);
    }
  }
}

Future<void> downloadLabResultFile(String url, String fileName) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
      toast("Downloaded: $fileName");
      // Try to open the downloaded file
      final fileUri = Uri.file(file.path);
      if (await canLaunchUrl(fileUri)) {
        await launchUrl(fileUri, mode: LaunchMode.externalApplication);
      }
    } else {
      toast("Download failed (${response.statusCode})");
    }
  } catch (e) {
    toast("Download error: $e");
  }
}

class _LabOrderCard extends StatelessWidget {
  final EncounterLabOrder order;
  const _LabOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final hasResults = order.labOrderItems.any((i) => i.status == 'completed' && i.resultFile != null);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(12), color: context.cardColor),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text("#${order.orderNumber}", style: boldTextStyle(size: 13, color: appColorPrimary), overflow: TextOverflow.ellipsis, maxLines: 1),
              ),
              const Spacer(),
              _statusBadge(order.status),
            ],
          ),
          if ((order.labName ?? '').isNotEmpty) ...[4.height, Text(order.labName ?? '', style: secondaryTextStyle(size: 12))],
          4.height,
          Text(order.orderDate.isNotEmpty ? order.orderDate.splitBefore(' ') : "", style: secondaryTextStyle(size: 11)),
          if (order.labOrderItems.isNotEmpty) ...[
            8.height,
            Divider(height: 1),
            8.height,
            ...order.labOrderItems.map((item) => _buildItemRow(item)),
          ],
          if (hasResults) ...[8.height, Divider(height: 1), 8.height, Text("Results", style: boldTextStyle(size: 12))],
          if (hasResults)
            ...order.labOrderItems
                .where((i) => i.status == 'completed' && i.resultFile != null)
                .map((item) => _resultFileRow(item)),
          if (order.notes.isNotEmpty) ...[8.height, Text(order.notes, style: secondaryTextStyle(size: 11, color: Colors.grey[600]))],
        ],
      ),
    );
  }

  Widget _buildItemRow(EncounterLabOrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.science, size: 14, color: appColorPrimary),
          6.width,
          Expanded(child: Text(item.serviceName, style: primaryTextStyle(size: 12))),
          Text(item.status.replaceAll('_', ' '), style: secondaryTextStyle(size: 10, color: item.status == 'completed' ? Colors.green : Colors.grey)),
        ],
      ),
    );
  }

  Widget _resultFileRow(EncounterLabOrderItem item) {
    final fileName = item.resultFile!.split('/').last;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file, size: 16, color: Colors.green),
          8.width,
          Expanded(
            child: Text(fileName, style: primaryTextStyle(size: 11), overflow: TextOverflow.ellipsis),
          ),
          GestureDetector(
            onTap: () => viewFiles(item.resultFile!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: boxDecorationDefault(color: appColorPrimary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
              child: Text("View", style: boldTextStyle(size: 10, color: appColorPrimary)),
            ),
          ),
          6.width,
          GestureDetector(
            onTap: () => downloadLabResultFile(item.resultFile!, fileName),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: boxDecorationDefault(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
              child: Text("Download", style: boldTextStyle(size: 10, color: Colors.green)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = status == 'completed' ? Colors.green : (status == 'in_progress' ? Colors.orange : Colors.grey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: boxDecorationDefault(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(status.replaceAll('_', ' '), style: boldTextStyle(size: 10, color: color)),
    );
  }
}
