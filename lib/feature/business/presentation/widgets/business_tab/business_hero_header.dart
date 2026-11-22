import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../common_widget/hero_page_header.dart';
import '../../../../../constants/color.dart';
import '../../../../../constants/image_const.dart';
import '../../../../../helpers/ui_helpers.dart';

/// Dashboard-style hero for the Business tab: menu, white logo,
/// notifications + profile, then title, subtitle and a "Workspace" pill.
class BusinessHeroHeader extends StatelessWidget {
  final VoidCallback? onOpenDrawer;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;

  const BusinessHeroHeader({
    super.key,
    required this.onNotificationsTap,
    required this.onProfileTap,
    this.onOpenDrawer,
  });

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
          padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 22.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(
                onOpenDrawer: onOpenDrawer,
                onNotificationsTap: onNotificationsTap,
                onProfileTap: onProfileTap,
              ),
              UIHelper.verticalSpace(10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'business'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          UIHelper.verticalSpace(2.h),
                          Text(
                            'business_subtitle'.tr,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                          ),
                        ],
                      ),
                    ),
                    UIHelper.horizontalSpace(8.w),
                    HeroCountPill(label: 'Workspace'.tr),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback? onOpenDrawer;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;

  const _TopBar({required this.onNotificationsTap, required this.onProfileTap, this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const SizedBox(width: double.infinity, height: 48),
        Image.asset(whiteLogo, width: 105.w, height: 34.h, fit: BoxFit.contain),
        if (onOpenDrawer != null)
          Positioned(
            left: 0,
            child: IconButton(
              onPressed: onOpenDrawer,
              icon: Icon(Icons.menu_rounded, color: Colors.white, size: 24.sp),
            ),
          ),
        Positioned(
          right: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onNotificationsTap,
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22.sp),
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
              ),
              IconButton(
                onPressed: onProfileTap,
                icon: Icon(Icons.person_outline_rounded, color: Colors.white, size: 22.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
