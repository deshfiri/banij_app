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
      'type': 'BUSINESS',
      'phone': '+88019005831',
      'address': 'dadad, Bokshiganj, Jamalpur, Mymensingh, 1207',
      'isDefault': false,
    },
    {
      'name': 'MD Hira',
      'type': 'BUSINESS',
      'phone': '+8801619005831',
      'address': 'eqeqeqeqe, Rajapur, Jhalakathi, Barisal, aeaeae',
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

  void _navigateToAddAddress([AddressItemModel? address]) {
    Navigator.pushNamed(context, Routes.addAddressScreen, arguments: address).then((_) {
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
        backgroundColor: AppColorsTheme.background(context),
        elevation: 0,
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
                onPressed: () => _navigateToAddAddress(),
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
                      onPressed: () => _navigateToAddAddress(),
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

                  // Saved Address List
                  hasApiAddresses
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: apiAddresses.length,
                          itemBuilder: (context, index) {
                            final item = apiAddresses[index];
                            return _buildAddressCard(
                              context,
                              name: item.contactName ?? item.recipientName,
                              type: item.type ?? 'BUSINESS',
                              phone: item.contactMobile ?? item.phone,
                              fullAddress: item.fullAddressFormatted,
                              isDefault: item.isDefault == true,
                              onEdit: () => _navigateToAddAddress(item),
                              onSetDefault: () => ToastUtil.showSuccessMessage('Address set as default'),
                              onArchive: () => ToastUtil.showSuccessMessage('Address archived'),
                            );
                          },
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _dummyAddresses.length,
                          itemBuilder: (context, index) {
                            final item = _dummyAddresses[index];
                            return _buildAddressCard(
                              context,
                              name: item['name'],
                              type: item['type'],
                              phone: item['phone'],
                              fullAddress: item['address'],
                              isDefault: item['isDefault'] == true,
                              onEdit: () => _navigateToAddAddress(),
                              onSetDefault: () {
                                setState(() {
                                  for (var a in _dummyAddresses) {
                                    a['isDefault'] = false;
                                  }
                                  item['isDefault'] = true;
                                });
                                ToastUtil.showSuccessMessage('Address set as default');
                              },
                              onArchive: () {
                                setState(() {
                                  _dummyAddresses.removeAt(index);
                                });
                                ToastUtil.showSuccessMessage('Address archived');
                              },
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context, {
    required String name,
    required String type,
    required String phone,
    required String fullAddress,
    required bool isDefault,
    VoidCallback? onEdit,
    VoidCallback? onSetDefault,
    VoidCallback? onArchive,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDefault ? primaryOrange : AppColorsTheme.borderColor(context),
          width: isDefault ? 1.5.w : 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDefault ? primaryOrange : Colors.black).withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(11.w),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.location_on_rounded, color: primaryOrange, size: 22.sp),
              ),
              UIHelper.horizontalSpace(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isDefault) ...[
                          UIHelper.horizontalSpace(8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: primaryOrange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 10.sp, color: primaryOrange),
                                UIHelper.horizontalSpace(3.w),
                                Text(
                                  'DEFAULT',
                                  style: TextStyle(
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w900,
                                    color: primaryOrange,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    UIHelper.verticalSpace(4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: AppColorsTheme.background(context),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: AppColorsTheme.borderColor(context)),
                      ),
                      child: Text(
                        '${type.toUpperCase()} ADDRESS',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColorsTheme.textMutedColor(context),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, size: 20.sp, color: AppColorsTheme.textMutedColor(context)),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit?.call();
                  } else if (value == 'default') {
                    onSetDefault?.call();
                  } else if (value == 'archive') {
                    onArchive?.call();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 16.sp, color: primaryOrange),
                        UIHelper.horizontalSpace(8.w),
                        Text('Edit', style: TextStyle(fontSize: 12.5.sp)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'default',
                    child: Row(
                      children: [
                        Icon(Icons.star_outline_rounded, size: 16.sp, color: Colors.amber),
                        UIHelper.horizontalSpace(8.w),
                        Text('Set as default', style: TextStyle(fontSize: 12.5.sp)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(Icons.archive_outlined, size: 16.sp, color: Colors.redAccent),
                        UIHelper.horizontalSpace(8.w),
                        Text('Archive', style: TextStyle(fontSize: 12.5.sp, color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          UIHelper.verticalSpace(14.h),
          if (phone.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColorsTheme.background(context),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_android_rounded, size: 13.sp, color: primaryOrange),
                  UIHelper.horizontalSpace(6.w),
                  Text(
                    phone,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                ],
              ),
            ),
            UIHelper.verticalSpace(10.h),
          ],
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColorsTheme.background(context),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColorsTheme.borderColor(context).withValues(alpha: 0.6)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.map_rounded, size: 15.sp, color: primaryOrange),
                UIHelper.horizontalSpace(8.w),
                Expanded(
                  child: Text(
                    fullAddress.isNotEmpty ? fullAddress : 'No detailed address provided',
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColorsTheme.textMainColor(context),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
              borderRadius: BorderRadius.circular(20.r),
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
