import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constants/color.dart';
import '../../../providers/notification_provider.dart';
import 'widgets/common/sub_screen_top_bar.dart';
import 'widgets/notification/notification_tile.dart';

/// Notification inbox with "mark all read".
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.notifications;

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            SubScreenTopBar(
              title: 'notifications'.tr,
              trailing: notificationProvider.unreadCount > 0
                  ? TextButton(
                      onPressed: notificationProvider.markAllAsRead,
                      child: Text(
                        'mark_all_read'.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: primaryOrange,
                        ),
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: notifications.isEmpty
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
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        return NotificationTile(
                          item: item,
                          onTap: () => context.read<NotificationProvider>().markAsRead(item.id),
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
