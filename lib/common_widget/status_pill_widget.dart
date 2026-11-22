import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';
import '../helpers/ui_helpers.dart';

/// Green "status" pill for use on the orange/slate hero gradient
/// (dashboard header, drawer header). [label] should already be translated.
class StatusPillWidget extends StatelessWidget {
  final String label;

  const StatusPillWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Light: white pill on orange; dark: tinted green pill on slate.
    final foreground = isDark ? successGreen : successGreenDark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? successGreen.withValues(alpha: 0.18) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: successGreen.withValues(alpha: isDark ? 0.45 : 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 12.sp, color: foreground),
          UIHelper.horizontalSpace(4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
