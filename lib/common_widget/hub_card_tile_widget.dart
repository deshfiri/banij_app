import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';
import '../helpers/ui_helpers.dart';

class HubCardTileWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final VoidCallback? onTap;

  const HubCardTileWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        splashColor: primaryOrange.withValues(alpha: 0.12),
        highlightColor: primaryOrange.withValues(alpha: 0.06),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColorsTheme.cardBg(context),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColorsTheme.borderColor(context),
              width: 1.2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
                blurRadius: 14.r,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: primaryOrange.withValues(alpha: isDark ? 0.03 : 0.02),
                blurRadius: 6.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top row: Soft Peach Icon Box & Chevron Arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(11.w),
                    decoration: BoxDecoration(
                      color: primaryOrange.withValues(alpha: isDark ? 0.16 : 0.14),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: primaryOrange.withValues(alpha: 0.25),
                        width: 1.w,
                      ),
                    ),
                    child: Icon(
                      iconData,
                      color: primaryOrange,
                      size: 22.sp,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF221A15)
                          : Colors.grey.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColorsTheme.textMutedColor(context),
                      size: 12.sp,
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpace(12.h),

              // Bottom text: Bold Title & Uppercase Subtitle Tag
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColorsTheme.textMainColor(context),
                      height: 1.25,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  UIHelper.verticalSpace(3.h),
                  Text(
                    subtitle.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColorsTheme.textMutedColor(context),
                      letterSpacing: 0.9,
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
