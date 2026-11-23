import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../providers/notification_provider.dart';

/// One notification card. Unread items get a warm tint, orange border, bold
/// title and an orange dot.
class NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const NotificationTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: item.isRead
              ? AppColorsTheme.cardBg(context)
              : (isDark ? const Color(0xFF221A15) : const Color(0xFFFFF7F2)),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: item.isRead ? AppColorsTheme.borderColor(context) : primaryOrange.withValues(alpha: 0.4),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.02),
              blurRadius: 8.r,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: primaryOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(item.iconData, size: 22.sp, color: primaryOrange),
            ),
            UIHelper.horizontalSpace(14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: AppColorsTheme.textMainColor(context),
                          ),
                        ),
                      ),
                      if (!item.isRead) ...[
                        UIHelper.horizontalSpace(8.w),
                        Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: primaryOrange),
                        ),
                      ],
                    ],
                  ),
                  UIHelper.verticalSpace(4.h),
                  Text(
                    item.message,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColorsTheme.textMutedColor(context),
                      height: 1.4,
                    ),
                  ),
                  UIHelper.verticalSpace(8.h),
                  Text(
                    item.time,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
