import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../data/address_api.dart';
import '../model/address_model.dart';
import 'widgets/commerce/address_form_widgets.dart';

class AddAddressScreen extends StatefulWidget {
  final AddressItemModel? address;

  const AddAddressScreen({
    super.key,
    this.address,
  });

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  static const String _localLocationsAsset = 'assets/json/bd_locations.json';
  static const List<String> _localLocationPaths = [
    _localLocationsAsset,
    'json/bd_locations.json',
    'bd_locations.json',
  ];
  static const List<Map<String, dynamic>> _defaultDivisions = [
    {"id": 1, "name_en": "Barisal", "name_bn": "বরিশাল", "districts": []},
    {"id": 2, "name_en": "Chattagram", "name_bn": "চট্টগ্রাম", "districts": []},
    {"id": 3, "name_en": "Dhaka", "name_bn": "ঢাকা", "districts": []},
    {"id": 4, "name_en": "Khulna", "name_bn": "খুলনা", "districts": []},
    {"id": 5, "name_en": "Mymensingh", "name_bn": "ময়মনসিংহ", "districts": []},
    {"id": 6, "name_en": "Rajshahi", "name_bn": "রাজশাহী", "districts": []},
    {"id": 7, "name_en": "Rangpur", "name_bn": "রংপুর", "districts": []},
    {"id": 8, "name_en": "Sylhet", "name_bn": "সিলেট", "districts": []},
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController(text: '+880');
  final TextEditingController _detailedAddressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _postcodeController = TextEditingController();

  final TextEditingController _divisionSearchController = TextEditingController();
  final TextEditingController _districtSearchController = TextEditingController();
  final TextEditingController _upazilaSearchController = TextEditingController();
  final TextEditingController _unionSearchController = TextEditingController();

  String _selectedType = 'business';
  bool _isLoading = false;
  bool _isLoadingLocations = true;

  List<dynamic> _divisions = [];
  dynamic _selectedDivision;
  List<dynamic> _districts = [];
  dynamic _selectedDistrict;
  List<dynamic> _upazilas = [];
  dynamic _selectedUpazila;
  List<dynamic> _unions = [];
  dynamic _selectedUnion;

  final List<String> _addressTypes = ['business', 'operational', 'shipping'];

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      final addr = widget.address!;
      _nameController.text = addr.contactName ?? addr.recipientName;
      _mobileController.text = addr.contactMobile ?? addr.phone;
      _detailedAddressController.text = addr.detailedAddress ?? '';
      _landmarkController.text = addr.landmark ?? '';
      _postcodeController.text = addr.postcode ?? '';
      if (addr.type != null && addr.type!.isNotEmpty) {
        _selectedType = addr.type!.toLowerCase();
      }
    }
    _loadLocations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _detailedAddressController.dispose();
    _landmarkController.dispose();
    _postcodeController.dispose();
    _divisionSearchController.dispose();
    _districtSearchController.dispose();
    _upazilaSearchController.dispose();
    _unionSearchController.dispose();
    super.dispose();
  }

  void _setDivisions(List<dynamic> divisions) {
    if (!mounted) return;
    setState(() {
      _divisions = divisions;
      _isLoadingLocations = false;
    });
  }

  /// Divisions from the API, else the bundled JSON, else the built-in list.
  Future<void> _loadLocations() async {
    // 1. Try fetching divisions from API (GET /locations/divisions)
    try {
      final res = await locationDivisionRxObj.fetchDivisions();
      if (res.data != null && res.data!.isNotEmpty) {
        final divsFromApi = res.data!.map((item) => item.toJson()).toList();
        await _tryMergeLocalDistricts(divsFromApi);
        _setDivisions(divsFromApi);
        debugPrint('Successfully loaded ${divsFromApi.length} divisions from API');
        return;
      }
    } catch (e) {
      debugPrint('Failed to load divisions from API: $e');
    }

    // 2. Fallback to local JSON assets if API is unavailable
    for (final path in _localLocationPaths) {
      try {
        final divs = _extractDivisions(json.decode(await rootBundle.loadString(path)));
        if (divs != null && divs.isNotEmpty) {
          _setDivisions(divs);
          debugPrint('Successfully loaded ${divs.length} divisions from $path');
          return;
        }
      } catch (e) {
        debugPrint('Failed to load locations from $path: $e');
      }
    }

    // 3. Fallback default divisions
    debugPrint('Warning: Falling back to default divisions');
    _setDivisions(_defaultDivisions.map((d) => Map<String, dynamic>.of(d)).toList());
  }

  /// Divisions list from a decoded locations JSON (`{divisions: [...]}`,
  /// `{data: [...]}` or a bare list).
  static List<dynamic>? _extractDivisions(dynamic data) {
    if (data is Map) {
      if (data.containsKey('divisions') && data['divisions'] is List) return data['divisions'] as List;
      if (data.containsKey('data') && data['data'] is List) return data['data'] as List;
      return null;
    }
    return data is List ? data : null;
  }

  Future<void> _tryMergeLocalDistricts(List<dynamic> apiDivs) async {
    try {
      final jsonString = await rootBundle.loadString(_localLocationsAsset);
      final data = json.decode(jsonString);
      if (data is Map && data.containsKey('divisions') && data['divisions'] is List) {
        final localDivs = data['divisions'] as List;
        for (var apiDiv in apiDivs) {
          final match = localDivs.firstWhere(
            (local) =>
                local['id'] == apiDiv['id'] ||
                (local['name_en'] != null &&
                    apiDiv['name_en'] != null &&
                    local['name_en'].toString().toLowerCase() == apiDiv['name_en'].toString().toLowerCase()),
            orElse: () => null,
          );
          if (match != null && match['districts'] is List) {
            apiDiv['districts'] = match['districts'];
          } else {
            apiDiv['districts'] = [];
          }
        }
      }
    } catch (e) {
      debugPrint('Error merging local districts: $e');
    }
  }

  /// Children of a location node: from the API (`/locations/{apiLevel}/{id}/children`)
  /// or, if that fails or is empty, the node's own [localKey] list.
  /// Returns null when neither source has any.
  Future<List<dynamic>?> _fetchChildren(dynamic parent, String apiLevel, String localKey, String label) async {
    final sourceId = parent['source_id']?.toString() ?? parent['id']?.toString();
    if (sourceId != null && sourceId.isNotEmpty) {
      try {
        final res = await locationChildRxObj.fetchChildren(apiLevel, sourceId);
        if (res.data != null && res.data!.isNotEmpty) {
          return res.data!.map((item) => item.toJson()).toList();
        }
      } catch (e) {
        debugPrint('Failed to fetch $label from API: $e');
      }
    }
    if (parent[localKey] is List && (parent[localKey] as List).isNotEmpty) {
      return parent[localKey];
    }
    return null;
  }

  Future<void> _onDivisionChanged(dynamic division) async {
    setState(() {
      _selectedDivision = division;
      _districts = [];
      _selectedDistrict = null;
      _upazilas = [];
      _selectedUpazila = null;
      _unions = [];
      _selectedUnion = null;
    });
    if (division == null) return;

    final districts = await _fetchChildren(division, 'divisions', 'districts', 'districts');
    if (districts != null && mounted) setState(() => _districts = districts);
  }

  Future<void> _onDistrictChanged(dynamic district) async {
    setState(() {
      _selectedDistrict = district;
      _upazilas = [];
      _selectedUpazila = null;
      _unions = [];
      _selectedUnion = null;
    });
    if (district == null) return;

    final upazilas = await _fetchChildren(district, 'districts', 'upazilas', 'upazilas');
    if (upazilas != null && mounted) setState(() => _upazilas = upazilas);
  }

  Future<void> _onUpazilaChanged(dynamic upazila) async {
    setState(() {
      _selectedUpazila = upazila;
      _unions = [];
      _selectedUnion = null;
    });
    if (upazila == null) return;

    final unions = await _fetchChildren(upazila, 'upazilas', 'unions', 'unions');
    if (unions != null && mounted) setState(() => _unions = unions);
  }

  void _onUnionChanged(dynamic union) {
    setState(() {
      _selectedUnion = union;
    });
  }

  /// First validation error, or null when the form can be submitted.
  String? _validationError(String contactName, String contactMobile, String detailedAddress) {
    if (contactName.isEmpty) return 'Please enter contact name';
    if (contactMobile.isEmpty || contactMobile.length < 8) return 'Please enter a valid mobile number';
    if (_selectedDivision == null) return 'Please select a division';
    if (_selectedDistrict == null) return 'Please select a district';
    if (_selectedUpazila == null) return 'Please select a upazila';
    if (detailedAddress.isEmpty) return 'Please enter detailed address';
    return null;
  }

  Future<void> _submitAddress() async {
    final contactName = _nameController.text.trim();
    final contactMobile = _mobileController.text.trim();
    final detailedAddress = _detailedAddressController.text.trim();

    final error = _validationError(contactName, contactMobile, detailedAddress);
    if (error != null) {
      ToastUtil.showErrorMessage(error);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final body = {
        'type': _selectedType,
        'contact_name': contactName,
        'contact_mobile': contactMobile,
        'division_id': _selectedDivision['id'],
        'district_id': _selectedDistrict['id'],
        'upazila_id': _selectedUpazila['id'],
        if (_selectedUnion != null) 'union_id': _selectedUnion['id'],
        'detailed_address': detailedAddress,
        'landmark': _landmarkController.text.trim(),
        'postcode': _postcodeController.text.trim(),
        'is_default': widget.address?.isDefault ?? false,
      };

      final bool isEditMode = widget.address != null && widget.address?.id != null;
      if (isEditMode) {
        await addressRxObj.updateAddress(widget.address!.id!.toString(), body);
        ToastUtil.showSuccessMessage('Address updated successfully!');
      } else {
        await AddressApi.instance.postAddress(body);
        ToastUtil.showSuccessMessage('Address added successfully!');
      }

      addressRxObj.fetchAddresses();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      String err = e.toString().replaceAll('Exception: ', '');
      ToastUtil.showErrorMessage(err.isNotEmpty ? err : 'Failed to add address');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.address != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            HeroPageHeader(
              title: isEdit ? 'Edit Address'.tr : 'Add New Address'.tr,
              subtitle: isEdit ? 'Update the contact and location details.' : 'Add a business, operational or shipping address.',
            ),
            Expanded(
              child: _isLoadingLocations
                  ? const Center(child: CircularProgressIndicator(color: primaryOrange))
                  : GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
                        child: AddressContentFrame(
                          child: Column(
                            children: [
                              AddressFormSection(
                                title: 'Address Type',
                                icon: Icons.category_outlined,
                                children: [
                                  AddressTypeChips(
                                    types: _addressTypes,
                                    selectedType: _selectedType,
                                    onSelected: (type) => setState(() => _selectedType = type),
                                  ),
                                ],
                              ),
                              UIHelper.verticalSpace(14.h),
                              _buildContactSection(),
                              UIHelper.verticalSpace(14.h),
                              _buildLocationSection(),
                              UIHelper.verticalSpace(14.h),
                              _buildDetailsSection(),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
        bottomNavigationBar: _isLoadingLocations
            ? null
            : AddressBottomBar(
                label: isEdit ? 'Update Address' : 'Save Address',
                icon: Icons.check_circle_outline_rounded,
                isLoading: _isLoading,
                onPressed: _submitAddress,
              ),
      ),
    );
  }

  Widget _buildContactSection() {
    return AddressFormSection(
      title: 'Contact',
      subtitle: 'Who should we reach at this address?',
      icon: Icons.person_outline_rounded,
      children: [
        AddressLabeledField(
          label: 'Contact Name *',
          field: AddressTextField(
            controller: _nameController,
            hint: 'e.g. Mohammad Rahim',
            icon: Icons.person_outline_rounded,
          ),
        ),
        AddressLabeledField(
          label: 'Contact Mobile *',
          isLast: true,
          field: AddressTextField(
            controller: _mobileController,
            hint: '+8801711111111',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return AddressFormSection(
      title: 'Location',
      subtitle: 'Choose each level in order.',
      icon: Icons.map_outlined,
      children: [
        AddressLabeledField(
          label: 'Division *',
          field: LocationDropdown(
            hint: 'Search & select Division',
            icon: Icons.public_rounded,
            items: _divisions,
            selectedValue: _selectedDivision,
            onChanged: _onDivisionChanged,
            searchController: _divisionSearchController,
          ),
        ),
        AddressLabeledField(
          label: 'District *',
          field: LocationDropdown(
            hint: _selectedDivision == null ? 'Select Division first' : 'Search & select District',
            icon: Icons.location_city_rounded,
            items: _districts,
            selectedValue: _selectedDistrict,
            onChanged: _selectedDivision == null ? null : _onDistrictChanged,
            searchController: _districtSearchController,
          ),
        ),
        AddressLabeledField(
          label: 'Upazila / Thana *',
          field: LocationDropdown(
            hint: _selectedDistrict == null ? 'Select District first' : 'Search & select Upazila',
            icon: Icons.apartment_rounded,
            items: _upazilas,
            selectedValue: _selectedUpazila,
            onChanged: _selectedDistrict == null ? null : _onUpazilaChanged,
            searchController: _upazilaSearchController,
          ),
        ),
        AddressLabeledField(
          label: 'Union (Optional)',
          isLast: true,
          field: LocationDropdown(
            hint: _selectedUpazila == null ? 'Select Upazila first' : 'Search & select Union (Optional)',
            icon: Icons.holiday_village_outlined,
            items: _unions,
            selectedValue: _selectedUnion,
            onChanged: _selectedUpazila == null ? null : _onUnionChanged,
            searchController: _unionSearchController,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    final landmark = AddressLabeledField(
      label: 'Landmark',
      isLast: true,
      field: AddressTextField(
        controller: _landmarkController,
        hint: 'e.g. Near City Hospital',
        icon: Icons.near_me_outlined,
      ),
    );
    final postcode = AddressLabeledField(
      label: 'Postcode',
      isLast: true,
      field: AddressTextField(
        controller: _postcodeController,
        hint: 'e.g. 1207',
        icon: Icons.markunread_mailbox_outlined,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
      ),
    );

    return AddressFormSection(
      title: 'Address Details',
      icon: Icons.home_work_outlined,
      children: [
        AddressLabeledField(
          label: 'Detailed Address *',
          field: AddressTextField(
            controller: _detailedAddressController,
            hint: 'e.g. House 42, Road 11, Mohammadpur, Dhaka',
            icon: Icons.location_on_outlined,
            maxLines: 3,
          ),
        ),
        // Side by side when there is room, stacked on narrow phones.
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth < 320
              ? Column(children: [landmark, UIHelper.verticalSpace(14.h), postcode])
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: landmark),
                    UIHelper.horizontalSpace(12.w),
                    Expanded(flex: 2, child: postcode),
                  ],
                ),
        ),
      ],
    );
  }
}
