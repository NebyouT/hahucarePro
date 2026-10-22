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
import 'package:kivicare_clinic_admin/utils/api_end_points.dart';
import 'package:kivicare_clinic_admin/network/network_utils.dart';

class EncounterReferralScreen extends StatelessWidget {
  const EncounterReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final encounterData = Get.arguments as EncounterElement?;
    if (encounterData == null) {
      return AppScaffoldNew(
        appBartitleText: "Referrals",
        hasLeadingWidget: true,
        appBarVerticalSize: Get.height * 0.12,
        body: const Center(child: Text("No encounter data provided")),
      );
    }
    final controller = Get.put(_ReferralController(encounterData));
    controller.loadReferrals();

    return GetBuilder<_ReferralController>(
      builder: (c) => AppScaffoldNew(
        appBartitleText: "Referrals",
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
          if (c.isLoading.value && c.referrals.isEmpty) return const LoaderWidget();
          if (c.errorMsg.value.isNotEmpty) {
            return NoDataWidget(
              title: c.errorMsg.value,
              imageWidget: const ErrorStateWidget(),
              onRetry: () => c.loadReferrals(),
              retryText: locale.value.reload,
            ).center();
          }
          if (c.referrals.isEmpty) {
            return NoDataWidget(
              title: "No referrals",
              imageWidget: const EmptyStateWidget(),
              onRetry: () => c.loadReferrals(),
              retryText: locale.value.reload,
            ).center();
          }
          return AnimatedListView(
            itemCount: c.referrals.length,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemBuilder: (_, i) => _ReferralCard(referral: c.referrals[i]),
          );
        }),
      ),
    );
  }

  void _showCreateSheet(BuildContext context, _ReferralController c, EncounterElement encounterData) {
    final formKey = GlobalKey<FormState>();
    final reasonCont = TextEditingController();
    final notesCont = TextEditingController();

    RxList<DoctorOption> doctors = RxList();
    RxBool loadingDoctors = false.obs;
    int? selectedDoctorId;
    int? selectedClinicId;

    _loadDoctors(doctors, loadingDoctors);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(child: Container(width: 40, height: 4, decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(2), color: Colors.grey[300]))),
                      16.height,
                      Text("Create Referral", style: boldTextStyle(size: 18)),
                      16.height,
                      Text("Patient: ${encounterData.userName}", style: primaryTextStyle(size: 13)),
                      12.height,
                      Obx(() {
                        if (loadingDoctors.value) return const Center(child: CircularProgressIndicator());
                        return DropdownButtonFormField<int>(
                          initialValue: selectedDoctorId,
                          isExpanded: true,
                          decoration: inputDecoration(context, labelText: "Refer To Doctor"),
                          hint: const Text("Select doctor"),
                          items: doctors.map((d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(
                              d.clinicName.isNotEmpty ? "${d.name}  (${d.clinicName})" : d.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          )).toList(),
                          onChanged: (v) => setSheetState(() {
                            selectedDoctorId = v;
                            final match = doctors.firstWhereOrNull((d) => d.id == v);
                            selectedClinicId = match?.clinicId;
                          }),
                          validator: (v) => v == null ? "Required" : null,
                        );
                      }),
                      12.height,
                      AppTextField(
                        controller: reasonCont,
                        textFieldType: TextFieldType.MULTILINE,
                        maxLines: 3,
                        decoration: inputDecoration(context, labelText: "Reason for Referral", hintText: "Explain why you're referring"),
                        validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                      ),
                      12.height,
                      AppTextField(
                        controller: notesCont,
                        textFieldType: TextFieldType.MULTILINE,
                        maxLines: 3,
                        decoration: inputDecoration(context, labelText: "Additional Notes", hintText: "Optional"),
                      ),
                      16.height,
                      SizedBox(
                        width: Get.width,
                        child: AppButton(
                          textStyle: boldTextStyle(color: Colors.white),
                          text: "Create Referral",
                          color: appColorPrimary,
                          onTap: () async {
                            if (!(formKey.currentState?.validate() ?? false)) return;
                            try {
                              await CoreServiceApis.createEncounterReferral(
                                patientId: encounterData.userId,
                                referredTo: selectedDoctorId!,
                                referredToClinicId: selectedClinicId,
                                encounterId: encounterData.id,
                                reason: reasonCont.text.trim(),
                                notes: notesCont.text.trim().isEmpty ? null : notesCont.text.trim(),
                              );
                              toast("Referral created");
                              if (ctx.mounted) Navigator.pop(ctx);
                              c.loadReferrals();
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

  Future<void> _loadDoctors(RxList<DoctorOption> list, RxBool loading) async {
    loading(true);
    try {
      final res = await handleResponse(
        await buildHttpResponse("${APIEndPoints.getDoctors}"),
      );
      final data = res['data'] as List? ?? [];
      list.value = data.map((d) {
        final clinics = d['clinics'] as List? ?? [];
        final clinicName = clinics.isNotEmpty ? (clinics.first['name'] ?? '').toString() : '';
        final clinicId = clinics.isNotEmpty && clinics.first['clinic_id'] is int ? clinics.first['clinic_id'] as int : -1;
        return DoctorOption(
          id: d['id'] is int ? d['id'] : 0,
          name: "${d['first_name'] ?? ""} ${d['last_name'] ?? ""}".trim(),
          clinicName: clinicName,
          clinicId: clinicId,
        );
      }).toList();
    } catch (e) { log("loadDoctors err: $e"); }
    finally { loading(false); }
  }
}

class DoctorOption {
  final int id;
  final String name;
  final String clinicName;
  final int clinicId;
  DoctorOption({required this.id, required this.name, this.clinicName = '', this.clinicId = -1});
}

class _ReferralController extends GetxController {
  final EncounterElement _data;
  _ReferralController(this._data);

  RxBool isLoading = false.obs;
  RxList<EncounterReferralItem> referrals = RxList();
  RxString errorMsg = ''.obs;

  Future<void> loadReferrals() async {
    isLoading(true);
    errorMsg('');
    try {
      referrals(await CoreServiceApis.getEncounterReferrals(_data.id));
    } catch (e) {
      log("loadReferrals err: $e");
      errorMsg(e.toString());
    } finally {
      isLoading(false);
    }
  }
}

class _ReferralCard extends StatelessWidget {
  final EncounterReferralItem referral;
  const _ReferralCard({required this.referral});

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
              Icon(Icons.swap_horiz, size: 16, color: appColorPrimary),
              8.width,
              Expanded(child: Text(referral.referralCode.isNotEmpty ? referral.referralCode : "Referral #${referral.id}", style: boldTextStyle(size: 13))),
              _statusBadge(referral.status),
            ],
          ),
          6.height,
          Row(
            children: [
              Icon(Icons.person_outline, size: 13, color: Colors.grey),
              4.width,
              Text("To: ${referral.referredToDoctorName ?? "Unknown"}", style: secondaryTextStyle(size: 12)).expand(),
            ],
          ),
          if (referral.reason.isNotEmpty) ...[4.height, Text(referral.reason, style: primaryTextStyle(size: 12), maxLines: 2, overflow: TextOverflow.ellipsis)],
          if (referral.referralDate.isNotEmpty) ...[4.height, Text(referral.referralDate.splitBefore(' '), style: secondaryTextStyle(size: 11))],
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'accepted': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      default: color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: boxDecorationDefault(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: boldTextStyle(size: 10, color: color)),
    );
  }
}
