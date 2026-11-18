import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../providers/dashboard_provider.dart';

class CheckoutDeliveryBanner extends StatelessWidget {
  final DashboardProvider dashboardProvider;
  final double shippingFee;

  const CheckoutDeliveryBanner({
    super.key,
    required this.dashboardProvider,
    required this.shippingFee,
  });

  @override
  Widget build(BuildContext context) {
    final formattedShipping = dashboardProvider.wholesaleCheckoutModel?.data?.shipping?.formatted ??
        "BDT ${shippingFee.toStringAsFixed(2)}";

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guaranteed delivery: Express Dispatch'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                UIHelper.verticalSpace(2.h),
                Text(
                  'Full refund & live tracking guarantee',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF10B981),
                  ),
                ),
                UIHelper.verticalSpace(8.h),
                Text(
                  'Shipping fee: $formattedShipping',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                UIHelper.verticalSpace(2.h),
                Row(
                  children: [
                    Text(
                      'Incoterm DAP',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColorsTheme.textMutedColor(context),
                      ),
                    ),
                    UIHelper.horizontalSpace(4.w),
                    Icon(Icons.info_outline_rounded, size: 13.sp, color: AppColorsTheme.textMutedColor(context)),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: AppColorsTheme.textMutedColor(context)),
        ],
      ),
    );
  }
}
