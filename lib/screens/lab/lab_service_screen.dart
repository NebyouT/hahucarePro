import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_clinic_admin/components/app_scaffold.dart';
import 'package:kivicare_clinic_admin/components/loader_widget.dart';
import 'package:kivicare_clinic_admin/main.dart';
import 'package:kivicare_clinic_admin/utils/colors.dart';
import 'package:kivicare_clinic_admin/utils/common_base.dart';
import 'package:kivicare_clinic_admin/utils/empty_error_state_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'lab_controller.dart';
import 'model/lab_order_model.dart';

class LabServiceScreen extends StatelessWidget {
  const LabServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LabController>()) {
      Get.put(LabController());
    }
    final controller = Get.find<LabController>();
    controller.fetchServices();
    controller.fetchCategories();

    return GetBuilder<LabController>(
      builder: (c) {
        return AppScaffoldNew(
          appBartitleText: locale.value.services,
          hasLeadingWidget: true,
          isLoading: c.isServicesLoading,
          appBarVerticalSize: Get.height * 0.12,
          body: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  decoration: boxDecorationDefault(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: appColorPrimary,
                    indicator: BoxDecoration(
                      color: appColorPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: "Services"),
                      Tab(text: "Categories"),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _servicesTab(context, c),
                      _categoriesTab(context, c),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _servicesTab(BuildContext context, LabController c) {
    return Stack(
      children: [
        Obx(
          () => SnapHelperWidget(
            future: c.servicesFuture.value,
            loadingWidget: c.isServicesLoading.value ? const Offstage() : const LoaderWidget(),
            errorBuilder: (error) => Text(error.toString()).center(),
            onSuccess: (res) {
              return Obx(() {
                return AnimatedListView(
                  itemCount: c.labServiceItems.length,
                  listAnimationType: ListAnimationType.FadeIn,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  emptyWidget: NoDataWidget(
                    title: locale.value.noServicesFound,
                    imageWidget: const EmptyStateWidget(),
                    retryText: locale.value.reload,
                    onRetry: () async {
                      await c.fetchServices();
                    },
                  ),
                  onSwipeRefresh: () async {
                    await c.fetchServices();
                  },
                  itemBuilder: (_, index) {
                    final service = c.labServiceItems[index];
                    return _ServiceCard(
                      service: service,
                      onTap: () => _showServiceForm(context, c, service: service),
                      onLongPress: () => _confirmDelete(context, c, service),
                    );
                  },
                );
              });
            },
          ).paddingOnly(top: 16, bottom: 70),
        ),
        Positioned(
          right: 16,
          bottom: 86,
          child: FloatingActionButton(
            backgroundColor: appColorPrimary,
            onPressed: () => _showServiceForm(context, c),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _categoriesTab(BuildContext context, LabController c) {
    return Stack(
      children: [
        Obx(
          () => SnapHelperWidget(
            future: c.servicesFuture.value,
            loadingWidget: const LoaderWidget(),
            errorBuilder: (error) => Text(error.toString()).center(),
            onSuccess: (res) {
              return Obx(() {
                return AnimatedListView(
                  itemCount: c.labCategories.length,
                  listAnimationType: ListAnimationType.FadeIn,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  emptyWidget: NoDataWidget(
                    title: "No categories found",
                    imageWidget: const EmptyStateWidget(),
                    retryText: locale.value.reload,
                    onRetry: () async {
                      await c.fetchCategories();
                    },
                  ),
                  onSwipeRefresh: () async {
                    await c.fetchCategories();
                  },
                  itemBuilder: (_, index) {
                    final cat = c.labCategories[index];
                    return _CategoryCard(
                      category: cat,
                      onTap: () => _showCategoryForm(context, c, category: cat),
                      onLongPress: () => _confirmDeleteCategory(context, c, cat),
                    );
                  },
                );
              });
            },
          ).paddingOnly(top: 16, bottom: 70),
        ),
        Positioned(
          right: 16,
          bottom: 86,
          child: FloatingActionButton(
            backgroundColor: appColorPrimary,
            onPressed: () => _showCategoryForm(context, c),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ─── Service CRUD ────────────────────────────────────────────────────

  void _confirmDelete(BuildContext context, LabController controller, LabServiceItem service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Service"),
        content: Text("Are you sure you want to delete \"${service.name}\"?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(locale.value.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await controller.deleteService(service.id);
                toast("Service deleted");
              } catch (e) {
                toast("Delete failed: $e");
              }
            },
            child: Text(locale.value.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showServiceForm(BuildContext context, LabController controller, {LabServiceItem? service}) async {
    if (controller.labCategories.isEmpty) {
      await controller.fetchCategories();
    }
    if (!context.mounted) return;
    final isEdit = service != null;
    final nameCont = TextEditingController(text: service?.name ?? "");
    final descCont = TextEditingController(text: service?.description ?? "");
    final priceCont = TextEditingController(text: service?.price ?? "");
    final formKey = GlobalKey<FormState>();
    int? selectedCategoryId = service?.categoryId;
    bool isActive = service?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 16, right: 16, top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(2), color: Colors.grey[300]),
                        ),
                      ),
                      16.height,
                      Text(isEdit ? "Edit Service" : "Add Service", style: boldTextStyle(size: 18)),
                      16.height,
                      AppTextField(
                        controller: nameCont,
                        textFieldType: TextFieldType.NAME,
                        decoration: inputDecoration(context, labelText: "Service Name", hintText: "Enter service name"),
                        validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                      ),
                      12.height,
                      AppTextField(
                        controller: descCont,
                        textFieldType: TextFieldType.MULTILINE,
                        maxLines: 3,
                        decoration: inputDecoration(context, labelText: "Description", hintText: "Enter description (optional)"),
                      ),
                      12.height,
                      AppTextField(
                        controller: priceCont,
                        textFieldType: TextFieldType.PHONE,
                        decoration: inputDecoration(context, labelText: "Price", hintText: "0.00"),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return "Required";
                          if (double.tryParse(v) == null) return "Invalid price";
                          return null;
                        },
                      ),
                      12.height,
                      DropdownButtonFormField<int>(
                        initialValue: selectedCategoryId,
                        decoration: inputDecoration(context, labelText: "Category"),
                        hint: const Text("Select Category"),
                        items: controller.labCategories.map((cat) =>
                          DropdownMenuItem(value: cat.id, child: Text(cat.name))
                        ).toList(),
                        onChanged: (v) => setSheetState(() => selectedCategoryId = v),
                        validator: (v) => v == null ? "Required" : null,
                      ),
                      12.height,
                      SwitchListTile(
                        title: const Text("Active"),
                        value: isActive,
                        onChanged: (v) => setSheetState(() => isActive = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                      16.height,
                      SizedBox(
                        width: Get.width,
                        child: AppButton(
                          textStyle: boldTextStyle(color: Colors.white),
                          text: isEdit ? "Update Service" : "Create Service",
                          color: appColorPrimary,
                          onTap: () async {
                            if (!(formKey.currentState?.validate() ?? false)) return;
                            try {
                              if (isEdit) {
                                await controller.updateService(
                                  id: service.id,
                                  name: nameCont.text.trim(),
                                  description: descCont.text.trim(),
                                  price: priceCont.text.trim(),
                                  categoryId: selectedCategoryId!,
                                  isActive: isActive,
                                );
                                toast("Service updated");
                              } else {
                                await controller.createService(
                                  name: nameCont.text.trim(),
                                  description: descCont.text.trim(),
                                  price: priceCont.text.trim(),
                                  categoryId: selectedCategoryId!,
                                  isActive: isActive,
                                );
                                toast("Service created");
                              }
                              if (ctx.mounted) Navigator.pop(ctx);
                            } catch (e) {
                              toast("Error: $e");
                            }
                          },
                        ),
                      ),
                      8.height,
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

  // ─── Category CRUD ───────────────────────────────────────────────────

  void _confirmDeleteCategory(BuildContext context, LabController controller, LabCategoryItem cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Category"),
        content: Text("Are you sure you want to delete \"${cat.name}\"?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(locale.value.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await controller.deleteCategory(cat.id);
                toast("Category deleted");
              } catch (e) {
                toast("Delete failed: $e");
              }
            },
            child: Text(locale.value.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCategoryForm(BuildContext context, LabController controller, {LabCategoryItem? category}) async {
    final isEdit = category != null;
    final nameCont = TextEditingController(text: category?.name ?? "");
    final descCont = TextEditingController(text: category?.description ?? "");
    final sortOrderCont = TextEditingController(text: (category?.sortOrder ?? 0).toString());
    final formKey = GlobalKey<FormState>();
    bool isActive = category?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 16, right: 16, top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(2), color: Colors.grey[300]),
                        ),
                      ),
                      16.height,
                      Text(isEdit ? "Edit Category" : "Add Category", style: boldTextStyle(size: 18)),
                      16.height,
                      AppTextField(
                        controller: nameCont,
                        textFieldType: TextFieldType.NAME,
                        decoration: inputDecoration(context, labelText: "Category Name", hintText: "Enter category name"),
                        validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                      ),
                      12.height,
                      AppTextField(
                        controller: descCont,
                        textFieldType: TextFieldType.MULTILINE,
                        maxLines: 3,
                        decoration: inputDecoration(context, labelText: "Description", hintText: "Enter description (optional)"),
                      ),
                      12.height,
                      AppTextField(
                        controller: sortOrderCont,
                        textFieldType: TextFieldType.PHONE,
                        decoration: inputDecoration(context, labelText: "Sort Order", hintText: "0"),
                      ),
                      12.height,
                      SwitchListTile(
                        title: const Text("Active"),
                        value: isActive,
                        onChanged: (v) => setSheetState(() => isActive = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                      16.height,
                      SizedBox(
                        width: Get.width,
                        child: AppButton(
                          textStyle: boldTextStyle(color: Colors.white),
                          text: isEdit ? "Update Category" : "Create Category",
                          color: appColorPrimary,
                          onTap: () async {
                            if (!(formKey.currentState?.validate() ?? false)) return;
                            try {
                              if (isEdit) {
                                await controller.updateCategory(
                                  id: category.id,
                                  name: nameCont.text.trim(),
                                  description: descCont.text.trim(),
                                  sortOrder: int.tryParse(sortOrderCont.text.trim()) ?? 0,
                                  isActive: isActive,
                                );
                                toast("Category updated");
                              } else {
                                await controller.createCategory(
                                  name: nameCont.text.trim(),
                                  description: descCont.text.trim(),
                                  sortOrder: int.tryParse(sortOrderCont.text.trim()) ?? 0,
                                  isActive: isActive,
                                );
                                toast("Category created");
                              }
                              if (ctx.mounted) Navigator.pop(ctx);
                            } catch (e) {
                              toast("Error: $e");
                            }
                          },
                        ),
                      ),
                      8.height,
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

// ─── Service Card ─────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final LabServiceItem service;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _ServiceCard({required this.service, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: boxDecorationDefault(
        borderRadius: BorderRadius.circular(12),
        color: context.cardColor,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(service.name, style: boldTextStyle(size: 14)),
                  const Spacer(),
                  _activeBadge(service.isActive),
                ],
              ),
              if (service.description.isNotEmpty) ...[
                4.height,
                Text(service.description, style: secondaryTextStyle(size: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
              8.height,
              Row(
                children: [
                  Icon(Icons.category_outlined, size: 14, color: appColorPrimary),
                  4.width,
                  Text(service.categoryName, style: secondaryTextStyle(size: 12)).expand(),
                  Text("\$${service.price}", style: boldTextStyle(size: 14, color: appColorPrimary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activeBadge(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: boxDecorationDefault(
        color: (active ? Colors.green : Colors.grey).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        active ? "Active" : "Inactive",
        style: boldTextStyle(size: 10, color: active ? Colors.green : Colors.grey),
      ),
    );
  }
}

// ─── Category Card ───────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final LabCategoryItem category;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _CategoryCard({required this.category, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: boxDecorationDefault(
        borderRadius: BorderRadius.circular(12),
        color: context.cardColor,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.category, size: 18, color: appColorPrimary),
                  8.width,
                  Text(category.name, style: boldTextStyle(size: 14)).expand(),
                  _activeBadge(category.isActive),
                ],
              ),
              if (category.description.isNotEmpty) ...[
                4.height,
                Text(category.description, style: secondaryTextStyle(size: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              6.height,
              Text("Sort: ${category.sortOrder}", style: secondaryTextStyle(size: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activeBadge(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: boxDecorationDefault(
        color: (active ? Colors.green : Colors.grey).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        active ? "Active" : "Inactive",
        style: boldTextStyle(size: 10, color: active ? Colors.green : Colors.grey),
      ),
    );
  }
}