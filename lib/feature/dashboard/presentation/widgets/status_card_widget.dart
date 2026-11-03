import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/color.dart';

class StatusCardWidget extends StatelessWidget {
  final String statusTitle;
  final String statusHighlight;
  final String progressLabel;
  final IconData progressIcon;
  final List<StatusItemModel> items;

  StatusCardWidget({
    super.key,
    String? statusTitle,
    String? statusHighlight,
    String? progressLabel,
    this.progressIcon = Icons.donut_large_rounded,
    List<StatusItemModel>? items,
  })  : statusTitle = statusTitle ?? 'current_status'.tr,
        statusHighlight = statusHighlight ?? 'kyc_pending'.tr,
        progressLabel = progressLabel ?? 'documents_pending'.tr,
        items = items ??
            [
              StatusItemModel(
                title: 'government_id'.tr,
                iconData: Icons.badge_outlined,
              ),
              StatusItemModel(
                title: 'proof_of_address'.tr,
                iconData: Icons.location_on_outlined,
              ),
              StatusItemModel(
                title: 'self_declaration'.tr,
                statusTag: 'pending_tag'.tr,
                iconData: Icons.circle_outlined,
              ),
            ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: primaryOrange.withValues(alpha: 0.4),
          width: 1.5.w,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: isDark ? 0.0 : 0.06),
            blurRadius: 16.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Current status: KYC pending
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 18.sp,
                fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
              ),
              children: [
                TextSpan(
                  text: statusTitle,
                  style: TextStyle(
                    color: AppColorsTheme.textMainColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: statusHighlight,
                  style: const TextStyle(
                    color: primaryOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Inner Status Box: Documents Pending
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF221A15) : const Color(0xFFFFF9F5),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColorsTheme.borderColor(context)),
            ),
            child: Row(
              children: [
                Icon(
                  progressIcon,
                  size: 22.sp,
                  color: primaryOrange,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    progressLabel,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Document List
          Column(
            children: items.map((item) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    Icon(
                      item.iconData,
                      size: 20.sp,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily:
                                Theme.of(context).textTheme.bodyMedium?.fontFamily,
                          ),
                          children: [
                            TextSpan(
                              text: item.title,
                              style: TextStyle(
                                color: AppColorsTheme.textMainColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (item.statusTag != null) ...[
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: item.statusTag!,
                                style: const TextStyle(
                                  color: primaryOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class StatusItemModel {
  final String title;
  final String? statusTag;
  final IconData iconData;

  const StatusItemModel({
    required this.title,
    this.statusTag,
    required this.iconData,
  });
}
