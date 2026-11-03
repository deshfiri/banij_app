import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../constants/color.dart';
import '../../../common_widget/finance_card_widget.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/ui_helpers.dart';

class BusinessScreenBody extends StatelessWidget {
  const BusinessScreenBody({super.key});

  void _handleVerificationTap(BuildContext context) {
    Navigator.pushNamed(context, Routes.verificationHistoryScreen);
  }

  void _handleSubscriptionTap(BuildContext context) {
    Navigator.pushNamed(context, Routes.accountScreen, arguments: 'Package');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorsTheme.background(context),
      child: Column(
        children: [
          // Business Header / AppBar
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: AppColorsTheme.cardBg(context),
              border: Border(
                bottom: BorderSide(color: AppColorsTheme.borderColor(context), width: 1.w),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Text(
                  'business'.tr,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
              ),
            ),
          ),

          // Body Content with Cards
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'business_management'.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(6.h),
                  Text(
                    'business_subtitle'.tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(20.h),

                  // Card 1: Verification
                  FinanceCardWidget(
                    title: 'verification'.tr,
                    subtitle: 'verification_subtitle'.tr,
                    iconData: Icons.verified_user_outlined,
                    onTap: () => _handleVerificationTap(context),
                  ),
                  UIHelper.verticalSpace(16.h),

                  // Card 2: Subscription
                  FinanceCardWidget(
                    title: 'subscription'.tr,
                    subtitle: 'subscription_subtitle'.tr,
                    iconData: Icons.card_membership_outlined,
                    onTap: () => _handleSubscriptionTap(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
