import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';
import '../helpers/ui_helpers.dart';

/// Centered icon-in-circle + message, for empty lists and "no results".
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subtitle;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(color: primaryOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: primaryOrange, size: 30.sp),
            ),
            UIHelper.verticalSpace(12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            if (subtitle != null) ...[
              UIHelper.verticalSpace(4.h),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
