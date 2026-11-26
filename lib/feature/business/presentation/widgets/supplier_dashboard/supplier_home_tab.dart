import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../constants/image_const.dart';
import '../../../../../helpers/all_routes.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../dashboard/presentation/widgets/quick_access_section_widget.dart';
import '../application_status_card_widget.dart';

/// Supplier dashboard home (index 0): logo header, metrics, application
/// status and quick shortcuts.
class SupplierHomeTab extends StatelessWidget {
  final VoidCallback onOpenDrawer;
  final VoidCallback onOpenAccount;

  const SupplierHomeTab({super.key, required this.onOpenDrawer, required this.onOpenAccount});

  Widget _buildIntegratedHeroHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [primaryOrange, secondaryOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: isDark ? 0.2 : 0.28),
            blurRadius: 18.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Drawer Menu, White Logo & Notifications / Profile Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: onOpenDrawer,
                    icon: Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  Image.asset(
                    whiteLogo,
                    width: 105.w,
                    height: 34.h,
                    fit: BoxFit.contain,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, Routes.notificationScreen),
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
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
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onOpenAccount,
                        icon: Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              UIHelper.verticalSpace(12.h),

              // Supplier Title & Hub Badge
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'supplier_dashboard'.tr,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          UIHelper.verticalSpace(2.h),
                          Text(
                            'Manage your workspace & requisitions',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    UIHelper.horizontalSpace(8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        'Supplier Hub',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      _Shortcut(
        'KYC & Business Verification',
        Icons.shield_outlined,
        () => Navigator.pushNamed(context, Routes.kycVerificationScreen),
      ),
      _Shortcut(
        'Verification History',
        Icons.history_rounded,
        () => Navigator.pushNamed(context, Routes.verificationHistoryScreen),
      ),
      _Shortcut('Account Settings & Profile', Icons.settings_outlined, onOpenAccount),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIntegratedHeroHeader(context),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Expanded(child: SupplierMetricCard(metric: SupplierMetric.verification)),
                    _MetricGap(),
                    Expanded(child: SupplierMetricCard(metric: SupplierMetric.activeOrders)),
                  ],
                ),
                UIHelper.verticalSpace(12.h),
                const Row(
                  children: [
                    Expanded(child: SupplierMetricCard(metric: SupplierMetric.requisitions)),
                    _MetricGap(),
                    Expanded(child: SupplierMetricCard(metric: SupplierMetric.earnings)),
                  ],
                ),
                UIHelper.verticalSpace(22.h),
                ApplicationStatusCardWidget(
                  onOpenApplication: () => Navigator.pushNamed(context, Routes.kycVerificationScreen),
                ),
                UIHelper.verticalSpace(24.h),
                DashboardSectionHeader(title: 'Quick Shortcuts'.tr),
                UIHelper.verticalSpace(12.h),
                for (int i = 0; i < shortcuts.length; i++) ...[
                  if (i > 0) UIHelper.verticalSpace(10.h),
                  SupplierShortcutTile(title: shortcuts[i].title, icon: shortcuts[i].icon, onTap: shortcuts[i].onTap),
                ],
                UIHelper.verticalSpace(100.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Shortcut {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _Shortcut(this.title, this.icon, this.onTap);
}

class _MetricGap extends StatelessWidget {
  const _MetricGap();

  @override
  Widget build(BuildContext context) => UIHelper.horizontalSpace(12.w);
}

/// The four supplier summary metrics.
enum SupplierMetric {
  verification('Verification', 'Pending', Icons.verified_user_outlined, infoBlue),
  activeOrders('Active Orders', '0', Icons.inventory_2_outlined, primaryOrange),
  requisitions('Requisitions', '0 Active', Icons.receipt_long_outlined, successGreen),
  earnings('Earnings', '৳ 0.00', Icons.account_balance_wallet_outlined, purpleAccent);

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SupplierMetric(this.title, this.value, this.icon, this.color);
}

/// Card with a tinted icon box, a bold value and a muted title.
class SupplierMetricCard extends StatelessWidget {
  final SupplierMetric metric;

  const SupplierMetricCard({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColorsTheme.cardBg(context) : const Color(0xFFFFF7F2),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : primaryOrange.withValues(alpha: 0.22),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: metric.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(metric.icon, color: metric.color, size: 20.sp),
          ),
          UIHelper.horizontalSpace(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  metric.value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                UIHelper.verticalSpace(2.h),
                Text(
                  metric.title,
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
}

/// Tappable shortcut row: orange icon, title, chevron.
class SupplierShortcutTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const SupplierShortcutTile({super.key, required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isDark ? AppColorsTheme.cardBg(context) : const Color(0xFFFFF7F2),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : primaryOrange.withValues(alpha: 0.22),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryOrange.withValues(alpha: isDark ? 0.08 : 0.05),
              blurRadius: 10.r,
              offset: const Offset(0, 3),
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
              color: primaryOrange,
            ),
          ],
        ),
      ),
    );
  }
}
