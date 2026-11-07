import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widget/custom_button.dart';
import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';

class ApplicationStatusCardWidget extends StatelessWidget {
  final VoidCallback onOpenApplication;

  const ApplicationStatusCardWidget({
    super.key,
    required this.onOpenApplication,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColorsTheme.borderColor(context),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & Pending Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'application_status'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColorsTheme.textMainColor(context),
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 5.h,
                ),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: primaryOrange.withValues(alpha: 0.3),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.hourglass_top_rounded,
                      color: primaryOrange,
                      size: 13.sp,
                    ),
                    UIHelper.horizontalSpace(4.w),
                    Text(
                      'kyc_pending'.tr,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(14.h),

          // Progress Indicator Bar (50% Completion)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Application Completion',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                  Text(
                    '50%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: primaryOrange,
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpace(6.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: LinearProgressIndicator(
                  value: 0.5,
                  minHeight: 6.h,
                  backgroundColor: AppColorsTheme.borderColor(context),
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryOrange),
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(16.h),
          Divider(color: AppColorsTheme.borderColor(context), thickness: 1),
          UIHelper.verticalSpace(14.h),

          // What Happens Next Section
          Text(
            'what_happens_next'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(6.h),
          Text(
            'upload_kyc_desc'.tr,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w400,
              color: AppColorsTheme.textMutedColor(context),
              height: 1.45,
            ),
          ),
          UIHelper.verticalSpace(20.h),

          // Open Application Action Button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              onTap: onOpenApplication,
              btnName: 'open_application'.tr,
            ),
          ),
        ],
      ),
    );
  }
}
