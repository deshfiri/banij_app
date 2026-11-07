import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constants/color.dart';
import '../../../constants/image_const.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/supplier_dashboard_provider.dart';
import '../../dashboard/presentation/widgets/custom_bottom_nav_bar.dart';
import 'widgets/application_status_card_widget.dart';
import 'widgets/supplier_drawer_widget.dart';

class SupplierDashboardScreen extends StatefulWidget {
  const SupplierDashboardScreen({super.key});

  @override
  State<SupplierDashboardScreen> createState() => _SupplierDashboardScreenState();
}

class _SupplierDashboardScreenState extends State<SupplierDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _handleOpenApplication(BuildContext context) {
    Navigator.pushNamed(context, Routes.kycVerificationScreen);
  }

  void _closeDrawer(BuildContext context) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColorsTheme.borderColor(context),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
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
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          UIHelper.horizontalSpace(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                UIHelper.verticalSpace(2.h),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColorsTheme.textMutedColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickShortcutTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColorsTheme.cardBg(context),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColorsTheme.borderColor(context),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 8.r,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryOrange, size: 20.sp),
            UIHelper.horizontalSpace(10.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13.sp,
              color: AppColorsTheme.textMutedColor(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<SupplierDashboardProvider>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColorsTheme.background(context),
      drawer: SupplierDrawerWidget(
        activeDrawerItem: provider.activeDrawerItem,
        onItemSelect: (item) {
          provider.setActiveDrawerItem(item);
        },
        onCloseDrawer: () => _closeDrawer(context),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar Header Stack (Fixed Centered Logo)
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
                  Positioned(
                    left: 0,
                    child: IconButton(
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
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
                            Navigator.pushNamed(context, Routes.accountScreen, arguments: 'supplier');
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

            // Main Scrollable Screen Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Title Banner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'supplier_dashboard'.tr,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: AppColorsTheme.textMainColor(context),
                                letterSpacing: 0.2,
                              ),
                            ),
                            UIHelper.verticalSpace(2.h),
                            Text(
                              'Manage your workspace & requisitions',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColorsTheme.textMutedColor(context),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: primaryOrange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'Supplier Hub',
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

                    // Metrics Summary Cards Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: 'Verification',
                            value: 'Pending',
                            icon: Icons.verified_user_outlined,
                            color: const Color(0xFF0284C7),
                          ),
                        ),
                        UIHelper.horizontalSpace(12.w),
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: 'Active Orders',
                            value: '0',
                            icon: Icons.inventory_2_outlined,
                            color: primaryOrange,
                          ),
                        ),
                      ],
                    ),
                    UIHelper.verticalSpace(12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: 'Requisitions',
                            value: '0 Active',
                            icon: Icons.receipt_long_outlined,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        UIHelper.horizontalSpace(12.w),
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: 'Earnings',
                            value: '৳ 0.00',
                            icon: Icons.account_balance_wallet_outlined,
                            color: const Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),
                    UIHelper.verticalSpace(22.h),

                    // Modular Application Status Card
                    ApplicationStatusCardWidget(
                      onOpenApplication: () => _handleOpenApplication(context),
                    ),
                    UIHelper.verticalSpace(24.h),

                    // Quick Shortcuts Section Header
                    Text(
                      'Quick Shortcuts',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(12.h),

                    // Quick Action Tiles
                    _buildQuickShortcutTile(
                      context: context,
                      title: 'KYC & Business Verification',
                      icon: Icons.shield_outlined,
                      onTap: () => Navigator.pushNamed(context, Routes.kycVerificationScreen),
                    ),
                    UIHelper.verticalSpace(10.h),
                    _buildQuickShortcutTile(
                      context: context,
                      title: 'Verification History',
                      icon: Icons.history_rounded,
                      onTap: () => Navigator.pushNamed(context, Routes.verificationHistoryScreen),
                    ),
                    UIHelper.verticalSpace(10.h),
                    _buildQuickShortcutTile(
                      context: context,
                      title: 'Account Settings & Profile',
                      icon: Icons.settings_outlined,
                      onTap: () => Navigator.pushNamed(context, Routes.accountScreen, arguments: 'supplier'),
                    ),
                    UIHelper.verticalSpace(24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Matching Custom Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('quick_action_clicked'.tr),
                backgroundColor: primaryOrange,
                duration: const Duration(milliseconds: 800),
              ),
            );
            return;
          }
          if (index == 0) {
            // Supplier Dashboard
          } else if (index == 1) {
            Navigator.pushNamed(context, Routes.accountScreen, arguments: 'supplier');
          } else if (index == 3) {
            Navigator.pushNamed(context, Routes.verificationHistoryScreen);
          } else if (index == 4) {
            Navigator.pushNamed(context, Routes.accountScreen, arguments: 'supplier');
          }
        },
      ),
    );
  }
}
