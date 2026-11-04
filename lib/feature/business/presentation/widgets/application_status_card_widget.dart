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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColorsTheme.borderColor(context),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'application_status'.tr,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(12.h),
          Divider(color: AppColorsTheme.borderColor(context)),
          UIHelper.verticalSpace(14.h),

          // Status Badge: KYC pending
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 6.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0369A1).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: const Color(0xFF0284C7).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.assignment_turned_in_outlined,
                  color: const Color(0xFF38BDF8),
                  size: 15.sp,
                ),
                UIHelper.horizontalSpace(6.w),
                Text(
                  'kyc_pending'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF38BDF8),
                  ),
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(18.h),

          // What happens next
          Text(
            'what_happens_next'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(6.h),
          Text(
            'upload_kyc_desc'.tr,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColorsTheme.textMutedColor(context),
              height: 1.4,
            ),
          ),
          UIHelper.verticalSpace(22.h),

          // Open Application Button
          SizedBox(
            width: 160.w,
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
