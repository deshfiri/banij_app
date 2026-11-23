import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../providers/dashboard_provider.dart';
import 'checkout_ui.dart';

/// Delivery section: guaranteed dispatch, refund guarantee, shipping fee, incoterm.
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
    final formattedShipping =
        dashboardProvider.wholesaleCheckoutModel?.data?.shipping?.formatted ?? "BDT ${shippingFee.toStringAsFixed(2)}";
    final muted = AppColorsTheme.textMutedColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CheckoutSectionCard(
      title: 'Delivery'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CheckoutIconBadge(icon: Icons.local_shipping_rounded, color: successGreen),
              UIHelper.horizontalSpace(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guaranteed delivery: Express Dispatch'.tr,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(3.h),
                    Row(
                      children: [
                        Icon(Icons.verified_rounded, size: 13.sp, color: successGreen),
                        UIHelper.horizontalSpace(4.w),
                        Flexible(
                          child: Text(
                            'Full refund & live tracking guarantee'.tr,
                            style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w700, color: successGreen),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isDark ? AppColorsTheme.innerCardBg(context) : lightBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Shipping fee: @fee'.trParams({'fee': formattedShipping}),
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                ),
                Text('Incoterm DAP'.tr, style: TextStyle(fontSize: 11.5.sp, color: muted)),
                UIHelper.horizontalSpace(4.w),
                Icon(Icons.info_outline_rounded, size: 13.sp, color: muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
