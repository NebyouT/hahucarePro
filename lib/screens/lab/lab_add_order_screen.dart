import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_clinic_admin/components/app_scaffold.dart';
import 'package:kivicare_clinic_admin/utils/colors.dart';
import 'package:kivicare_clinic_admin/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';
import 'lab_controller.dart';
import 'model/lab_order_model.dart';

class LabAddOrderScreen extends StatefulWidget {
  const LabAddOrderScreen({super.key});

  @override
  State<LabAddOrderScreen> createState() => _LabAddOrderScreenState();
}

class _LabAddOrderScreenState extends State<LabAddOrderScreen> {
  final LabController _con = Get.put(LabController());

  final _formKey = GlobalKey<FormState>();

  LabClinic? _selectedClinic;
  LabData? _selectedLab;
  LabPatientData? _selectedPatient;
  LabDoctorData? _selectedDoctor;
  String _selectedOrderType = 'outpatient';
  String _selectedPriority = 'routine';
  final _notesCont = TextEditingController();

  final Set<int> _selectedServiceIds = {};
  LabCategoryData? _selectedCategory;

  bool _isLoadingClinics = false;
  bool _isLoadingLabs = false;


  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  @override
  void dispose() {
    _notesCont.dispose();
    super.dispose();
  }

  Future<void> _loadClinics() async {
    _isLoadingClinics = true;
    setState(() {});
    await _con.fetchClinics();
    _isLoadingClinics = false;
    setState(() {});
  }

  Future<void> _loadLabs() async {
    if (_selectedClinic == null) return;
    _isLoadingLabs = true;
    _selectedLab = null;
    _selectedCategory = null;
    _selectedServiceIds.clear();
    _con.labs.clear();
    _con.categories.clear();
    _con.services.clear();
    setState(() {});
    await _con.fetchLabsByClinic(_selectedClinic!.id);
    _isLoadingLabs = false;
    setState(() {});
  }

  Future<void> _loadPatients() async {
    await _con.fetchPatients();
  }

  Future<void> _loadDoctors() async {
    if (_selectedClinic == null) return;
    _selectedDoctor = null;
    _con.doctors.clear();
    setState(() {});
    await _con.fetchDoctorsByClinic(_selectedClinic!.id);
    setState(() {});
  }

  Future<void> _loadCategories() async {
    if (_selectedLab == null) return;
    _selectedCategory = null;
    _selectedServiceIds.clear();
    _con.categories.clear();
    _con.services.clear();
    setState(() {});
    await _con.fetchCategoriesByLab(_selectedLab!.id);
    setState(() {});
  }

  Future<void> _loadServicesByCategory(int categoryId) async {
    _selectedCategory = _con.categories.firstWhereOrNull((c) => c.id == categoryId);
    _selectedServiceIds.clear();
    setState(() {});
    await _con.fetchServicesByCategory(categoryId);
    setState(() {});
  }

  Future<void> _submitOrder() async {
    if (_selectedClinic == null) {
      toast("Please select a clinic");
      return;
    }
    if (_selectedLab == null) {
      toast("Please select a lab");
      return;
    }
    if (_selectedPatient == null) {
      toast("Please select a patient");
      return;
    }
    if (_selectedDoctor == null) {
      toast("Please select a doctor");
      return;
    }
    if (_selectedServiceIds.isEmpty) {
      toast("Please select at least one service");
      return;
    }

    try {
      final res = await _con.createLabOrder(
        clinicId: _selectedClinic!.id,
        labId: _selectedLab!.id,
        patientId: _selectedPatient!.id,
        doctorId: _selectedDoctor!.id,
        orderType: _selectedOrderType,
        priority: _selectedPriority,
        notes: _notesCont.text,
        serviceIds: _selectedServiceIds.toList(),
      );

      if (res.status) {
        toast("Lab order created successfully");
        Get.back(result: true);
      } else {
        toast(res.message.isNotEmpty ? res.message : "Failed to create order");
      }
    } catch (e) {
      toast("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: "Create Lab Order",
      hasLeadingWidget: true,
      isLoading: _con.isOrderLoading,
      appBarVerticalSize: Get.height * 0.12,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Clinic & Lab"),
              8.height,
              _clinicDropdown(context),
              12.height,
              _labDropdown(context),
              20.height,

              _sectionTitle("Patient & Doctor"),
              8.height,
              _patientDropdown(context),
              12.height,
              _doctorDropdown(context),
              20.height,

              _sectionTitle("Lab Services"),
              8.height,
              _categoryDropdown(context),
              12.height,
              _servicesGrid(),
              20.height,

              _sectionTitle("Order Details"),
              8.height,
              _orderTypeDropdown(context),
              12.height,
              _priorityDropdown(context),
              12.height,
              AppTextField(
                controller: _notesCont,
                textFieldType: TextFieldType.MULTILINE,
                decoration: inputDecoration(context, labelText: "Notes (optional)", hintText: "Add any notes..."),
                maxLines: 3,
              ),
              24.height,

              AppButton(
                width: Get.width,
                color: appColorPrimary,
                onTap: _submitOrder,
                child: Text("Submit Order", style: primaryTextStyle(color: white)),
              ),
              32.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: boldTextStyle(size: 16));
  }

  Widget _clinicDropdown(BuildContext context) {
    return DropdownButtonFormField<LabClinic>(
      value: _selectedClinic,
      decoration: inputDecoration(context, labelText: "Clinic"),
      hint: Text(_isLoadingClinics ? "Loading..." : "Select Clinic"),
      items: _con.clinics.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
      onChanged: (val) {
        _selectedClinic = val;
        _selectedLab = null;
        _selectedCategory = null;
        _selectedServiceIds.clear();
        _con.labs.clear();
        _con.categories.clear();
        _con.services.clear();
        setState(() {});
        if (val != null) {
          _loadLabs();
        }
      },
      validator: (v) => v == null ? "Required" : null,
    );
  }

  Widget _labDropdown(BuildContext context) {
    return DropdownButtonFormField<LabData>(
      value: _selectedLab,
      decoration: inputDecoration(context, labelText: "Lab"),
      hint: Text(_isLoadingLabs ? "Loading..." : "Select Lab"),
      items: _con.labs.map((l) => DropdownMenuItem(value: l, child: Text(l.name))).toList(),
      onChanged: (val) {
        _selectedLab = val;
        setState(() {});
        if (val != null) {
          _loadCategories();
        }
      },
      validator: (v) => v == null ? "Required" : null,
    );
  }

  Widget _patientDropdown(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (_con.patients.isEmpty) {
          await _loadPatients();
        }
        _showSearchSheet<LabPatientData>(
          title: "Select Patient",
          items: _con.patients,
          displayName: (p) => "${p.firstName} ${p.lastName} (${p.email})",
          onSelected: (p) {
            _selectedPatient = p;
            setState(() {});
          },
        );
      },
      child: InputDecorator(
        decoration: inputDecoration(context, labelText: "Patient"),
        child: Text(_selectedPatient != null ? "${_selectedPatient!.firstName} ${_selectedPatient!.lastName}" : "Tap to select"),
      ),
    );
  }

  Widget _doctorDropdown(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (_selectedClinic == null) {
          toast("Please select a clinic first");
          return;
        }
        if (_con.doctors.isEmpty) {
          await _loadDoctors();
        }
        _showSearchSheet<LabDoctorData>(
          title: "Select Doctor",
          items: _con.doctors,
          displayName: (d) => "${d.firstName} ${d.lastName}",
          onSelected: (d) {
            _selectedDoctor = d;
            setState(() {});
          },
        );
      },
      child: InputDecorator(
        decoration: inputDecoration(context, labelText: "Doctor"),
        child: Text(_selectedDoctor != null ? "${_selectedDoctor!.firstName} ${_selectedDoctor!.lastName}" : "Tap to select"),
      ),
    );
  }

  Widget _categoryDropdown(BuildContext context) {
    return DropdownButtonFormField<LabCategoryData>(
      value: _selectedCategory,
      decoration: inputDecoration(context, labelText: "Category (filter services)"),
      hint: const Text("All Categories"),
      items: _con.categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
      onChanged: (val) {
        if (val != null) {
          _loadServicesByCategory(val.id);
        } else {
          _selectedCategory = null;
          _selectedServiceIds.clear();
          setState(() {});
        }
      },
    );
  }

  Widget _servicesGrid() {
    if (_con.services.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(8), color: context.cardColor),
        child: Center(
          child: Text("Select a lab and category to see services", style: secondaryTextStyle()),
        ),
      );
    }

    return Container(
      decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(8), color: context.cardColor),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: Text("${_selectedServiceIds.length} selected", style: boldTextStyle(size: 12)),
          ),
          ..._con.services.map((service) => CheckboxListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            title: Text(service.name, style: primaryTextStyle(size: 13)),
            subtitle: Text("\$${service.price}", style: secondaryTextStyle(size: 12)),
            value: _selectedServiceIds.contains(service.id),
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  _selectedServiceIds.add(service.id);
                } else {
                  _selectedServiceIds.remove(service.id);
                }
              });
            },
          )),
        ],
      ),
    );
  }

  Widget _orderTypeDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedOrderType,
      decoration: inputDecoration(context, labelText: "Order Type"),
      items: const [
        DropdownMenuItem(value: 'outpatient', child: Text('Outpatient')),
        DropdownMenuItem(value: 'inpatient', child: Text('Inpatient')),
        DropdownMenuItem(value: 'emergency', child: Text('Emergency')),
      ],
      onChanged: (v) => setState(() => _selectedOrderType = v!),
    );
  }

  Widget _priorityDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedPriority,
      decoration: inputDecoration(context, labelText: "Priority"),
      items: const [
        DropdownMenuItem(value: 'routine', child: Text('Routine')),
        DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
        DropdownMenuItem(value: 'stat', child: Text('Stat')),
      ],
      onChanged: (v) => setState(() => _selectedPriority = v!),
    );
  }

  void _showSearchSheet<T>({
    required String title,
    required List<T> items,
    required String Function(T) displayName,
    required Function(T) onSelected,
  }) {
    final searchCont = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final filtered = searchCont.text.isEmpty
                ? items
                : items.where((e) => displayName(e).toLowerCase().contains(searchCont.text.toLowerCase())).toList();

            return Container(
              height: Get.height * 0.6,
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: boxDecorationDefault(borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                    child: Column(
                      children: [
                        Container(width: 40, height: 4, decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(2), color: Colors.grey[300])),
                        12.height,
                        Text(title, style: boldTextStyle(size: 16)),
                        12.height,
                        AppTextField(
                          controller: searchCont,
                          textFieldType: TextFieldType.NAME,
                          decoration: inputDecoration(ctx, hintText: "Search..."),
                          onChanged: (_) => setSheetState(() {}),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text("No results"))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final item = filtered[i];
                              return ListTile(
                                title: Text(displayName(item)),
                                onTap: () {
                                  onSelected(item);
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
