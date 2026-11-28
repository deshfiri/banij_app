import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../providers/notification_provider.dart';
import '../../../../notification/model/notification_category.dart';

/// One notification card with a left-side bar and outline in its category
/// colour (order = blue, payment = green, …). Unread cards get a solid bar,
/// a stronger outline, a soft coloured glow and tint, a bold title and a
/// "New" badge; read cards keep a softer bar and faint outline so the type
/// still shows at a glance.
class NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const NotificationTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread = !item.isRead;
    final category = item.category;
    final accent = category.accent(context);
    final muted = AppColorsTheme.textMutedColor(context);
    final radius = BorderRadius.circular(18.r);
    final cardBg = AppColorsTheme.cardBg(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: accent.withValues(alpha: 0.1),
          highlightColor: accent.withValues(alpha: 0.05),
          child: Ink(
            decoration: BoxDecoration(
              color: unread ? Color.alphaBlend(category.color.withValues(alpha: isDark ? 0.09 : 0.045), cardBg) : cardBg,
              borderRadius: radius,
              border: Border.all(
                color: accent.withValues(alpha: unread ? (isDark ? 0.6 : 0.5) : (isDark ? 0.24 : 0.2)),
                width: unread ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: unread
                      ? category.color.withValues(alpha: isDark ? 0.2 : 0.12)
                      : Colors.black.withValues(alpha: isDark ? 0.2 : 0.035),
                  blurRadius: unread ? 16.r : 10.r,
                  offset: Offset(0, unread ? 6 : 4),
                ),
              ],
            ),
            // Clipped to the card's shape so the left bar follows its
            // rounded corners.
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                children: [
                  Padding(
                    // Left inset = bar width + the usual 14.
                    padding: EdgeInsets.fromLTRB(_barWidth.w + 14.w, 14.h, 14.w, 14.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: category.tint(context, strong: unread),
                            borderRadius: BorderRadius.circular(13.r),
                            border: Border.all(color: accent.withValues(alpha: unread ? 0.3 : 0.14)),
                          ),
                          child: Icon(
                            category.icon,
                            size: 21.sp,
                            color: unread ? accent : accent.withValues(alpha: 0.75),
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
                              UIHelper.verticalSpace(10.h),
                              // Hairline in the category colour between body and meta.
                              Divider(height: 1, thickness: 1, color: accent.withValues(alpha: isDark ? 0.16 : 0.12)),
                              UIHelper.verticalSpace(9.h),
                              _MetaRow(category: category, time: item.time),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Left-side border in the category colour: solid when
                  // unread, softer once read.
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: _barWidth.w,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: unread
                              ? [accent, accent.withValues(alpha: 0.7)]
                              : [accent.withValues(alpha: isDark ? 0.65 : 0.6), accent.withValues(alpha: isDark ? 0.45 : 0.4)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const double _barWidth = 5;
}

/// Category label pill followed by the relative time.
class _MetaRow extends StatelessWidget {
  final NotificationCategory category;
  final String time;

  const _MetaRow({required this.category, required this.time});

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: category.tint(context, strong: false),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            category.labelKey.tr,
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: category.accent(context),
            ),
          ),
        ),
        if (time.isNotEmpty) ...[
          UIHelper.horizontalSpace(8.w),
          Icon(Icons.schedule_rounded, size: 12.sp, color: muted),
          UIHelper.horizontalSpace(4.w),
          Flexible(
            child: Text(
              time,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w500, color: muted),
            ),
          ),
        ],
      ],
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
        'notif_new'.tr,
        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: Colors.white),
      ),
    );
  }
}

/// "TODAY · 3" style heading above each day group.
class NotificationSectionHeader extends StatelessWidget {
  final String label;
  final int count;

  const NotificationSectionHeader({super.key, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 6.h, 4.w, 10.h),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: muted),
          ),
          UIHelper.horizontalSpace(6.w),
          Text(
            '$count',
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: muted.withValues(alpha: 0.7)),
          ),
          UIHelper.horizontalSpace(10.w),
          Expanded(child: Divider(height: 1, thickness: 1, color: AppColorsTheme.borderColor(context))),
        ],
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
              label: 'filter_all'.tr,
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

/// Horizontally scrolling category chips ("All", "Order 3", "Payment 1", …).
/// [selected] null means "All".
class NotificationCategoryChips extends StatelessWidget {
  final List<NotificationCategory> categories;
  final Map<NotificationCategory, int> counts;
  final NotificationCategory? selected;
  final ValueChanged<NotificationCategory?> onChanged;

  const NotificationCategoryChips({
    super.key,
    required this.categories,
    required this.counts,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _CategoryChip(
            label: 'filter_all'.tr,
            icon: Icons.apps_rounded,
            color: primaryOrange,
            selected: selected == null,
            onTap: () => onChanged(null),
          ),
          for (final category in categories)
            _CategoryChip(
              label: category.labelKey.tr,
              icon: category.icon,
              color: category.color,
              count: counts[category] ?? 0,
              selected: selected == category,
              onTap: () => onChanged(selected == category ? null : category),
            ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Color.lerp(color, Colors.white, 0.28)! : color;
    final foreground = selected ? Colors.white : AppColorsTheme.textMainColor(context);

    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: selected ? color : AppColorsTheme.cardBg(context),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: selected ? color : AppColorsTheme.borderColor(context)),
            boxShadow: selected
                ? [BoxShadow(color: color.withValues(alpha: isDark ? 0.3 : 0.25), blurRadius: 8.r, offset: const Offset(0, 3))]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15.sp, color: selected ? Colors.white : accent),
              UIHelper.horizontalSpace(6.w),
              Text(
                label,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: foreground),
              ),
              if (count != null) ...[
                UIHelper.horizontalSpace(6.w),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white.withValues(alpha: 0.85) : AppColorsTheme.textMutedColor(context),
                  ),
                ),
              ],
            ],
          ),
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
