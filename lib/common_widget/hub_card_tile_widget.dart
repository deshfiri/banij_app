import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';
import '../helpers/ui_helpers.dart';

class HubCardTileWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final Color? categoryColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const HubCardTileWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    this.categoryColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = categoryColor ?? primaryOrange;
    final cardBgColor = backgroundColor ?? accentColor.withValues(alpha: isDark ? 0.18 : 0.12);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        splashColor: accentColor.withValues(alpha: 0.18),
        highlightColor: accentColor.withValues(alpha: 0.08),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: isDark ? AppColorsTheme.cardBg(context) : cardBgColor,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF374151)
                  : accentColor.withValues(alpha: 0.2),
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: isDark ? 0.08 : 0.04),
                blurRadius: 10.r,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular White Icon Container matching Quick Access tiles
              Container(
                padding: EdgeInsets.all(11.w),
                decoration: BoxDecoration(
                  color: isDark ? accentColor.withValues(alpha: 0.2) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.14),
                        blurRadius: 6.r,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Icon(
                  iconData,
                  color: accentColor,
                  size: 23.sp,
                ),
              ),
              UIHelper.verticalSpace(10.h),

              // Title Centered Text
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColorsTheme.textMainColor(context),
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
