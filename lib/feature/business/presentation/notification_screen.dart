import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../providers/notification_provider.dart';
import 'widgets/notification/notification_tile.dart';

/// Notification inbox with "mark all read".
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.notifications;
    final unreadCount = notificationProvider.unreadCount;

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: Column(
        children: [
          HeroPageHeader(
            title: 'notifications'.tr,
            subtitle: 'notifications_subtitle'.tr,
            trailing: unreadCount > 0
                ? HeroCountPill(label: '$unreadCount ${'unread'.tr}')
                : null,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: RefreshIndicator(
                color: primaryOrange,
                onRefresh: notificationProvider.fetchNotifications,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final sidePadding = constraints.maxWidth > 760
                        ? (constraints.maxWidth - 720) / 2
                        : 16.w;
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        sidePadding,
                        20.h,
                        sidePadding,
                        28.h,
                      ),
                      children: [
                        if (notificationProvider.isLoading &&
                            notifications.isEmpty)
                          const _NotificationsLoading()
                        else if (notificationProvider.error != null &&
                            notifications.isEmpty)
                          _NotificationsError(
                            message: notificationProvider.error!,
                            onRetry: notificationProvider.fetchNotifications,
                          )
                        else if (notifications.isEmpty)
                          const _NotificationsEmpty()
                        else ...[
                          _NotificationsSummary(
                            count: notifications.length,
                            unreadCount: unreadCount,
                            onMarkAllRead: unreadCount > 0
                                ? notificationProvider.markAllAsRead
                                : null,
                          ),
                          if (notificationProvider.error != null) ...[
                            SizedBox(height: 12.h),
                            _InlineLoadError(
                              message: notificationProvider.error!,
                            ),
                          ],
                          SizedBox(height: 16.h),
                          for (final item in notifications)
                            NotificationTile(
                              item: item,
                              onTap: () => context
                                  .read<NotificationProvider>()
                                  .markAsRead(item.id),
                            ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsSummary extends StatelessWidget {
  final int count;
  final int unreadCount;
  final VoidCallback? onMarkAllRead;

  const _NotificationsSummary({
    required this.count,
    required this.unreadCount,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'recent_notifications'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '$count ${'notifications'.tr.toLowerCase()}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColorsTheme.textMutedColor(context),
                  ),
                ),
              ],
            ),
          ),
          if (onMarkAllRead != null)
            TextButton(
              onPressed: onMarkAllRead,
              style: TextButton.styleFrom(
                foregroundColor: primaryOrange,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              ),
              child: Text(
                'mark_all_read'.tr,
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700),
              ),
            )
          else if (unreadCount == 0)
            Icon(Icons.done_all_rounded, color: primaryOrange, size: 20.sp),
        ],
      ),
    );
  }
}

class _NotificationsLoading extends StatelessWidget {
  const _NotificationsLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 80.h),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(color: primaryOrange),
            SizedBox(height: 16.h),
            Text(
              'loading_notifications'.tr,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsEmpty extends StatelessWidget {
  const _NotificationsEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 56.h, horizontal: 20.w),
      child: Column(
        children: [
          Container(
            width: 84.w,
            height: 84.w,
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: primaryOrange,
              size: 38.sp,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'no_notifications'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'notification_empty_description'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: AppColorsTheme.textMutedColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _NotificationsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 12.w),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: AppColorsTheme.textMutedColor(context),
            size: 42.sp,
          ),
          SizedBox(height: 14.h),
          Text(
            message.isEmpty ? 'notification_load_error'.tr : message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColorsTheme.textMutedColor(context),
            ),
          ),
          SizedBox(height: 12.h),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('retry'.tr),
          ),
        ],
      ),
    );
  }
}

class _InlineLoadError extends StatelessWidget {
  final String message;

  const _InlineLoadError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: primaryOrange, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message.isEmpty ? 'notification_load_error'.tr : message,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
