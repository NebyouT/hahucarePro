import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_clinic_admin/components/app_scaffold.dart';
import 'package:kivicare_clinic_admin/components/loader_widget.dart';
import 'package:kivicare_clinic_admin/main.dart';
import 'package:kivicare_clinic_admin/utils/colors.dart';
import 'package:kivicare_clinic_admin/utils/common_base.dart';
import 'package:kivicare_clinic_admin/utils/empty_error_state_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_clinic_admin/api/core_apis.dart';
import 'package:kivicare_clinic_admin/screens/Encounter/model/encounter_lab_order_model.dart';
import 'package:kivicare_clinic_admin/screens/Encounter/model/encounters_list_model.dart';
import '../../../generated/assets.dart';

class EncounterCertificateScreen extends StatelessWidget {
  const EncounterCertificateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final encounterData = Get.arguments as EncounterElement;
    final controller = Get.put(_CertificateController(encounterData));
    controller.loadCertificates();

    return GetBuilder<_CertificateController>(
      builder: (c) => AppScaffoldNew(
        appBartitleText: "Medical Certificates",
        hasLeadingWidget: true,
        isLoading: c.isLoading,
        appBarVerticalSize: Get.height * 0.12,
        actions: [
          IconButton(
            onPressed: () => _showCreateSheet(context, c, encounterData),
            icon: const Icon(Icons.add_circle_outline, color: white),
          ),
        ],
        body: Obx(() {
          if (c.isLoading.value && c.certificates.isEmpty) return const LoaderWidget();
          if (c.errorMsg.value.isNotEmpty) {
            return NoDataWidget(
              title: c.errorMsg.value,
              imageWidget: const ErrorStateWidget(),
              onRetry: () => c.loadCertificates(),
              retryText: locale.value.reload,
            ).center();
          }
          if (c.certificates.isEmpty) {
            return NoDataWidget(
              title: "No medical certificates",
              imageWidget: const EmptyStateWidget(),
              onRetry: () => c.loadCertificates(),
              retryText: locale.value.reload,
            ).center();
          }
          return AnimatedListView(
            itemCount: c.certificates.length,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemBuilder: (_, i) => _CertCard(
              cert: c.certificates[i],
              onDownload: () => c.downloadCert(c.certificates[i].id),
            ),
          );
        }),
      ),
    );
  }

  void _showCreateSheet(BuildContext context, _CertificateController c, EncounterElement encounterData) {
    final formKey = GlobalKey<FormState>();
    final reasonCont = TextEditingController();
    final diagnosisCont = TextEditingController();
    final recommendationsCont = TextEditingController();
    final notesCont = TextEditingController();

    String selectedType = 'medical_leave';
    final issueDateCont = TextEditingController(text: DateTime.now().toIso8601String().splitBefore('T'));
    final startDateCont = TextEditingController(text: DateTime.now().toIso8601String().splitBefore('T'));
    final endDateCont = TextEditingController(text: DateTime.now().add(const Duration(days: 7)).toIso8601String().splitBefore('T'));
    final totalDaysCont = TextEditingController(text: "7");

    String computeTotalDays() {
      final start = DateTime.tryParse(startDateCont.text.trim());
      final end = DateTime.tryParse(endDateCont.text.trim());
      if (start == null || end == null || end.isBefore(start)) return "0";
      return (end.difference(start).inDays + 1).toString();
    }

    void refreshTotalDays() => totalDaysCont.text = computeTotalDays();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
              height: MediaQuery.of(ctx).size.height * 0.75,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(child: Container(width: 40, height: 4, decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(2), color: Colors.grey[300]))),
                      16.height,
                      Text("Create Medical Certificate", style: boldTextStyle(size: 18)),
                      16.height,
                      Text("Patient: ${encounterData.userName}", style: primaryTextStyle(size: 13)),
                      12.height,
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: inputDecoration(context, labelText: "Certificate Type"),
                        items: const [
                          DropdownMenuItem(value: 'medical_leave', child: Text("Medical Leave")),
                          DropdownMenuItem(value: 'fitness', child: Text("Fitness")),
                          DropdownMenuItem(value: 'recovery', child: Text("Recovery")),
                          DropdownMenuItem(value: 'other', child: Text("Other")),
                        ],
                        onChanged: (v) => setSheetState(() => selectedType = v!),
                      ),
                      12.height,
                      AppTextField(
                        controller: issueDateCont,
                        textFieldType: TextFieldType.NAME,
                        decoration: inputDecoration(context, labelText: "Issue Date", hintText: "Issue Date (YYYY-MM-DD)"),
                        validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                      ),
                      12.height,
                      AppTextField(
                        controller: startDateCont,
                        textFieldType: TextFieldType.NAME,
                        readOnly: true,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.tryParse(startDateCont.text.trim()) ?? DateTime.now(),
                            firstDate: DateTime(1970),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null) {
                            setSheetState(() {
                              startDateCont.text = picked.formatDateYYYYmmdd();
                              refreshTotalDays();
                            });
                          }
                        },
                        decoration: inputDecoration(
                          context,
                          labelText: "Start Date",
                          hintText: "Start Date (YYYY-MM-DD)",
                          fillColor: context.cardColor,
                          filled: true,
                          suffixIcon: commonLeadingWid(imgPath: Assets.iconsIcCalendar, color: iconColor, size: 10).paddingAll(16),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                      ),
                      12.height,
                      AppTextField(
                        controller: endDateCont,
                        textFieldType: TextFieldType.NAME,
                        readOnly: true,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.tryParse(endDateCont.text.trim()) ?? DateTime.now(),
                            firstDate: DateTime(1970),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null) {
                            setSheetState(() {
                              endDateCont.text = picked.formatDateYYYYmmdd();
                              refreshTotalDays();
                            });
                          }
                        },
                        decoration: inputDecoration(
                          context,
                          labelText: "End Date",
                          hintText: "End Date (YYYY-MM-DD)",
                          fillColor: context.cardColor,
                          filled: true,
                          suffixIcon: commonLeadingWid(imgPath: Assets.iconsIcCalendar, color: iconColor, size: 10).paddingAll(16),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                      ),
                      12.height,
                      AppTextField(
                        controller: totalDaysCont,
                        readOnly: true,
                        enabled: false,
                        textFieldType: TextFieldType.PHONE,
                        decoration: inputDecoration(
                          context,
                          labelText: "Total Days of Leave",
                          hintText: "Auto-calculated",
                          fillColor: context.cardColor,
                          filled: true,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Center(child: Text("Days", style: secondaryTextStyle(size: 13))),
                          ),
                        ),
                      ),
                      12.height,
                      AppTextField(
                        controller: diagnosisCont,
                        textFieldType: TextFieldType.MULTILINE,
                        maxLines: 2,
                        decoration: inputDecoration(context, labelText: "Diagnosis", hintText: "Optional diagnosis"),
                      ),
                      12.height,
                      AppTextField(
                        controller: reasonCont,
                        textFieldType: TextFieldType.MULTILINE,
                        maxLines: 2,
                        decoration: inputDecoration(context, labelText: "Reason", hintText: "Reason for certificate"),
                        validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                      ),
                      12.height,
                      AppTextField(
                        controller: recommendationsCont,
                        textFieldType: TextFieldType.MULTILINE,
                        maxLines: 2,
                        decoration: inputDecoration(context, labelText: "Recommendations", hintText: "Optional recommendations"),
                      ),
                      12.height,
                      AppTextField(
                        controller: notesCont,
                        textFieldType: TextFieldType.MULTILINE,
                        maxLines: 2,
                        decoration: inputDecoration(context, labelText: "Additional Notes", hintText: "Optional"),
                      ),
                      16.height,
                      SizedBox(
                        width: Get.width,
                        child: AppButton(
                          textStyle: boldTextStyle(color: Colors.white),
                          text: "Create Certificate",
                          color: appColorPrimary,
                          onTap: () async {
                            if (!(formKey.currentState?.validate() ?? false)) return;
                            try {
                              await CoreServiceApis.createMedicalCertificate(
                                patientId: encounterData.userId,
                                encounterId: encounterData.id,
                                clinicId: encounterData.clinicId,
                                certificateType: selectedType,
                                issueDate: issueDateCont.text.trim(),
                                startDate: startDateCont.text.trim(),
                                endDate: endDateCont.text.trim(),
                                diagnosis: diagnosisCont.text.trim().isEmpty ? null : diagnosisCont.text.trim(),
                                reason: reasonCont.text.trim(),
                                recommendations: recommendationsCont.text.trim().isEmpty ? null : recommendationsCont.text.trim(),
                                notes: notesCont.text.trim().isEmpty ? null : notesCont.text.trim(),
                              );
                              toast("Certificate created");
                              if (ctx.mounted) Navigator.pop(ctx);
                              c.loadCertificates();
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

class _CertificateController extends GetxController {
  final EncounterElement _data;
  _CertificateController(this._data);

  RxBool isLoading = false.obs;
  RxList<MedicalCertificateItem> certificates = RxList();
  RxString errorMsg = ''.obs;

  Future<void> loadCertificates() async {
    isLoading(true);
    errorMsg('');
    try {
      certificates(await CoreServiceApis.getMedicalCertificates(_data.id));
    } catch (e) {
      log("loadCerts err: $e");
      errorMsg(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> downloadCert(int id) async {
    try {
      final res = await CoreServiceApis.downloadMedicalCertificate(id);
      if (res.value.status && res.value.link.isNotEmpty) {
        viewFiles(res.value.link);
      } else {
        toast("Download failed");
      }
    } catch (e) { toast("Error: $e"); }
  }
}

class _CertCard extends StatelessWidget {
  final MedicalCertificateItem cert;
  final VoidCallback onDownload;
  const _CertCard({required this.cert, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(12), color: context.cardColor),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fact_check_outlined, size: 16, color: appColorPrimary),
              8.width,
              Expanded(child: Text(cert.certificateNumber, style: boldTextStyle(size: 13))),
              _typeBadge(cert.certificateType),
            ],
          ),
          6.height,
              Row(children: [
                _infoChip("${cert.durationDays} day(s)"),
                8.width,
                _infoChip(cert.status),
              ]),
          4.height,
          Text("${cert.startDate} → ${cert.endDate}", style: secondaryTextStyle(size: 11)),
          if (cert.reason.isNotEmpty) ...[4.height, Text(cert.reason, style: primaryTextStyle(size: 12), maxLines: 2, overflow: TextOverflow.ellipsis)],
          8.height,
          AppButton(
            text: "Download PDF",
            textStyle: boldTextStyle(size: 11, color: Colors.white),
            color: appColorPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: EdgeInsets.zero,
            shapeBorder: RoundedRectangleBorder(borderRadius: radius(6)),
            elevation: 0,
            onTap: onDownload,
          ),
        ],
      ),
    );
  }

  Widget _typeBadge(String type) {
    final label = type == 'medical_leave' ? 'Medical Leave' : (type == 'fitness' ? 'Fitness' : (type == 'recovery' ? 'Recovery' : type));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: boxDecorationDefault(color: appColorPrimary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: boldTextStyle(size: 9, color: appColorPrimary)),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: boxDecorationDefault(color: Colors.grey.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: boldTextStyle(size: 9, color: Colors.grey[700])),
    );
  }
}
