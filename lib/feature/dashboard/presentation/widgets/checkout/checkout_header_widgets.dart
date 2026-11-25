import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../common_widget/gradient_button.dart';
import '../../../../../constants/color.dart';
import '../../../../../helpers/all_routes.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/checkout_response_model.dart';

/// Translucent "Protected by Trade Assurance" pill shown on the checkout hero.
class CheckoutTrustPill extends StatelessWidget {
  const CheckoutTrustPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_rounded, size: 13.sp, color: Colors.white),
          UIHelper.horizontalSpace(5.w),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${'Protected by'.tr} '),
                  TextSpan(text: 'Trade Assurance'.tr, style: const TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Orange gradient banner with the checkout package name and validity.
class CheckoutPackageBanner extends StatelessWidget {
  final CheckoutPackage package;

  const CheckoutPackageBanner({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryOrange, secondaryOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: primaryOrange.withValues(alpha: 0.3), blurRadius: 14.r, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 22.sp),
          ),
          UIHelper.horizontalSpace(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.name ?? 'Package'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                if (package.validityDays != null) ...[
                  UIHelper.verticalSpace(2.h),
                  Text(
                    'Validity: @days days'.trParams({'days': '${package.validityDays}'}),
                    style: TextStyle(fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.88)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Order placed" dialog (pay-later orders); its button closes the dialog and replaces the
/// route with the dashboard using [hostContext] (the checkout screen).
class CheckoutSuccessDialog extends StatelessWidget {
  final BuildContext hostContext;

  const CheckoutSuccessDialog({super.key, required this.hostContext});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CheckoutSuccessDialog(hostContext: context),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    final context = hostContext;

    return Dialog(
      backgroundColor: AppColorsTheme.cardBg(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(22.w, 26.h, 22.w, 22.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(color: successGreen.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [successGreen, successGreenDark]),
                  boxShadow: [
                    BoxShadow(color: successGreen.withValues(alpha: 0.35), blurRadius: 14.r, offset: const Offset(0, 5)),
                  ],
                ),
                child: Icon(Icons.check_rounded, size: 36.sp, color: Colors.white),
              ),
            ),
            UIHelper.verticalSpace(18.h),
            Text(
              'Order placed'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w900,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(6.h),
            Text(
              'Your order has been placed. You can follow its payment and delivery in Orders.'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, height: 1.4, color: AppColorsTheme.textMutedColor(context)),
            ),
            UIHelper.verticalSpace(22.h),
            GradientButton(
              label: 'Back to Dashboard'.tr,
              trailingIcon: Icons.arrow_forward_rounded,
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(context, Routes.dashboardScreen);
              },
            ),
          ],
        ),
      ),
    );
  }
}
