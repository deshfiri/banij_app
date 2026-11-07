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
        borderRadius: BorderRadius.circular(18.r),
        splashColor: primaryOrange.withValues(alpha: 0.15),
        highlightColor: primaryOrange.withValues(alpha: 0.08),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColorsTheme.cardBg(context),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isDark
                  ? AppColorsTheme.borderColor(context)
                  : const Color(0xFFFFECE0),
              width: 1.2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
                blurRadius: 12.r,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: primaryOrange.withValues(alpha: isDark ? 0.04 : 0.02),
                blurRadius: 6.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top row: Soft Peach Icon Box & Chevron Circle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(9.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECE0).withValues(alpha: isDark ? 0.2 : 0.9),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: primaryOrange.withValues(alpha: 0.25),
                        width: 1.w,
                      ),
                    ),
                    child: Icon(
                      iconData,
                      color: primaryOrange,
                      size: 20.sp,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF221A15)
                          : const Color(0xFFFAFAFA),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColorsTheme.borderColor(context),
                        width: 0.8.w,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColorsTheme.textMutedColor(context),
                      size: 11.sp,
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpace(8.h),

              // Bottom text: Bold Title & Uppercase Subtitle Tag
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColorsTheme.textMainColor(context),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  UIHelper.verticalSpace(2.h),
                  Text(
                    subtitle.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColorsTheme.textMutedColor(context),
                      letterSpacing: 0.8,
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
