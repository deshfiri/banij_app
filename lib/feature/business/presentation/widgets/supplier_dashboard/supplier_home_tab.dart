import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../constants/image_const.dart';
import '../../../../../helpers/all_routes.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../application_status_card_widget.dart';

/// Supplier dashboard home (index 0): logo header, metrics, application
/// status and quick shortcuts.
class SupplierHomeTab extends StatelessWidget {
  final VoidCallback onOpenDrawer;
  final VoidCallback onOpenAccount;

  const SupplierHomeTab({super.key, required this.onOpenDrawer, required this.onOpenAccount});

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
        _SupplierHomeHeader(onOpenDrawer: onOpenDrawer, onProfileTap: onOpenAccount),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _WelcomeBanner(),
                UIHelper.verticalSpace(20.h),
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
                Text(
                  'Quick Shortcuts',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
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

/// Logo centered, drawer button left, notifications + profile right.
class _SupplierHomeHeader extends StatelessWidget {
  final VoidCallback onOpenDrawer;
  final VoidCallback onProfileTap;

  const _SupplierHomeHeader({required this.onOpenDrawer, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = AppColorsTheme.textMainColor(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.background(context),
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
          Center(
            child: Image.asset(
              isDark ? whiteLogo : logo,
              width: 110.w,
              height: 36.h,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: 0,
            child: IconButton(
              onPressed: onOpenDrawer,
              icon: Icon(Icons.menu_rounded, color: iconColor, size: 24.sp),
            ),
          ),
          Positioned(
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, Routes.notificationScreen),
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(Icons.notifications_none_rounded, color: iconColor, size: 22.sp),
                      Positioned(
                        top: -2.h,
                        right: -2.w,
                        child: Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: primaryOrange),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onProfileTap,
                  icon: Icon(Icons.person_outline_rounded, color: iconColor, size: 22.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

/// The four (currently static) supplier summary metrics.
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
              color: metric.color.withValues(alpha: 0.12),
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
}
