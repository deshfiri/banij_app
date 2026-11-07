import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common_widget/finance_card_widget.dart';
import '../../../constants/color.dart';
import '../../../constants/image_const.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/ui_helpers.dart';

class BusinessScreenBody extends StatelessWidget {
  final VoidCallback? onOpenDrawer;

  const BusinessScreenBody({
    super.key,
    this.onOpenDrawer,
  });

  void _handleVerificationTap(BuildContext context) {
    Navigator.pushNamed(context, Routes.verificationHistoryScreen);
  }

  void _handleSubscriptionTap(BuildContext context) {
    Navigator.pushNamed(context, Routes.accountScreen, arguments: 'Package');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: AppColorsTheme.background(context),
      child: Column(
        children: [
          // Business Top Header / AppBar Stack (Fixed Centered Logo & Left Drawer Menu Icon)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColorsTheme.cardBg(context),
              border: Border(
                bottom: BorderSide(
                  color: AppColorsTheme.borderColor(context),
                  width: 1.w,
                ),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 100% Dead-Centered Logo
                Center(
                  child: Image.asset(
                    isDark ? whiteLogo : logo,
                    width: 110.w,
                    height: 36.h,
                    fit: BoxFit.contain,
                  ),
                ),
                // Left Drawer Menu Icon
                if (onOpenDrawer != null)
                  Positioned(
                    left: 0,
                    child: IconButton(
                      onPressed: onOpenDrawer,
                      icon: Icon(
                        Icons.menu_rounded,
                        color: AppColorsTheme.textMainColor(context),
                        size: 24.sp,
                      ),
                    ),
                  ),
                // Right Action Icons: Notifications & Profile
                Positioned(
                  right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.notificationScreen);
                        },
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              color: AppColorsTheme.textMainColor(context),
                              size: 22.sp,
                            ),
                            Positioned(
                              top: -2.h,
                              right: -2.w,
                              child: Container(
                                width: 8.w,
                                height: 8.h,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.accountScreen);
                        },
                        icon: Icon(
                          Icons.person_outline_rounded,
                          color: AppColorsTheme.textMainColor(context),
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body Content with Cards
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'business'.tr,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: AppColorsTheme.textMainColor(context),
                              ),
                            ),
                            UIHelper.verticalSpace(2.h),
                            Text(
                              'business_subtitle'.tr,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColorsTheme.textMutedColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: primaryOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'Workspace',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryOrange,
                          ),
                        ),
                      ),
                    ],
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
