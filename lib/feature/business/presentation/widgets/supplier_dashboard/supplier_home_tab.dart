import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../constants/image_const.dart';
import '../../../../../helpers/all_routes.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../dashboard/presentation/all_modules_screen.dart';
import '../../../../dashboard/presentation/widgets/hero_metric_card_widget.dart';
import '../../../../dashboard/presentation/widgets/quick_access_section_widget.dart';
import '../application_status_card_widget.dart';

/// Supplier dashboard home (index 0): logo header, metrics, application
/// status and quick shortcuts matching the exact User Dashboard layout.
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
          colors: AppColorsTheme.heroGradient(context),
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
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 18.h),
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
              UIHelper.verticalSpace(10.h),

              // Supplier Greeting & Active Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'supplier_dashboard'.tr,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        UIHelper.verticalSpace(2.h),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                        UIHelper.horizontalSpace(4.w),
                        Text(
                          'Active'.tr,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpace(16.h),

              // Embedded Inner Metric Cards Row INSIDE the Hero Header Container
              Row(
                children: [
                  Expanded(
                    child: HeroMetricCardWidget(
                      title: 'Total Earnings',
                      amount: '৳0.00',
                      iconPath: walletIconAsset,
                      onTap: () => Navigator.pushNamed(context, Routes.walletScreen),
                    ),
                  ),
                  UIHelper.horizontalSpace(10.w),
                  Expanded(
                    child: HeroMetricCardWidget(
                      title: 'Active Orders',
                      amount: '0',
                      iconPath: paidMediaIconAsset,
                      onTap: () => Navigator.pushNamed(context, Routes.verificationHistoryScreen),
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpace(12.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIntegratedHeroHeader(context),
          UIHelper.verticalSpace(16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Expanded(child: SupplierMetricCard(metric: SupplierMetric.verification)),
                    _MetricGap(),
                    Expanded(child: SupplierMetricCard(metric: SupplierMetric.requisitions)),
                  ],
                ),
                UIHelper.verticalSpace(22.h),
                ApplicationStatusCardWidget(
                  onOpenApplication: () => Navigator.pushNamed(context, Routes.kycVerificationScreen),
                ),
                UIHelper.verticalSpace(24.h),
                DashboardSectionHeader(
                  title: 'Quick Access'.tr,
                  actionLabel: 'See All'.tr,
                  onAction: () => AllModulesScreen.open(context),
                ),
                UIHelper.verticalSpace(12.h),
                QuickAccessGrid(
                  tiles: [
                    QuickAccessTile(
                      title: 'KYC Verification',
                      iconAsset: verificationIconAsset,
                      onTap: () => Navigator.pushNamed(context, Routes.kycVerificationScreen),
                    ),
                    QuickAccessTile(
                      title: 'History',
                      iconAsset: addressesIconAsset,
                      onTap: () => Navigator.pushNamed(context, Routes.verificationHistoryScreen),
                    ),
                    QuickAccessTile(
                      title: 'Account',
                      iconAsset: subscriptionIconAsset,
                      onTap: onOpenAccount,
                    ),
                  ],
                ),
                UIHelper.verticalSpace(100.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGap extends StatelessWidget {
  const _MetricGap();

  @override
  Widget build(BuildContext context) => UIHelper.horizontalSpace(12.w);
}

/// The four supplier summary metrics.
enum SupplierMetric {
  verification('Verification', 'Pending', Icons.verified_user_outlined, infoBlue),
  requisitions('Requisitions', '0 Active', Icons.receipt_long_outlined, successGreen);

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
          color: isDark
              ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.22),
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
