import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../constants/color.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../data/address_api.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
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
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    List<String> pathsToTry = [
      'assets/json/bd_locations.json',
      'json/bd_locations.json',
      'bd_locations.json',
    ];

    for (final path in pathsToTry) {
      try {
        final jsonString = await rootBundle.loadString(path);
        final data = json.decode(jsonString);

        List<dynamic>? divs;
        if (data is Map) {
          if (data.containsKey('divisions') && data['divisions'] is List) {
            divs = data['divisions'] as List;
          } else if (data.containsKey('data') && data['data'] is List) {
            divs = data['data'] as List;
          }
        } else if (data is List) {
          divs = data;
        }

        if (divs != null && divs.isNotEmpty) {
          setState(() {
            _divisions = divs!;
            _isLoadingLocations = false;
          });
          debugPrint('Successfully loaded ${_divisions.length} divisions from $path');
          return;
        }
      } catch (e) {
        debugPrint('Failed to load locations from $path: $e');
      }
    }

    // Fallback default divisions if asset loading fails across all paths
    debugPrint('Warning: Falling back to default divisions');
    setState(() {
      _divisions = [
        {"id": 1, "name_en": "Barisal", "name_bn": "বরিশাল", "districts": []},
        {"id": 2, "name_en": "Chattagram", "name_bn": "চট্টগ্রাম", "districts": []},
        {"id": 3, "name_en": "Dhaka", "name_bn": "ঢাকা", "districts": []},
        {"id": 4, "name_en": "Khulna", "name_bn": "খুলনা", "districts": []},
        {"id": 5, "name_en": "Mymensingh", "name_bn": "ময়মনসিংহ", "districts": []},
        {"id": 6, "name_en": "Rajshahi", "name_bn": "রাজশাহী", "districts": []},
        {"id": 7, "name_en": "Rangpur", "name_bn": "রংপুর", "districts": []},
        {"id": 8, "name_en": "Sylhet", "name_bn": "সিলেট", "districts": []},
      ];
      _isLoadingLocations = false;
    });
  }

  void _onDivisionChanged(dynamic division) {
    setState(() {
      _selectedDivision = division;
      _districts = division != null && division['districts'] is List ? division['districts'] : [];
      _selectedDistrict = null;
      _upazilas = [];
      _selectedUpazila = null;
      _unions = [];
      _selectedUnion = null;
    });
  }

  void _onDistrictChanged(dynamic district) {
    setState(() {
      _selectedDistrict = district;
      _upazilas = district != null && district['upazilas'] is List ? district['upazilas'] : [];
      _selectedUpazila = null;
      _unions = [];
      _selectedUnion = null;
    });
  }

  void _onUpazilaChanged(dynamic upazila) {
    setState(() {
      _selectedUpazila = upazila;
      _unions = upazila != null && upazila['unions'] is List ? upazila['unions'] : [];
      _selectedUnion = null;
    });
  }

  void _onUnionChanged(dynamic union) {
    setState(() {
      _selectedUnion = union;
    });
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

  Future<void> _submitAddress() async {
    final contactName = _nameController.text.trim();
    final contactMobile = _mobileController.text.trim();
    final detailedAddress = _detailedAddressController.text.trim();

    if (contactName.isEmpty) {
      ToastUtil.showErrorMessage('Please enter contact name');
      return;
    }

    if (contactMobile.isEmpty || contactMobile.length < 8) {
      ToastUtil.showErrorMessage('Please enter a valid mobile number');
      return;
    }

    if (_selectedDivision == null) {
      ToastUtil.showErrorMessage('Please select a division');
      return;
    }

    if (_selectedDistrict == null) {
      ToastUtil.showErrorMessage('Please select a district');
      return;
    }

    if (_selectedUpazila == null) {
      ToastUtil.showErrorMessage('Please select a upazila');
      return;
    }

    if (detailedAddress.isEmpty) {
      ToastUtil.showErrorMessage('Please enter detailed address');
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
      };

      await AddressApi.instance.postAddress(body);

      ToastUtil.showSuccessMessage('Address added successfully!');
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
    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppColorsTheme.cardBg(context),
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColorsTheme.textMainColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add New Address'.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoadingLocations
            ? Center(child: CircularProgressIndicator(color: primaryOrange))
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address Type Choice Chips
                    Text(
                      'Address Type',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(8.h),
                    Row(
                      children: _addressTypes.map((type) {
                        final isSelected = _selectedType == type;
                        return Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: ChoiceChip(
                            label: Text(type.toUpperCase()),
                            selected: isSelected,
                            selectedColor: primaryOrange,
                            backgroundColor: AppColorsTheme.cardBg(context),
                            labelStyle: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColorsTheme.textMainColor(context),
                            ),
                            side: BorderSide(
                              color: isSelected ? primaryOrange : AppColorsTheme.borderColor(context),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedType = type;
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    UIHelper.verticalSpace(20.h),

                    // Form Section Container
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: AppColorsTheme.cardBg(context),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColorsTheme.borderColor(context),
                          width: 1.w,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Field 1: Contact Name
                          _buildLabel('Contact Name *'),
                          UIHelper.verticalSpace(6.h),
                          _buildTextField(
                            controller: _nameController,
                            hint: 'e.g. Mohammad Rahim',
                            icon: Icons.person_outline_rounded,
                          ),
                          UIHelper.verticalSpace(16.h),

                          // Field 2: Contact Mobile
                          _buildLabel('Contact Mobile *'),
                          UIHelper.verticalSpace(6.h),
                          _buildTextField(
                            controller: _mobileController,
                            hint: '+8801711111111',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          UIHelper.verticalSpace(16.h),

                          // Location Cascading Dropdowns with Search
                          _buildLabel('Division *'),
                          UIHelper.verticalSpace(6.h),
                          _buildSearchableDropdownSelector(
                            hint: 'Search & select Division',
                            items: _divisions,
                            selectedValue: _selectedDivision,
                            onChanged: _onDivisionChanged,
                            searchController: _divisionSearchController,
                          ),
                          UIHelper.verticalSpace(16.h),

                          _buildLabel('District *'),
                          UIHelper.verticalSpace(6.h),
                          _buildSearchableDropdownSelector(
                            hint: _selectedDivision == null ? 'Select Division first' : 'Search & select District',
                            items: _districts,
                            selectedValue: _selectedDistrict,
                            onChanged: _selectedDivision == null ? null : _onDistrictChanged,
                            searchController: _districtSearchController,
                          ),
                          UIHelper.verticalSpace(16.h),

                          _buildLabel('Upazila / Thana *'),
                          UIHelper.verticalSpace(6.h),
                          _buildSearchableDropdownSelector(
                            hint: _selectedDistrict == null ? 'Select District first' : 'Search & select Upazila',
                            items: _upazilas,
                            selectedValue: _selectedUpazila,
                            onChanged: _selectedDistrict == null ? null : _onUpazilaChanged,
                            searchController: _upazilaSearchController,
                          ),
                          UIHelper.verticalSpace(16.h),

                          _buildLabel('Union (Optional)'),
                          UIHelper.verticalSpace(6.h),
                          _buildSearchableDropdownSelector(
                            hint: _selectedUpazila == null ? 'Select Upazila first' : 'Search & select Union (Optional)',
                            items: _unions,
                            selectedValue: _selectedUnion,
                            onChanged: _selectedUpazila == null ? null : _onUnionChanged,
                            searchController: _unionSearchController,
                          ),
                          UIHelper.verticalSpace(16.h),

                          // Field 3: Detailed Address
                          _buildLabel('Detailed Address *'),
                          UIHelper.verticalSpace(6.h),
                          _buildTextField(
                            controller: _detailedAddressController,
                            hint: 'e.g. House 42, Road 11, Mohammadpur, Dhaka',
                            icon: Icons.location_on_outlined,
                            maxLines: 2,
                          ),
                          UIHelper.verticalSpace(16.h),

                          // Field 4 & 5: Landmark & Postcode Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Landmark'),
                                    UIHelper.verticalSpace(6.h),
                                    _buildTextField(
                                      controller: _landmarkController,
                                      hint: 'e.g. Near City Hospital',
                                      icon: Icons.near_me_outlined,
                                    ),
                                  ],
                                ),
                              ),
                              UIHelper.horizontalSpace(12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Postcode'),
                                    UIHelper.verticalSpace(6.h),
                                    _buildTextField(
                                      controller: _postcodeController,
                                      hint: 'e.g. 1207',
                                      icon: Icons.markunread_mailbox_outlined,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    UIHelper.verticalSpace(24.h),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save Address',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.5.sp,
        fontWeight: FontWeight.bold,
        color: AppColorsTheme.textMainColor(context),
      ),
    );
  }

  Widget _buildSearchableDropdownSelector({
    required String hint,
    required List<dynamic> items,
    required dynamic selectedValue,
    required ValueChanged<dynamic>? onChanged,
    required TextEditingController searchController,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorsTheme.background(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<dynamic>(
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(
              fontSize: 12.5.sp,
              color: AppColorsTheme.textMutedColor(context),
            ),
          ),
          items: items.map((item) {
            final name = item['name_en'] ?? item['name'] ?? 'Item';
            return DropdownMenuItem<dynamic>(
              value: item,
              child: Text(
                name.toString(),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
            );
          }).toList(),
          value: selectedValue,
          onChanged: onChanged,
          buttonStyleData: ButtonStyleData(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(Icons.arrow_drop_down_rounded, color: primaryOrange),
            iconSize: 24.sp,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 250.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: AppColorsTheme.cardBg(context),
            ),
          ),
          dropdownSearchData: DropdownSearchData(
            searchController: searchController,
            searchInnerWidgetHeight: 55.h,
            searchInnerWidget: Container(
              height: 55.h,
              padding: EdgeInsets.all(8.w),
              child: TextFormField(
                controller: searchController,
                style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMainColor(context)),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                  hintText: 'Search...',
                  hintStyle: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColorsTheme.borderColor(context)),
                  ),
                ),
              ),
            ),
            searchMatchFn: (item, searchValue) {
              final name = (item.child as Text).data ?? '';
              return name.toLowerCase().contains(searchValue.toLowerCase());
            },
          ),
          onMenuStateChange: (isOpen) {
            if (!isOpen) {
              searchController.clear();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.background(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 12.h : 0),
            child: Icon(icon, size: 18.sp, color: primaryOrange),
          ),
          UIHelper.horizontalSpace(10.w),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColorsTheme.textMainColor(context),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 12.5.sp,
                  color: AppColorsTheme.textMutedColor(context),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
