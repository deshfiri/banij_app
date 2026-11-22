import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../constants/image_const.dart';
import '../../../../../helpers/all_routes.dart';
import '../../../../../helpers/ui_helpers.dart';

/// Finance tab hero: gradient (orange / slate) with the menu button, white
/// logo, notifications + profile buttons, then title, subtitle and the
/// "B2B Billing" pill.
class FinanceHeroHeader extends StatelessWidget {
  final VoidCallback? onOpenDrawer;
  final VoidCallback onProfileTap;

  const FinanceHeroHeader({super.key, required this.onProfileTap, this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColorsTheme.heroGradient(context),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.35) : primaryOrange.withValues(alpha: 0.28),
            blurRadius: 18.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 22.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              UIHelper.verticalSpace(8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'finance'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          UIHelper.verticalSpace(3.h),
                          Text(
                            'financial_subtitle'.tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              height: 1.35,
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                          ),
                        ],
                      ),
                    ),
                    UIHelper.horizontalSpace(10.w),
                    _BillingPill(label: 'B2B Billing'.tr),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    // Full width so the buttons pin to the screen edges, not the logo's.
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(whiteLogo, width: 105.w, height: 34.h, fit: BoxFit.contain),
          if (onOpenDrawer != null)
            Positioned(
              left: 0,
              child: _HeaderIconButton(icon: Icons.menu_rounded, size: 24.sp, onPressed: onOpenDrawer!),
            ),
          Positioned(
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _HeaderIconButton(
                  icon: Icons.notifications_none_rounded,
                  showDot: true,
                  onPressed: () => Navigator.pushNamed(context, Routes.notificationScreen),
                ),
                _HeaderIconButton(icon: Icons.person_outline_rounded, onPressed: onProfileTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double? size;
  final bool showDot;

  const _HeaderIconButton({required this.icon, required this.onPressed, this.size, this.showDot = false});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: Colors.white, size: size ?? 22.sp),
          if (showDot)
            Positioned(
              top: -2.h,
              right: -2.w,
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: primaryOrange, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BillingPill extends StatelessWidget {
  final String label;

  const _BillingPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.business_center_rounded, color: Colors.white, size: 12.sp),
          UIHelper.horizontalSpace(4.w),
          Text(
            label,
            style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
