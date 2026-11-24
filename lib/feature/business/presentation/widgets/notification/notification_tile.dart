import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../providers/notification_provider.dart';

/// One notification card. Unread items get an orange edge, a warm tint, a
/// bold title and a "New" dot; read items are plain cards.
class NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const NotificationTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread = !item.isRead;
    final muted = AppColorsTheme.textMutedColor(context);
    final radius = BorderRadius.circular(16.r);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              color: unread
                  ? (isDark ? const Color(0xFF221A15) : const Color(0xFFFFF7F2))
                  : AppColorsTheme.cardBg(context),
              borderRadius: radius,
              border: Border.all(
                color: unread ? primaryOrange.withValues(alpha: 0.35) : AppColorsTheme.borderColor(context),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
                  blurRadius: 10.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Unread accent edge.
                    Container(width: 4.w, color: unread ? primaryOrange : Colors.transparent),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(12.w, 14.h, 14.w, 14.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: primaryOrange.withValues(alpha: unread ? 0.16 : 0.08),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                item.iconData,
                                size: 20.sp,
                                color: unread ? primaryOrange : primaryOrange.withValues(alpha: 0.7),
                              ),
                            ),
                            UIHelper.horizontalSpace(12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13.5.sp,
                                            fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                                            color: AppColorsTheme.textMainColor(context),
                                          ),
                                        ),
                                      ),
                                      if (unread) ...[
                                        UIHelper.horizontalSpace(8.w),
                                        const _NewBadge(),
                                      ],
                                    ],
                                  ),
                                  if (item.message.isNotEmpty) ...[
                                    UIHelper.verticalSpace(4.h),
                                    Text(
                                      item.message,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 12.sp, color: muted, height: 1.4),
                                    ),
                                  ],
                                  if (item.time.isNotEmpty) ...[
                                    UIHelper.verticalSpace(8.h),
                                    Row(
                                      children: [
                                        Icon(Icons.schedule_rounded, size: 12.sp, color: muted),
                                        UIHelper.horizontalSpace(4.w),
                                        Flexible(
                                          child: Text(
                                            item.time,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w500, color: muted),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(20.r)),
      child: Text(
        'New'.tr,
        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: Colors.white),
      ),
    );
  }
}

/// "All · Unread" segmented filter.
class NotificationFilterBar extends StatelessWidget {
  final bool showUnreadOnly;
  final int totalCount;
  final int unreadCount;
  final ValueChanged<bool> onChanged;

  const NotificationFilterBar({
    super.key,
    required this.showUnreadOnly,
    required this.totalCount,
    required this.unreadCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              label: 'All'.tr,
              count: totalCount,
              selected: !showUnreadOnly,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _Segment(
              label: 'unread'.tr,
              count: unreadCount,
              selected: showUnreadOnly,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({required this.label, required this.count, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : AppColorsTheme.textMutedColor(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 9.h),
        decoration: BoxDecoration(
          gradient: selected ? const LinearGradient(colors: [primaryOrange, secondaryOrange]) : null,
          borderRadius: BorderRadius.circular(11.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800, color: foreground),
              ),
            ),
            UIHelper.horizontalSpace(6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: selected ? Colors.white.withValues(alpha: 0.25) : AppColorsTheme.innerCardBg(context),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '$count',
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading placeholder shaped like notification cards.
class NotificationListShimmer extends StatelessWidget {
  const NotificationListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6.r)),
        );

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Column(
        children: [
          bar(double.infinity, 44.h),
          UIHelper.verticalSpace(16.h),
          for (var i = 0; i < 5; i++)
            Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColorsTheme.cardBg(context),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bar(40.w, 40.w),
                  UIHelper.horizontalSpace(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        bar(160.w, 13.h),
                        UIHelper.verticalSpace(8.h),
                        bar(double.infinity, 10.h),
                        UIHelper.verticalSpace(6.h),
                        bar(120.w, 10.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
