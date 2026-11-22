import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';

/// Onboarding step 5 card: approval badge and the review message.
class ApprovalStatusCardWidget extends StatelessWidget {
  final String badgeLabel;
  final String message;

  const ApprovalStatusCardWidget({
    super.key,
    required this.badgeLabel,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: isDark ? AppColorsTheme.cardBg(context) : primaryOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: primaryOrange, width: 1.5.w),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: 0.08),
            blurRadius: 16.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Approval Status'.tr,
                  style: TextStyle(
                    fontSize: 16.5.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: isDark ? successGreen.withValues(alpha: 0.18) : successGreenLight,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: successGreen.withValues(alpha: 0.3), width: 1.w),
                ),
                child: Text(
                  badgeLabel.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark ? successGreen : successGreenDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(14.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: isDark ? AppColorsTheme.innerCardBg(context) : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: successGreen.withValues(alpha: 0.25), width: 1.w),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: isDark ? successGreen.withValues(alpha: 0.18) : successGreenLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.verified_rounded, size: 22.sp, color: successGreenDark),
                ),
                UIHelper.horizontalSpace(12.w),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColorsTheme.textMainColor(context),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
