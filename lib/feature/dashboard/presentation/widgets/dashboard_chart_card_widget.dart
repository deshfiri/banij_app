import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';

class DashboardChartCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const DashboardChartCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(minHeight: 215.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColorsTheme.cardBg(context) : const Color(0xFFFFF7F2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : primaryOrange.withValues(alpha: 0.25),
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
        children: [
          Text(
            title.tr,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w900,
              color: AppColorsTheme.textMainColor(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          UIHelper.verticalSpace(2.h),
          Text(
            subtitle.tr,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColorsTheme.textMutedColor(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          UIHelper.verticalSpace(14.h),
          child,
        ],
      ),
    );
  }
}
