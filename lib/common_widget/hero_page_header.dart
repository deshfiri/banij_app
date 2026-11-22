import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';
import '../helpers/ui_helpers.dart';

/// Page header in the dashboard hero style: orange (light) / slate (dark)
/// gradient with rounded bottom corners, a back button, title, optional
/// subtitle, trailing actions and a [bottom] slot (e.g. a search row).
class HeroPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? bottom;
  final VoidCallback? onBack;

  const HeroPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.bottom,
    this.onBack,
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
          padding: EdgeInsets.fromLTRB(8.w, 4.h, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onBack ?? () => Navigator.maybePop(context),
                    icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24.sp),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                  ?trailing,
                ],
              ),
              if (subtitle != null || bottom != null)
                Padding(
                  padding: EdgeInsets.only(left: 12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(fontSize: 11.5.sp, color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      if (bottom != null) ...[
                        UIHelper.verticalSpace(14.h),
                        bottom!,
                      ],
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

/// Small translucent pill for use on the hero gradient (e.g. "8 modules").
class HeroCountPill extends StatelessWidget {
  final String label;

  const HeroCountPill({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.white),
      ),
    );
  }
}

/// Round translucent icon button for the hero gradient, with an optional badge.
class HeroIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  const HeroIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, color: Colors.white, size: 20.sp),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -3.h,
              right: -3.w,
              child: Container(
                constraints: BoxConstraints(minWidth: 17.w, minHeight: 17.w),
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: primaryOrange, width: 1.2),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
