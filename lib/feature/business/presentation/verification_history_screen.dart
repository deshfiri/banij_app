import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';

class VerificationHistoryScreen extends StatelessWidget {
  const VerificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample verification history records list
    final List<Map<String, String>> verificationRecords = [
      {
        'title': 'verification'.tr,
        'meta': 'verification_meta'.tr,
        'status': 'approved'.tr,
        'due': 'verification_due'.tr,
      },
    ];

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header / AppBar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColorsTheme.cardBg(context),
                border: Border(
                  bottom: BorderSide(
                    color: AppColorsTheme.borderColor(context),
                    width: 1.w,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColorsTheme.textMainColor(context),
                      size: 22.sp,
                    ),
                  ),
                  UIHelper.horizontalSpace(8.w),
                  Text(
                    'verification_history'.tr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                ],
              ),
            ),

            // Content Body with ListView.builder
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                itemCount: verificationRecords.length,
                itemBuilder: (context, index) {
                  final record = verificationRecords[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColorsTheme.cardBg(context),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColorsTheme.borderColor(context),
                        width: 1.w,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          record['title'] ?? '',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColorsTheme.textMainColor(context),
                          ),
                        ),
                        UIHelper.verticalSpace(6.h),

                        // Meta Dates
                        Text(
                          record['meta'] ?? '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColorsTheme.textMutedColor(context),
                            height: 1.4,
                          ),
                        ),
                        UIHelper.verticalSpace(14.h),

                        // Status Badge (Approved)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF065F46).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: const Color(0xFF10B981),
                                size: 14.sp,
                              ),
                              UIHelper.horizontalSpace(6.w),
                              Text(
                                record['status'] ?? '',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                        UIHelper.verticalSpace(14.h),

                        // Due Date & Remaining Days
                        Text(
                          record['due'] ?? '',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColorsTheme.textMainColor(context),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
