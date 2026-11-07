import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/color.dart';

class StatusCardWidget extends StatelessWidget {
  final String statusTitle;
  final String statusHighlight;
  final String progressLabel;
  final List<StatusItemModel> items;

  StatusCardWidget({
    super.key,
    String? statusTitle,
    String? statusHighlight,
    String? progressLabel,
    List<StatusItemModel>? items,
  })  : statusTitle = statusTitle ?? 'Current status: ',
        statusHighlight = statusHighlight ?? 'KYC pending',
        progressLabel = progressLabel ?? 'Documents Pending',
        items = items ??
            [
              const StatusItemModel(
                title: 'Government ID',
                iconData: Icons.badge_outlined,
              ),
              const StatusItemModel(
                title: 'Proof of Address',
                iconData: Icons.location_on_outlined,
              ),
              const StatusItemModel(
                title: 'Self-Declaration Form',
                statusTag: '(Pending)',
                iconData: Icons.circle_outlined,
              ),
            ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: primaryOrange.withValues(alpha: 0.5),
          width: 1.2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: isDark ? 0.0 : 0.05),
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
                fontSize: 17.sp,
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

          // Inner Light Box: Documents Pending with Circular Orange Sync Icon
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF221A15) : const Color(0xFFFFF9F5),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: primaryOrange.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sync_rounded,
                  size: 22.sp,
                  color: primaryOrange,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    progressLabel,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Document Items List
          Column(
            children: items.map((item) {
              return Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: Row(
                  children: [
                    Icon(
                      item.iconData,
                      size: 20.sp,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                    SizedBox(width: 14.w),
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
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (item.statusTag != null) ...[
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: item.statusTag!,
                                style: const TextStyle(
                                  color: primaryOrange,
                                  fontWeight: FontWeight.bold,
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
