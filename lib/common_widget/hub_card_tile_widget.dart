import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';
import '../helpers/ui_helpers.dart';

class HubCardTileWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final Color? categoryColor;
  final VoidCallback? onTap;

  const HubCardTileWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    this.categoryColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = categoryColor ?? primaryOrange;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        splashColor: accentColor.withValues(alpha: 0.15),
        highlightColor: accentColor.withValues(alpha: 0.08),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColorsTheme.cardBg(context),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark
                  ? AppColorsTheme.borderColor(context)
                  : accentColor.withValues(alpha: 0.18),
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.03),
                blurRadius: 10.r,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: accentColor.withValues(alpha: isDark ? 0.04 : 0.02),
                blurRadius: 6.r,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top row: Compact Color-Accented Icon Container & Chevron Arrow Circle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(7.w),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isDark ? 0.22 : 0.12),
                      borderRadius: BorderRadius.circular(11.r),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.28),
                        width: 0.8.w,
                      ),
                    ),
                    child: Icon(
                      iconData,
                      color: accentColor,
                      size: 17.sp,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(4.5.w),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.2),
                        width: 0.8.w,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: accentColor,
                      size: 9.sp,
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpace(4.h),

              // Bottom text: Compact Bold Title & Uppercase Subtitle Tag
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColorsTheme.textMainColor(context),
                      height: 1.15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  UIHelper.verticalSpace(2.h),
                  Text(
                    subtitle.toUpperCase(),
                    style: TextStyle(
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColorsTheme.textMutedColor(context),
                      letterSpacing: 0.6,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
