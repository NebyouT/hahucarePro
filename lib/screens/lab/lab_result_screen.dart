import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_clinic_admin/components/app_scaffold.dart';
import 'package:kivicare_clinic_admin/components/loader_widget.dart';
import 'package:kivicare_clinic_admin/main.dart';
import 'package:kivicare_clinic_admin/utils/colors.dart';
import 'package:kivicare_clinic_admin/utils/common_base.dart';
import 'package:kivicare_clinic_admin/utils/empty_error_state_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'lab_controller.dart';
import 'model/lab_order_model.dart';

class LabResultScreen extends StatelessWidget {
  const LabResultScreen({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'in_progress': return const Color(0xFF7C4DFF);
      case 'cancelled': return Colors.red;
      case 'pending': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    return status.replaceAll('_', ' ').capitalizeFirst!;
  }

  Widget _statusBadge(String status, {Color? color}) {
    final c = color ?? _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: boxDecorationDefault(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(_statusLabel(status), style: boldTextStyle(size: 10, color: c)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LabController>()) {
      Get.put(LabController());
    }

    return GetBuilder<LabController>(
      builder: (c) {
        return AppScaffoldNew(
          appBartitleText: "Lab Results",
          hasLeadingWidget: true,
          isLoading: c.isWorklistLoading,
          appBarVerticalSize: Get.height * 0.12,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text("Results uploaded from completed lab orders",
                        style: secondaryTextStyle(size: 12)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => c.getWorklist(showLoader: false),
                      icon: Icon(Icons.refresh, size: 16, color: appColorPrimary),
                      label: Text("Refresh", style: boldTextStyle(size: 12, color: appColorPrimary)),
                    ),
                  ],
                ),
              ),
              8.height,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        textFieldType: TextFieldType.NAME,
                        decoration: inputDecoration(
                          context,
                          hintText: "Order # or patient name...",
                          prefixIcon: Icon(Icons.search, size: 18, color: appColorPrimary),
                        ),
                        onFieldSubmitted: (v) {
                          c.getWorklist(showLoader: false, search: v);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              8.height,
              Obx(() {
                final activeFilter = c.worklistStatusFilter.value;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _filterChip(context, "All", activeFilter == '', () => c.getWorklist(showLoader: false, status: '')),
                      8.width,
                      _filterChip(context, "Pending", activeFilter == 'pending', () => c.getWorklist(showLoader: false, status: 'pending')),
                      8.width,
                      _filterChip(context, "In Progress", activeFilter == 'in_progress', () => c.getWorklist(showLoader: false, status: 'in_progress')),
                      8.width,
                      _filterChip(context, "Completed", activeFilter == 'completed', () => c.getWorklist(showLoader: false, status: 'completed')),
                    ],
                  ),
                );
              }),
              12.height,
              Obx(
                () => SnapHelperWidget(
                  future: c.worklistFuture.value,
                  loadingWidget: c.isWorklistLoading.value ? const Offstage() : const LoaderWidget(),
                  errorBuilder: (error) => Text(error.toString()).center(),
                  onSuccess: (res) {
                    return Obx(() {
                      if (c.worklist.isEmpty) {
                        return NoDataWidget(
                          title: "No lab results found.",
                          subTitle: "Complete lab orders to see results here.",
                          imageWidget: const EmptyStateWidget(),
                          retryText: locale.value.reload,
                          onRetry: () async {
                            await c.getWorklist(showLoader: false);
                          },
                        ).center();
                      }
                      return AnimatedListView(
                        itemCount: c.worklist.length,
                        listAnimationType: ListAnimationType.FadeIn,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        onSwipeRefresh: () async {
                          await c.getWorklist(showLoader: false);
                        },
                        itemBuilder: (_, index) {
                          final order = c.worklist[index];
                          return _buildOrderCard(context, c, order);
                        },
                      );
                    });
                  },
                ).expand(),
              ),
            ],
          ).paddingOnly(top: 8, bottom: 70),
        );
      },
    );
  }

  Widget _filterChip(BuildContext context, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: boxDecorationDefault(
          color: isActive ? appColorPrimary : context.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: boldTextStyle(size: 12, color: isActive ? Colors.white : null),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, LabController controller, LabOrderData order) {
    final statusColor = _statusColor(order.status);
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final canUpload = order.status != 'completed' && order.status != 'cancelled';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: boxDecorationDefault(
        borderRadius: BorderRadius.circular(12),
        color: context.cardColor,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status color stripe
            Container(width: 6, color: statusColor),
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: order number + badges + date
                    Row(
                      children: [
                        Flexible(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: [
                              Text("#${order.orderNumber}", style: boldTextStyle(size: 14, color: appColorPrimary)),
                              _statusBadge(order.status),
                              if (order.priority == 'urgent' || order.priority == 'stat')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: boxDecorationDefault(
                                    color: Colors.red.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(order.priority.toUpperCase(), style: boldTextStyle(size: 9, color: Colors.red)),
                                ),
                            ],
                          ),
                        ),
                        8.width,
                        Text(
                          order.orderDate.isNotEmpty ? order.orderDate.splitBefore(' ') : '',
                          style: secondaryTextStyle(size: 11),
                        ),
                      ],
                    ),
                    8.height,
                    // Patient / Doctor / Lab / Clinic in 2x2 grid
                    Row(
                      children: [
                        Expanded(
                          child: _infoCol("Patient", order.patientName),
                        ),
                        8.width,
                        Expanded(
                          child: _infoCol("Doctor", order.doctorName),
                        ),
                      ],
                    ),
                    4.height,
                    Row(
                      children: [
                        Expanded(
                          child: _infoCol("Lab", order.labName),
                        ),
                        8.width,
                        Expanded(
                          child: _infoCol("Clinic", order.clinicName),
                        ),
                      ],
                    ),
                    // Service badges
                    if (order.items.isNotEmpty) ...[
                      8.height,
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: order.items.map((item) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: boxDecorationDefault(
                            color: context.cardColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: context.dividerColor),
                          ),
                          child: Text(item.serviceName, style: primaryTextStyle(size: 11)),
                        )).toList(),
                      ),
                    ],
                    // Doctor's clinical note
                    if (order.notes.isNotEmpty) ...[
                      8.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.note, size: 14, color: appColorPrimary),
                          4.width,
                          Expanded(
                            child: Text(order.notes,
                                style: secondaryTextStyle(size: 11, fontStyle: FontStyle.italic)),
                          ),
                        ],
                      ),
                    ],
                    // Result section
                    8.height,
                    _buildResultSection(firstItem, order.completedDate),
                  ],
                ),
              ),
            ),
            // Action buttons column
            Container(
              width: 44,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: context.dividerColor)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => _showOrderDetail(context, controller, order),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Icon(Icons.visibility, size: 18, color: appColorPrimary),
                    ),
                  ),
                  if (canUpload)
                    InkWell(
                      onTap: () => _showResultUploadSheet(context, controller, order),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: context.dividerColor)),
                        ),
                        child: Icon(Icons.cloud_upload_outlined, size: 18, color: appColorPrimary),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: secondaryTextStyle(size: 10)),
        Text(value.isNotEmpty ? value : '—', style: boldTextStyle(size: 12)),
      ],
    );
  }

  Widget _buildResultSection(LabOrderItemData? firstItem, String? completedDate) {
    if (firstItem != null && firstItem.resultFile != null && firstItem.resultFile!.isNotEmpty) {
      return Container(
        width: Get.width,
        padding: const EdgeInsets.all(8),
        decoration: boxDecorationDefault(
          color: Colors.green.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, size: 14, color: Colors.green),
                4.width,
                Text("Result Available", style: boldTextStyle(size: 11, color: Colors.green)),
              ],
            ),
            4.height,
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: firstItem.resultFileUrls.map((f) {
                return InkWell(
                  onTap: () async {
                    final uri = Uri.tryParse(f.url);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((e) {
                        launchUrl(uri, mode: LaunchMode.inAppWebView);
                      });
                    } else if (uri != null) {
                      launchUrl(uri, mode: LaunchMode.inAppWebView);
                    } else {
                      toast("Could not open file");
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: boxDecorationDefault(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.download, size: 12, color: Colors.green),
                        4.width,
                        Text(f.name.isNotEmpty ? f.name : "File", style: boldTextStyle(size: 10, color: Colors.green)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (firstItem.technicianNote != null && firstItem.technicianNote!.isNotEmpty) ...[
              4.height,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person, size: 12, color: Colors.green[700]),
                  4.width,
                  Expanded(
                    child: Text(firstItem.technicianNote!,
                        style: secondaryTextStyle(size: 10, color: Colors.green[700])),
                  ),
                ],
              ),
            ],
            if (firstItem.resultUploadedAt != null && firstItem.resultUploadedAt!.isNotEmpty) ...[
              4.height,
              Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: Colors.green[700]),
                  4.width,
                  Text("Uploaded ${firstItem.resultUploadedAt!.splitBefore(' ')}",
                      style: secondaryTextStyle(size: 10, color: Colors.green[700])),
                ],
              ),
            ],
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.hourglass_bottom, size: 14, color: Colors.grey),
          4.width,
          Text("No result uploaded yet", style: secondaryTextStyle(size: 11)),
        ],
      ),
    );
  }

  void _showOrderDetail(BuildContext context, LabController controller, LabOrderData order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(2), color: Colors.grey[300]),
                    ),
                  ),
                  16.height,
                  Row(
                    children: [
                      Text("#${order.orderNumber}", style: boldTextStyle(size: 18, color: appColorPrimary)),
                      const Spacer(),
                      _statusBadge(order.status),
                    ],
                  ),
                  16.height,
                  _detailRow(Icons.person_outline, "Patient", order.patientName),
                  _detailRow(Icons.person, "Doctor", order.doctorName),
                  _detailRow(Icons.local_hospital_outlined, "Clinic", order.clinicName),
                  _detailRow(Icons.science_outlined, "Lab", order.labName),
                  _detailRow(Icons.flag_outlined, "Priority", order.priority.capitalizeFirst!),
                  if (order.notes.isNotEmpty) _detailRow(Icons.notes, "Notes", order.notes),
                  _detailRow(Icons.calendar_today, "Date", order.orderDate.isNotEmpty ? order.orderDate.splitBefore(' ') : ""),
                  if (order.completedDate != null) _detailRow(Icons.check_circle, "Completed", order.completedDate!),
                  16.height,
                  const Divider(height: 1),
                  12.height,
                  Text("Services (${order.items.length})", style: boldTextStyle(size: 15)),
                  8.height,
                  ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        if (item.status == 'completed')
                          Icon(Icons.check_circle, size: 16, color: Colors.green)
                        else
                          Icon(Icons.check_circle_outline, size: 16, color: appColorPrimary),
                        8.width,
                        Text(item.serviceName, style: primaryTextStyle(size: 13)).expand(),
                        Text("\$${item.finalPrice}", style: boldTextStyle(size: 13)),
                      ],
                    ),
                  )),
                  24.height,
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showResultUploadSheet(BuildContext context, LabController controller, LabOrderData order) async {
    final noteController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final selectedFilePaths = <String>[];
        var uploadingInProgress = false;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            Future<void> pickFromCamera() async {
              try {
                final xFile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
                if (xFile != null) {
                  selectedFilePaths.add(xFile.path);
                  setSheetState(() {});
                }
              } catch (e) {
                toast("Camera error: $e");
              }
            }

            Future<void> pickFromFiles() async {
              try {
                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'gif', 'txt', 'xls', 'xlsx'],
                );
                if (result != null && result.files.isNotEmpty) {
                  for (final f in result.files) {
                    if (f.path != null) selectedFilePaths.add(f.path!);
                  }
                  setSheetState(() {});
                }
              } catch (e) {
                toast("File picker error: $e");
              }
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (ctx, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(2), color: Colors.grey[300]),
                        ),
                      ),
                      16.height,
                      Row(
                        children: [
                          Text("Upload Result", style: boldTextStyle(size: 18, color: appColorPrimary)),
                          const Spacer(),
                          Text("#${order.orderNumber}", style: boldTextStyle(size: 14)),
                        ],
                      ),
                      12.height,
                      AppTextField(
                        controller: noteController,
                        textFieldType: TextFieldType.OTHER,
                        maxLines: 3,
                        decoration: inputDecoration(context, hintText: "Technician note (optional)"),
                      ),
                      12.height,
                      if (selectedFilePaths.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text("${selectedFilePaths.length} file(s) selected",
                              style: boldTextStyle(size: 13, color: Colors.green)),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              textStyle: boldTextStyle(color: Colors.white),
                              text: "Camera",
                              color: appColorPrimary,
                              onTap: pickFromCamera,
                            ),
                          ),
                          8.width,
                          Expanded(
                            child: AppButton(
                              textStyle: boldTextStyle(color: Colors.white),
                              text: "Files",
                              color: appColorPrimary,
                              onTap: pickFromFiles,
                            ),
                          ),
                        ],
                      ).paddingOnly(bottom: 12),
                      SizedBox(
                        width: Get.width,
                        child: AppButton(
                          textStyle: boldTextStyle(color: Colors.white),
                          text: uploadingInProgress ? "Uploading..." : "Save & Mark Completed",
                          color: appColorPrimary,
                          onTap: uploadingInProgress
                              ? null
                              : () async {
                                  if (selectedFilePaths.isEmpty) {
                                    toast("Please select at least one file or photo");
                                    return;
                                  }
                                  setSheetState(() => uploadingInProgress = true);
                                  try {
                                    final res = await controller.uploadResult(
                                      orderId: order.id,
                                      filePaths: selectedFilePaths,
                                      technicianNote: noteController.text.isNotEmpty ? noteController.text : null,
                                    );
                                    if (res.status) {
                                      toast("Result uploaded successfully");
                                      if (ctx.mounted) Navigator.pop(ctx);
                                    } else {
                                      toast(res.message.isNotEmpty ? res.message : "Upload failed");
                                    }
                                  } catch (e) {
                                    toast("Upload failed: $e");
                                  } finally {
                                    setSheetState(() => uploadingInProgress = false);
                                  }
                                },
                        ),
                      ),
                      24.height,
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: appColorPrimary),
          8.width,
          Text("$label: ", style: secondaryTextStyle(size: 13)),
          Text(value, style: primaryTextStyle(size: 13)).expand(),
        ],
      ),
    );
  }
}
