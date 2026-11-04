import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/ui_helpers.dart';

class SupplierDrawerWidget extends StatelessWidget {
  final String activeDrawerItem;
  final ValueChanged<String> onItemSelect;
  final VoidCallback onCloseDrawer;

  const SupplierDrawerWidget({
    super.key,
    required this.activeDrawerItem,
    required this.onItemSelect,
    required this.onCloseDrawer,
  });

  void _closeAndNavigate(BuildContext context, String routeName, {Object? arguments}) {
    onCloseDrawer();
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: AppColorsTheme.cardBg(context),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Logo
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Image.asset(
                isDark ? whiteLogo : logo,
                width: 120.w,
                height: 42.h,
                fit: BoxFit.contain,
              ),
            ),
            Divider(color: AppColorsTheme.borderColor(context)),
            UIHelper.verticalSpace(12.h),

            // Business Supplier Tile
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECE0),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.local_shipping,
                      color: primaryOrange,
                      size: 22.sp,
                    ),
                  ),
                  UIHelper.horizontalSpace(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'xyz business',
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
                          'SUP-261104-D48Y5RV8',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColorsTheme.textMutedColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            UIHelper.verticalSpace(24.h),

            // Section 1: OVERVIEW
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'overview'.tr,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColorsTheme.textMutedColor(context),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            UIHelper.verticalSpace(8.h),
            _buildDrawerItem(
              context: context,
              icon: Icons.grid_view_rounded,
              title: 'dashboard'.tr,
              isSelected: activeDrawerItem == 'Dashboard',
              onTap: () {
                onItemSelect('Dashboard');
                _closeAndNavigate(context, Routes.dashboardScreen);
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.verified_user_outlined,
              title: 'application_and_kyc'.tr,
              isSelected: activeDrawerItem == 'Application & KYC',
              onTap: () {
                onItemSelect('Application & KYC');
                onCloseDrawer();
              },
            ),
            UIHelper.verticalSpace(24.h),

            // Section 2: ACCOUNT
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'account'.tr.toUpperCase(),
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColorsTheme.textMutedColor(context),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            UIHelper.verticalSpace(8.h),
            _buildDrawerItem(
              context: context,
              icon: Icons.notifications_none,
              title: 'notifications'.tr,
              isSelected: activeDrawerItem == 'Notifications',
              onTap: () {
                onItemSelect('Notifications');
                onCloseDrawer();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications'),
                    backgroundColor: primaryOrange,
                    duration: Duration(milliseconds: 700),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.person_outline,
              title: 'profile'.tr,
              isSelected: activeDrawerItem == 'Profile',
              onTap: () {
                onItemSelect('Profile');
                _closeAndNavigate(context, Routes.accountScreen, arguments: 'supplier');
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.security,
              title: 'security'.tr,
              isSelected: activeDrawerItem == 'Security',
              onTap: () {
                onItemSelect('Security');
                _closeAndNavigate(context, Routes.accountScreen, arguments: 'supplier');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected ? primaryOrange : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20.sp,
                  color: isSelected ? Colors.white : AppColorsTheme.textMainColor(context),
                ),
                UIHelper.horizontalSpace(14.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColorsTheme.textMainColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
