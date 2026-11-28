import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../providers/notification_provider.dart';
import '../../notification/model/notification_category.dart';
import 'widgets/notification/notification_tile.dart';

/// Notification inbox: All/Unread filter, category chips (Order, Payment,
/// …), cards styled by category and grouped by day, and "mark all read".
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  /// Display filters only; the list itself comes from the provider.
  bool _showUnreadOnly = false;
  NotificationCategory? _category;

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
    final categories = notificationProvider.categories;
    // A refresh can remove the selected category; fall back to "All".
    final category = categories.contains(_category) ? _category : null;
    final categoryCounts = <NotificationCategory, int>{
      for (final c in categories) c: notifications.where((n) => n.category == c).length,
    };
    final visible = notifications
        .where((n) => !_showUnreadOnly || !n.isRead)
        .where((n) => category == null || n.category == category)
        .toList();

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
                          const NotificationListShimmer()
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
                          SizedBox(height: 12.h),
                          NotificationFilterBar(
                            showUnreadOnly: _showUnreadOnly,
                            totalCount: notifications.length,
                            unreadCount: unreadCount,
                            onChanged: (value) => setState(() => _showUnreadOnly = value),
                          ),
                          if (categories.length > 1) ...[
                            SizedBox(height: 12.h),
                            NotificationCategoryChips(
                              categories: categories,
                              counts: categoryCounts,
                              selected: category,
                              onChanged: (value) => setState(() => _category = value),
                            ),
                          ],
                          SizedBox(height: 16.h),
                          if (visible.isEmpty)
                            const _AllCaughtUp()
                          else
                            ..._groupedTiles(visible),
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

  /// Tiles under "Today / Yesterday / Earlier" headers. Without any
  /// parseable timestamps the headers would say nothing, so the list is flat.
  List<Widget> _groupedTiles(List<NotificationItem> items) {
    Widget tile(NotificationItem item) => NotificationTile(
          key: ValueKey(item.id),
          item: item,
          onTap: () => context.read<NotificationProvider>().markAsRead(item.id),
        );

    if (items.every((n) => n.createdAt == null)) return [for (final item in items) tile(item)];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Calendar arithmetic (not Duration) so DST days are still one day.
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final groups = <String, List<NotificationItem>>{'today'.tr: [], 'yesterday'.tr: [], 'earlier'.tr: []};
    for (final item in items) {
      final date = item.createdAt;
      final day = date == null ? null : DateTime(date.year, date.month, date.day);
      final key = day == null || day.isBefore(yesterday)
          ? 'earlier'.tr
          : (day.isBefore(today) ? 'yesterday'.tr : 'today'.tr);
      groups[key]!.add(item);
    }

    return [
      for (final MapEntry(key: label, value: group) in groups.entries)
        if (group.isNotEmpty) ...[
          NotificationSectionHeader(label: label, count: group.length),
          for (final item in group) tile(item),
          SizedBox(height: 8.h),
        ],
    ];
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
          Container(
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.notifications_active_outlined, size: 20.sp, color: primaryOrange),
          ),
          SizedBox(width: 12.w),
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
            TextButton.icon(
              onPressed: onMarkAllRead,
              icon: Icon(Icons.done_all_rounded, size: 15.sp),
              label: Text(
                'mark_all_read'.tr,
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800),
              ),
              style: TextButton.styleFrom(
                foregroundColor: primaryOrange,
                backgroundColor: primaryOrange.withValues(alpha: 0.1),
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                minimumSize: Size(0, 32.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              ),
            )
          else if (unreadCount == 0)
            Icon(Icons.done_all_rounded, color: primaryOrange, size: 20.sp),
        ],
      ),
    );
  }
}

/// Shown under the "Unread" filter when everything has been read.
class _AllCaughtUp extends StatelessWidget {
  const _AllCaughtUp();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          Icon(Icons.mark_email_read_outlined, size: 40.sp, color: primaryOrange),
          SizedBox(height: 12.h),
          Text(
            'all_caught_up'.tr,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'no_unread_notifications'.tr,
            style: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
          ),
        ],
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
