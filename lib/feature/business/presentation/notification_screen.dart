import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                        'notifications'.tr,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                    ],
                  ),
                  if (notificationProvider.unreadCount > 0)
                    TextButton(
                      onPressed: () => notificationProvider.markAllAsRead(),
                      child: Text(
                        'mark_all_read'.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: primaryOrange,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Notification List Body
            Expanded(
              child: notificationProvider.notifications.isEmpty
                  ? Center(
                      child: Text(
                        'no_notifications'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColorsTheme.textMutedColor(context),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                      itemCount: notificationProvider.notifications.length,
                      itemBuilder: (context, index) {
                        final item = notificationProvider.notifications[index];
                        return GestureDetector(
                          onTap: () => notificationProvider.markAsRead(item.id),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 14.h),
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: item.isRead
                                  ? AppColorsTheme.cardBg(context)
                                  : (isDark ? const Color(0xFF221A15) : const Color(0xFFFFF7F2)),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: item.isRead
                                    ? AppColorsTheme.borderColor(context)
                                    : primaryOrange.withValues(alpha: 0.4),
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
                                // Icon Box
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: primaryOrange.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    item.iconData,
                                    size: 22.sp,
                                    color: primaryOrange,
                                  ),
                                ),
                                UIHelper.horizontalSpace(14.w),

                                // Title, Message & Time
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
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: primaryOrange,
                                              ),
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
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
