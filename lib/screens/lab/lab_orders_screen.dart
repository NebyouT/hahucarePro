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
import 'lab_controller.dart';
import 'model/lab_order_model.dart';

class LabOrdersScreen extends StatelessWidget {
  const LabOrdersScreen({super.key});

  void _showOrderDetail(BuildContext context, LabController controller, LabOrderData order) {
    final noteController = TextEditingController();
    final canUpload = order.status != 'completed' && order.status != 'cancelled';

    showModalBottomSheet(
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
              initialChildSize: canUpload ? 0.85 : 0.7,
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
                          _buildStatusBadge(order.status),
                        ],
                      ),
                      16.height,
                      _detailRow(Icons.person_outline, "Patient", order.patientName),
                      _detailRow(Icons.local_hospital_outlined, "Clinic", order.clinicName),
                      _detailRow(Icons.science_outlined, "Lab", order.labName),
                      _detailRow(Icons.assignment_outlined, "Type", order.orderType.capitalizeFirst!),
                      _detailRow(Icons.flag_outlined, "Priority", order.priority.capitalizeFirst!),
                      if (order.notes.isNotEmpty) _detailRow(Icons.notes, "Notes", order.notes),
                      _detailRow(Icons.calendar_today, "Date", order.orderDate.isNotEmpty ? order.orderDate.splitBefore(' ') : ""),
                      16.height,
                      if (order.items.isNotEmpty) ...[
                        const Divider(height: 1),
                        12.height,
                        Text("Services (${order.items.length})", style: boldTextStyle(size: 15)),
                        8.height,
                        ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline, size: 16, color: appColorPrimary),
                              8.width,
                              Text(item.serviceName, style: primaryTextStyle(size: 13)).expand(),
                              Text("\$${item.finalPrice}", style: boldTextStyle(size: 13)),
                            ],
                          ),
                        )),
                      ],
                      12.height,
                      const Divider(height: 1),
                      8.height,
                      Row(
                        children: [
                          Text(locale.value.total, style: boldTextStyle(size: 15)),
                          const Spacer(),
                          Text("\$${order.finalAmount}", style: boldTextStyle(size: 16, color: appColorPrimary)),
                        ],
                      ),
                      if (canUpload) ...[
                        16.height,
                        const Divider(height: 1),
                        12.height,
                        Text("Upload Result", style: boldTextStyle(size: 15)),
                        8.height,
                        AppTextField(
                          controller: noteController,
                          textFieldType: TextFieldType.OTHER,
                          maxLines: 3,
                          decoration: inputDecoration(
                            context,
                            hintText: "Technician note (optional)",
                          ),
                        ),
                        12.height,
                        if (selectedFilePaths.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text("${selectedFilePaths.length} file(s) selected", style: boldTextStyle(size: 13, color: Colors.green)),
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
                            text: uploadingInProgress ? "Uploading..." : "Submit Results",
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
                                        await controller.getLabOrders(showLoader: false);
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
                      ],
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

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending': color = Colors.orange; break;
      case 'confirmed': color = Colors.blue; break;
      case 'in_progress': color = Colors.purple; break;
      case 'completed': color = Colors.green; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: boxDecorationDefault(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(status.capitalizeFirst!, style: boldTextStyle(size: 10, color: color)),
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LabController>(
      init: LabController(),
      builder: (controller) {
        return AppScaffoldNew(
          appBartitleText: locale.value.order,
          hasLeadingWidget: true,
          isLoading: controller.isLoading,
          appBarVerticalSize: Get.height * 0.12,
          body: Column(
            children: [
              16.height,
              Obx(
                () => SnapHelperWidget(
                  future: controller.labOrdersFuture.value,
                  loadingWidget: controller.isLoading.value ? const Offstage() : const LoaderWidget(),
                  errorBuilder: (error) => Text(error.toString()).center(),
                  onSuccess: (res) {
                    return Obx(() {
                      return AnimatedListView(
                        itemCount: controller.labOrders.length,
                        listAnimationType: ListAnimationType.FadeIn,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        emptyWidget: NoDataWidget(
                          title: locale.value.noOrdersFound,
                          imageWidget: const EmptyStateWidget(),
                          retryText: locale.value.reload,
                          onRetry: () async {
                            await controller.getLabOrders(showLoader: false);
                          },
                        ),
                        onSwipeRefresh: () async {
                          await controller.getLabOrders(showLoader: false);
                        },
                        itemBuilder: (_, index) {
                          final order = controller.labOrders[index];
                          return LabOrderCard(
                            order: order,
                            onTap: () => _showOrderDetail(context, controller, order),
                            onUpload: () => _showOrderDetail(context, controller, order),
                          );
                        },
                      );
                    });
                  },
                ).expand(),
              ),
            ],
          ).paddingOnly(top: 16, bottom: 70),
        );
      },
    );
  }
}

class LabOrderCard extends StatelessWidget {
  final LabOrderData order;
  final VoidCallback? onTap;
  final VoidCallback? onUpload;

  const LabOrderCard({super.key, required this.order, this.onTap, this.onUpload});

  @override
  Widget build(BuildContext context) {
    final canUpload = order.status != 'completed' && order.status != 'cancelled';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: boxDecorationDefault(
        borderRadius: BorderRadius.circular(12),
        color: context.cardColor,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text("#${order.orderNumber}", style: boldTextStyle(size: 14, color: appColorPrimary), overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
                  8.width,
                  _statusBadge(order.status),
                ],
              ),
              4.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order.orderDate.isNotEmpty ? order.orderDate.splitBefore(' ') : "", style: secondaryTextStyle(size: 12)),
                  if (canUpload && onUpload != null)
                    GestureDetector(
                      onTap: onUpload,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: boxDecorationDefault(
                          color: appColorPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 14, color: appColorPrimary),
                            4.width,
                            Text("Upload", style: boldTextStyle(size: 11, color: appColorPrimary)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              8.height,
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: appColorPrimary),
                  6.width,
                  Text(order.patientName, style: primaryTextStyle(size: 13)).expand(),
                ],
              ),
              4.height,
              Row(
                children: [
                  Icon(Icons.science_outlined, size: 16, color: appColorPrimary),
                  6.width,
                  Text(order.labName, style: secondaryTextStyle(size: 12)).expand(),
                ],
              ),
              4.height,
              Row(
                children: [
                  Icon(Icons.local_hospital_outlined, size: 16, color: appColorPrimary),
                  6.width,
                  Text(order.clinicName, style: secondaryTextStyle(size: 12)).expand(),
                ],
              ),
              if (order.items.isNotEmpty) ...[
                8.height,
                const Divider(height: 1),
                8.height,
                Text("${order.items.length} ${locale.value.services}", style: boldTextStyle(size: 12)),
              ],
              if (order.finalAmount != "0") ...[
                4.height,
                Row(
                  children: [
                    const Spacer(),
                    Text("${locale.value.total}: \$${order.finalAmount}", style: boldTextStyle(size: 13, color: appColorPrimary)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'in_progress':
        color = Colors.purple;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: boxDecorationDefault(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(status.capitalizeFirst!, style: boldTextStyle(size: 10, color: color)),
    );
  }
}
