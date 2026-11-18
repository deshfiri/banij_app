import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../providers/dashboard_provider.dart';

class CheckoutVoucherSection extends StatelessWidget {
  final DashboardProvider dashboardProvider;
  final TextEditingController couponController;

  const CheckoutVoucherSection({
    super.key,
    required this.dashboardProvider,
    required this.couponController,
  });

  @override
  Widget build(BuildContext context) {
    final appliedCouponText = dashboardProvider.wholesaleCheckoutModel?.data?.appliedCoupon ??
        dashboardProvider.checkoutResponseModel?.data?.coupon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Apply Voucher'.tr,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
        UIHelper.verticalSpace(10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColorsTheme.cardBg(context),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColorsTheme.borderColor(context)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: couponController,
                  style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMainColor(context)),
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code'.tr,
                    hintStyle: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (appliedCouponText != null && appliedCouponText.isNotEmpty) ...[
                TextButton(
                  onPressed: dashboardProvider.isApplyingCoupon ? null : () => dashboardProvider.removeWholesaleCoupon(),
                  child: Text(
                    'Remove'.tr,
                    style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: dashboardProvider.isApplyingCoupon
                      ? null
                      : () => dashboardProvider.applyWholesaleCoupon(couponController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    elevation: 0,
                  ),
                  child: dashboardProvider.isApplyingCoupon
                      ? SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Apply'.tr,
                          style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
