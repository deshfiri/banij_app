import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/all_routes.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../providers/dashboard_provider.dart';

class CheckoutAddressCard extends StatelessWidget {
  final DashboardProvider dashboardProvider;

  const CheckoutAddressCard({
    super.key,
    required this.dashboardProvider,
  });

  void _showAddressSelectionSheet(BuildContext context) {
    final addresses = dashboardProvider.addressResponseModel?.data ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsTheme.cardBg(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Address'.tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppColorsTheme.textMainColor(context)),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            UIHelper.verticalSpace(12.h),
            if (addresses.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.location_off_outlined, size: 40.sp, color: AppColorsTheme.textMutedColor(context)),
                      UIHelper.verticalSpace(8.h),
                      Text(
                        'Address is not found'.tr,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          color: AppColorsTheme.textMutedColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300.h),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final addr = addresses[index];
                    final isSelected = dashboardProvider.selectedAddress?.id == addr.id;
                    return Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      decoration: BoxDecoration(
                        color: AppColorsTheme.background(context),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected ? primaryOrange : AppColorsTheme.borderColor(context),
                          width: isSelected ? 1.5.w : 1.w,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected ? primaryOrange : AppColorsTheme.textMutedColor(context),
                        ),
                        title: Text(
                          addr.recipientName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColorsTheme.textMainColor(context),
                          ),
                        ),
                        subtitle: Text(
                          addr.fullAddressFormatted.isNotEmpty ? addr.fullAddressFormatted : 'No address details',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColorsTheme.textMutedColor(context),
                          ),
                        ),
                        onTap: () {
                          dashboardProvider.selectWholesaleAddress(addr);
                          Navigator.pop(ctx);
                        },
                      ),
                    );
                  },
                ),
              ),
            UIHelper.verticalSpace(16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, Routes.addAddressScreen).then((_) {
                    dashboardProvider.fetchCheckoutState();
                  });
                },
                icon: Icon(Icons.add, size: 18.sp),
                label: Text(
                  'Add New Address'.tr,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (dashboardProvider.isLoadingCheckout) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(
          height: 72.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
      );
    }

    final selectedAddress = dashboardProvider.selectedAddress;

    return GestureDetector(
      onTap: () {
        if (selectedAddress == null) {
          Navigator.pushNamed(context, Routes.addAddressScreen).then((_) {
            dashboardProvider.fetchCheckoutState();
          });
        } else {
          _showAddressSelectionSheet(context);
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColorsTheme.cardBg(context),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColorsTheme.borderColor(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: primaryOrange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_on_outlined, color: primaryOrange, size: 22.sp),
            ),
            UIHelper.horizontalSpace(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedAddress != null ? selectedAddress.recipientName : 'Address is not found'.tr,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(2.h),
                  Text(
                    selectedAddress != null
                        ? selectedAddress.fullAddressFormatted
                        : 'Add your address for shipping options and accurate delivery.'.tr,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: AppColorsTheme.textMutedColor(context)),
          ],
        ),
      ),
    );
  }
}
