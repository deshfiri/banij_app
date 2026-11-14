import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constants/color.dart';
import '../../../constants/image_const.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/supplier_dashboard_provider.dart';

class BusinessScreenBody extends StatelessWidget {
  final VoidCallback? onOpenDrawer;

  const BusinessScreenBody({
    super.key,
    this.onOpenDrawer,
  });

  void _handleProfileTap(BuildContext context) {
    try {
      final dashProvider = Provider.of<DashboardProvider>(context, listen: false);
      dashProvider.setBottomNavIndex(4);
      return;
    } catch (_) {}
    try {
      final supplierProvider = Provider.of<SupplierDashboardProvider>(context, listen: false);
      supplierProvider.setBottomNavIndex(4);
      return;
    } catch (_) {}
    Navigator.pushNamed(context, Routes.accountScreen);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> businessItems = [
      {
        'title': 'Verification',
        'subtitle': 'KYC & identity verification',
        'icon': Icons.verified_user_rounded,
        'onTap': (BuildContext ctx) => Navigator.pushNamed(ctx, Routes.verificationHistoryScreen),
      },
      {
        'title': 'Subscription',
        'subtitle': 'Manage packages & B2B plans',
        'icon': Icons.credit_card_rounded,
        'onTap': (BuildContext ctx) => Navigator.pushNamed(ctx, Routes.accountScreen, arguments: 'Package'),
      },
      {
        'title': 'Partner Network',
        'subtitle': 'Referral rewards & partner network',
        'icon': Icons.share_rounded,
        'onTap': (BuildContext ctx) => ToastUtil.showSuccessMessage('Partner Network module opened'),
      },
      {
        'title': 'Addresses',
        'subtitle': 'Manage shipping & billing addresses',
        'icon': Icons.location_on_rounded,
        'onTap': (BuildContext ctx) => Navigator.pushNamed(ctx, Routes.addAddressScreen),
      },
    ];

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
                        onPressed: () => _handleProfileTap(context),
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

          // Body Content with Grid Cards
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

                  // GridView of Business Cards (Verification, Subscription, Partner Network, Addresses)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14.w,
                      mainAxisSpacing: 14.h,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: businessItems.length,
                    itemBuilder: (context, index) {
                      final item = businessItems[index];
                      return GestureDetector(
                        onTap: () => item['onTap'](context),
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColorsTheme.cardBg(context),
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(color: AppColorsTheme.borderColor(context), width: 1.w),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                                blurRadius: 10.r,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: primaryOrange.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  item['icon'],
                                  color: primaryOrange,
                                  size: 22.sp,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'],
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColorsTheme.textMainColor(context),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  UIHelper.verticalSpace(2.h),
                                  Text(
                                    item['subtitle'],
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: AppColorsTheme.textMutedColor(context),
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
