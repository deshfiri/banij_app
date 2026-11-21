import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';

class SummaryCardWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String amount;
  final IconData? iconData;
  final String? iconAsset;
  final VoidCallback onTap;

  const SummaryCardWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.amount,
    this.iconData,
    this.iconAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        constraints: BoxConstraints(minHeight: 88.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColorsTheme.cardBg(context) : primaryOrange.withValues(alpha: 0.0),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : primaryOrange.withValues(alpha: 0.21),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark?Colors.white:Colors.black
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (iconAsset != null) ...[
                  Image.asset(
                    iconAsset!,
                    width: 20.w,
                    height: 20.h,
                    fit: BoxFit.contain,
                  ),
                ] else if (iconData != null) ...[
                  Icon(iconData, color: primaryOrange, size: 20.sp),
                ],
              ],
            ),

            UIHelper.verticalSpace(8.h),
            Text(
              amount,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: primaryOrange,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
