import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../providers/dashboard_provider.dart';
import 'checkout_ui.dart';

/// Coupon input with Apply (or Remove when a coupon is applied).
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
    final appliedCouponText =
        dashboardProvider.wholesaleCheckoutModel?.data?.appliedCoupon ?? dashboardProvider.checkoutResponseModel?.data?.coupon;
    final hasCoupon = appliedCouponText != null && appliedCouponText.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isApplying = dashboardProvider.isApplyingCoupon;

    return CheckoutSectionCard(
      title: 'Apply Voucher'.tr,
      icon: Icons.local_offer_outlined,
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 6.h, 6.w, 6.h),
        decoration: BoxDecoration(
          color: isDark ? AppColorsTheme.innerCardBg(context) : lightBackground,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: hasCoupon ? successGreen.withValues(alpha: 0.5) : primaryOrange.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasCoupon ? Icons.check_circle_rounded : Icons.confirmation_number_outlined,
              size: 18.sp,
              color: hasCoupon ? successGreen : primaryOrange,
            ),
            UIHelper.horizontalSpace(8.w),
            Expanded(
              child: TextField(
                controller: couponController,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColorsTheme.textMainColor(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter coupon code'.tr,
                  hintStyle: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (hasCoupon)
              TextButton(
                onPressed: isApplying ? null : () => dashboardProvider.removeWholesaleCoupon(),
                style: TextButton.styleFrom(foregroundColor: errorRed),
                child: Text('Remove'.tr, style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800)),
              )
            else
              CheckoutPillButton(
                onTap: isApplying ? null : () => dashboardProvider.applyWholesaleCoupon(couponController.text),
                child: isApplying
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Apply'.tr,
                        style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
