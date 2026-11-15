import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../model/address_model.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  AddressResponseModel? _addressResponseModel;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _dummyAddresses = [
    {
      'name': 'Md Hira',
      'type': 'Business address',
      'phone': '+88019005831',
      'address': 'dadad, Bokshiganj, Jamalpur, Mymensingh',
      'isDefault': false,
    },
    {
      'name': 'MD Hira',
      'type': 'Business address',
      'phone': '+8801619005831',
      'address': 'eqeqeqeqe, Rajapur, Jhalakathi, Barisal',
      'isDefault': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() => _isLoading = true);
    try {
      final res = await addressRxObj.fetchAddresses();
      if (mounted) {
        setState(() {
          _addressResponseModel = res;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToAddAddress() {
    Navigator.pushNamed(context, Routes.addAddressScreen).then((_) {
      _fetchAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiAddresses = _addressResponseModel?.data ?? [];
    final hasApiAddresses = apiAddresses.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppColorsTheme.cardBg(context),
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColorsTheme.textMainColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Addresses',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _navigateToAddAddress,
                icon: Icon(Icons.add_rounded, size: 16.sp),
                label: Text('Add address', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildAddressShimmer(context)
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Addresses',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(4.h),
                  Text(
                    'Your business and operational addresses.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _navigateToAddAddress,
                      icon: Icon(Icons.add_location_alt_rounded, size: 18.sp),
                      label: Text('Add address', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(20.h),

                  // Saved Address List (API or dummy fallback)
                  hasApiAddresses
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: apiAddresses.length,
                          itemBuilder: (context, index) {
                            final item = apiAddresses[index];
                            final isDefault = item.isDefault == true;
                            return Container(
                              margin: EdgeInsets.only(bottom: 14.h),
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: AppColorsTheme.cardBg(context),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: isDefault ? primaryOrange : AppColorsTheme.borderColor(context),
                                  width: isDefault ? 1.5.w : 1.w,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.contactName ?? item.recipientName,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColorsTheme.textMainColor(context),
                                    ),
                                  ),
                                  UIHelper.verticalSpace(4.h),
                                  Text(
                                    '${(item.type ?? "Business").toUpperCase()} address • ${item.contactMobile ?? item.phone}',
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      color: AppColorsTheme.textMutedColor(context),
                                    ),
                                  ),
                                  UIHelper.verticalSpace(8.h),
                                  Text(
                                    item.fullAddressFormatted.isNotEmpty ? item.fullAddressFormatted : 'No address details provided',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: AppColorsTheme.textMainColor(context),
                                    ),
                                  ),
                                  UIHelper.verticalSpace(14.h),
                                  Row(
                                    children: [
                                      OutlinedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, Routes.addAddressScreen, arguments: item).then((_) {
                                            _fetchAddresses();
                                          });
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                                          side: BorderSide(color: AppColorsTheme.borderColor(context)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                        ),
                                        child: Text('Edit', style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMainColor(context))),
                                      ),
                                      UIHelper.horizontalSpace(8.w),
                                      OutlinedButton(
                                        onPressed: () {
                                          ToastUtil.showSuccessMessage('Address set as default');
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                                          side: BorderSide(color: isDefault ? primaryOrange : AppColorsTheme.borderColor(context)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                        ),
                                        child: Text(
                                          isDefault ? 'Default' : 'Set as default',
                                          style: TextStyle(fontSize: 12.sp, color: isDefault ? primaryOrange : AppColorsTheme.textMainColor(context), fontWeight: isDefault ? FontWeight.bold : FontWeight.normal),
                                        ),
                                      ),
                                      UIHelper.horizontalSpace(8.w),
                                      TextButton(
                                        onPressed: () {
                                          ToastUtil.showSuccessMessage('Address archived');
                                        },
                                        child: Text('Archive', style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context))),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _dummyAddresses.length,
                          itemBuilder: (context, index) {
                            final item = _dummyAddresses[index];
                            final isDefault = item['isDefault'] == true;
                            return Container(
                              margin: EdgeInsets.only(bottom: 14.h),
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: AppColorsTheme.cardBg(context),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: isDefault ? primaryOrange : AppColorsTheme.borderColor(context),
                                  width: isDefault ? 1.5.w : 1.w,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColorsTheme.textMainColor(context),
                                    ),
                                  ),
                                  UIHelper.verticalSpace(4.h),
                                  Text(
                                    '${item['type']} • ${item['phone']}',
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      color: AppColorsTheme.textMutedColor(context),
                                    ),
                                  ),
                                  UIHelper.verticalSpace(8.h),
                                  Text(
                                    item['address'],
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: AppColorsTheme.textMainColor(context),
                                    ),
                                  ),
                                  UIHelper.verticalSpace(14.h),
                                  Row(
                                    children: [
                                      OutlinedButton(
                                        onPressed: _navigateToAddAddress,
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                                          side: BorderSide(color: AppColorsTheme.borderColor(context)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                        ),
                                        child: Text('Edit', style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMainColor(context))),
                                      ),
                                      UIHelper.horizontalSpace(8.w),
                                      OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            for (var a in _dummyAddresses) {
                                              a['isDefault'] = false;
                                            }
                                            item['isDefault'] = true;
                                          });
                                          ToastUtil.showSuccessMessage('Address set as default');
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                                          side: BorderSide(color: isDefault ? primaryOrange : AppColorsTheme.borderColor(context)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                        ),
                                        child: Text(
                                          isDefault ? 'Default' : 'Set as default',
                                          style: TextStyle(fontSize: 12.sp, color: isDefault ? primaryOrange : AppColorsTheme.textMainColor(context), fontWeight: isDefault ? FontWeight.bold : FontWeight.normal),
                                        ),
                                      ),
                                      UIHelper.horizontalSpace(8.w),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _dummyAddresses.removeAt(index);
                                          });
                                          ToastUtil.showSuccessMessage('Address archived');
                                        },
                                        child: Text('Archive', style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context))),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildAddressShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        itemCount: 2,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 14.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120.w, height: 16.h, color: Colors.white),
                UIHelper.verticalSpace(8.h),
                Container(width: 180.w, height: 12.h, color: Colors.white),
                UIHelper.verticalSpace(12.h),
                Container(width: double.infinity, height: 14.h, color: Colors.white),
              ],
            ),
          );
        },
      ),
    );
  }
}
