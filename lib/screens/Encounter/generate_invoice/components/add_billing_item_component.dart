import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_clinic_admin/components/loader_widget.dart';
import 'package:kivicare_clinic_admin/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../main.dart';
import '../../../../utils/app_common.dart';
import '../../../../utils/common_base.dart';
import '../../../service/model/service_list_model.dart';
import '../../invoice_details/invoice_details_controller.dart';
import '../model/billing_item_model.dart';
import 'billing_item_service_list_screen.dart';

class AddBillingItemComponent extends StatelessWidget {
  final int? index;
  final BillingItem? billingItem;

  AddBillingItemComponent({super.key, this.billingItem, this.index});

  final InvoiceDetailsController invoiceDetailsCon = Get.find();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      invoiceDetailsCon.clearBillingTypeSelection();
      if (billingItem != null) {
        invoiceDetailsCon.isEditBillingItemLoading(true);
        final service = await invoiceDetailsCon.getAllServices(
          showloader: false,
          serviceID: billingItem!.serviceDetail!.id,
        );
        invoiceDetailsCon.tempInclusiveText(
          service.first.assignDoctor.first.priceDetail.inclusiveTaxJson,
        );
        invoiceDetailsCon.isEditBillingItemLoading(false);
      } else {
        invoiceDetailsCon.isEditBillingItemLoading(false);
      }
    });

    return Obx(
      () => SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
          decoration: boxDecorationDefault(
            color: context.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
            ),
          ),
          child: invoiceDetailsCon.isEditBillingItemLoading.value
              ? const LoaderWidget()
              : Form(
                  key: invoiceDetailsCon.addBillFormKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          billingItem != null ? locale.value.editBillingItem : locale.value.addBillingItem,
                          style: secondaryTextStyle(
                            size: 16,
                            weight: FontWeight.w600,
                            color: isDarkMode.value ? null : darkGrayTextColor,
                          ),
                        ),
                        16.height,
                        // Category Tabs
                        _buildCategoryTabs(context),
                        16.height,
                        // Category-specific content
                        _buildCategoryContent(context),
                        16.height,
                        // Common fields (price & quantity) — shown only when an item is selected
                        if (_isItemSelected()) ...[
                          AppTextField(
                            textStyle: primaryTextStyle(size: 12),
                            controller: invoiceDetailsCon.priceCont,
                            textFieldType: TextFieldType.NUMBER,
                            focus: invoiceDetailsCon.priceFocus,
                            readOnly: true,
                            decoration: inputDecoration(
                              context,
                              fillColor: context.cardColor,
                              filled: true,
                              hintText: locale.value.price,
                            ),
                          ),
                          16.height,
                          AppTextField(
                            textStyle: primaryTextStyle(size: 12),
                            controller: invoiceDetailsCon.quantityCont,
                            textFieldType: TextFieldType.NUMBER,
                            focus: invoiceDetailsCon.quantityFocus,
                            decoration: inputDecoration(
                              context,
                              fillColor: context.cardColor,
                              filled: true,
                              hintText: locale.value.quantity,
                            ),
                          ),
                          16.height,
                          AppButton(
                            width: Get.width,
                            text: locale.value.save,
                            color: appColorSecondary,
                            textStyle: appButtonTextStyleWhite,
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: radius(defaultAppButtonRadius / 2),
                            ),
                            onTap: () {
                              if (invoiceDetailsCon.addBillFormKey.currentState!.validate()) {
                                Get.back();
                                if (invoiceDetailsCon.selectedBillingItemType.value == BillingItemType.service) {
                                  invoiceDetailsCon.saveBillingItem(
                                    billingItem: billingItem,
                                    index: index ?? 0,
                                  );
                                } else {
                                  invoiceDetailsCon.saveNonServiceBillingItem(
                                    billingItem: billingItem,
                                    index: index ?? 0,
                                  );
                                }
                              }
                            },
                          ),
                        ],
                        16.height,
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  bool _isItemSelected() {
    final type = invoiceDetailsCon.selectedBillingItemType.value;
    switch (type) {
      case BillingItemType.service:
        return invoiceDetailsCon.selectService.value.id != -1;
      case BillingItemType.labTest:
        return invoiceDetailsCon.selectedLabOrderItem.value.id != 0;
      case BillingItemType.medicine:
        return invoiceDetailsCon.selectedPrescriptionItem.value.id != -1;
    }
  }

  Widget _buildCategoryTabs(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: isDarkMode.value ? Colors.white10 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _buildTab(context, locale.value.services, BillingItemType.service),
            _buildTab(context, locale.value.labTests, BillingItemType.labTest),
            _buildTab(context, locale.value.prescribedMedicines, BillingItemType.medicine),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, BillingItemType type) {
    final isSelected = invoiceDetailsCon.selectedBillingItemType.value == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          invoiceDetailsCon.clearBillingTypeSelection();
          invoiceDetailsCon.selectedBillingItemType(type);
          if (type == BillingItemType.labTest) {
            invoiceDetailsCon.fetchEncounterLabOrders();
          } else if (type == BillingItemType.medicine) {
            invoiceDetailsCon.fetchEncounterPrescriptions();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? appColorSecondary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: primaryTextStyle(
              size: 12,
              color: isSelected ? Colors.white : textSecondaryColorGlobal,
              weight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryContent(BuildContext context) {
    final type = invoiceDetailsCon.selectedBillingItemType.value;
    switch (type) {
      case BillingItemType.service:
        return _buildServiceSelector(context);
      case BillingItemType.labTest:
        return _buildLabTestSelector(context);
      case BillingItemType.medicine:
        return _buildMedicineSelector(context);
    }
  }

  Widget _buildServiceSelector(BuildContext context) {
    return AppTextField(
      textStyle: primaryTextStyle(size: 12),
      controller: invoiceDetailsCon.servicesCont,
      focus: invoiceDetailsCon.servicesFocus,
      nextFocus: invoiceDetailsCon.priceFocus,
      textFieldType: TextFieldType.MULTILINE,
      minLines: 1,
      readOnly: true,
      onTap: () {
        Get.to(
          () => BillingServicesListScreen(),
          arguments: [invoiceDetailsCon.selectService.value, invoiceDetailsCon.billingItemList],
        )?.then((value) {
          if (value is ServiceElement) {
            invoiceDetailsCon.selectService(value);
            invoiceDetailsCon.servicesCont.text = invoiceDetailsCon.selectService.value.name;
            invoiceDetailsCon.quantityCont.text = "1";

            final hasDoctor = invoiceDetailsCon.selectService.value.assignDoctor.isNotEmpty;

            invoiceDetailsCon.serviceAmount.value = hasDoctor
                ? invoiceDetailsCon.selectService.value.assignDoctor
                    .firstWhere(
                      (e) => e.doctorId == invoiceDetailsCon.invoiceData.value.doctorId,
                    )
                    .priceDetail
                    .servicePrice
                : invoiceDetailsCon.selectService.value.charges;

            invoiceDetailsCon.priceCont.text = hasDoctor
                ? invoiceDetailsCon.selectService.value.assignDoctor
                    .firstWhere(
                      (e) => e.doctorId == invoiceDetailsCon.invoiceData.value.doctorId,
                    )
                    .priceDetail
                    .serviceAmount
                    .toStringAsFixed(appCurrency.value.noOfDecimal)
                    .formatNumberWithComma(
                      seperator: appCurrency.value.thousandSeparator,
                    )
                : invoiceDetailsCon.selectService.value.charges.toString();
          }
        });
      },
      decoration: inputDecoration(
        context,
        hintText: locale.value.selectService,
        fillColor: context.cardColor,
        filled: true,
        suffixIcon: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 24,
          color: darkGray.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildLabTestSelector(BuildContext context) {
    return Obx(() {
      if (invoiceDetailsCon.isLoadingLabOrders.value) {
        return const LoaderWidget().center();
      }
      if (invoiceDetailsCon.encounterLabOrders.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: boxDecorationDefault(
            color: context.cardColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            locale.value.noLabOrdersFound,
            style: primaryTextStyle(size: 12, color: dividerColor),
          ),
        );
      }

      // Collect all lab order items across all orders
      final allLabItems = invoiceDetailsCon.encounterLabOrders
          .expand((order) => order.labOrderItems)
          .toList();

      return Container(
        constraints: const BoxConstraints(maxHeight: 250),
        decoration: boxDecorationDefault(
          color: context.cardColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          itemCount: allLabItems.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: context.dividerColor.withValues(alpha: 0.2)),
          itemBuilder: (context, index) {
            final item = allLabItems[index];
            final isSelected = invoiceDetailsCon.selectedLabOrderItem.value.id == item.id;
            return ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              title: Text(
                item.serviceName,
                style: primaryTextStyle(
                  size: 13,
                  color: isSelected ? appColorSecondary : null,
                  weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${locale.value.price}: ${item.price}',
                style: secondaryTextStyle(size: 11),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: appColorSecondary, size: 20)
                  : Icon(Icons.radio_button_off, color: borderColor, size: 20),
              onTap: () {
                invoiceDetailsCon.selectLabOrderItem(item);
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildMedicineSelector(BuildContext context) {
    return Obx(() {
      if (invoiceDetailsCon.isLoadingPrescriptions.value) {
        return const LoaderWidget().center();
      }
      if (invoiceDetailsCon.encounterPrescriptions.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: boxDecorationDefault(
            color: context.cardColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            locale.value.noPrescriptionsFound,
            style: primaryTextStyle(size: 12, color: dividerColor),
          ),
        );
      }

      return Container(
        constraints: const BoxConstraints(maxHeight: 250),
        decoration: boxDecorationDefault(
          color: context.cardColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          itemCount: invoiceDetailsCon.encounterPrescriptions.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: context.dividerColor.withValues(alpha: 0.2)),
          itemBuilder: (context, index) {
            final item = invoiceDetailsCon.encounterPrescriptions[index];
            final isSelected = invoiceDetailsCon.selectedPrescriptionItem.value.id == item.id;
            return ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              title: Text(
                item.medicine.name,
                style: primaryTextStyle(
                  size: 13,
                  color: isSelected ? appColorSecondary : null,
                  weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${item.medicine.dosage} • ${item.medicine.form.name} • ${locale.value.price}: ${item.medicine.sellingPrice}',
                style: secondaryTextStyle(size: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: appColorSecondary, size: 20)
                  : Icon(Icons.radio_button_off, color: borderColor, size: 20),
              onTap: () {
                invoiceDetailsCon.selectPrescriptionItem(item);
              },
            );
          },
        ),
      );
    });
  }
}
