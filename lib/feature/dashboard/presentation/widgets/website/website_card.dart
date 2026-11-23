import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/website_model.dart';
import '../order/sheet_parts.dart';

/// One row in the partner websites list, built from either an owned website
/// or a website allocation, with the same fallbacks the sheet always used.
class WebsiteListItem {
  final String name;
  final String host;
  final String account;
  final String status;
  final String connection;
  final String lastSynced;

  const WebsiteListItem({
    required this.name,
    required this.host,
    required this.account,
    required this.status,
    required this.connection,
    required this.lastSynced,
  });

  static const String _defaultHost = 'feriwala.shop';
  static const String _notConnected = 'Not connected yet';
  static const String _never = 'Never';

  /// Websites first, then allocations — the order the sheet always showed.
  static List<WebsiteListItem> fromResponse(MyWebsitesResponseModel? response) {
    return [
      for (final item in response?.data ?? const [])
        WebsiteListItem(
          name: item.name ?? item.host ?? 'Partner Website',
          host: item.host ?? _defaultHost,
          account: item.name ?? 'Partner Account',
          status: item.statusLabel ?? item.status ?? 'Active',
          connection: item.connectionHealth ?? _notConnected,
          lastSynced: item.lastSyncedAt ?? _never,
        ),
      for (final alloc in response?.allocations ?? const [])
        WebsiteListItem(
          name: alloc.name ?? alloc.domainName ?? 'Partner Website',
          host: alloc.domainName ?? alloc.website?.host ?? _defaultHost,
          account: alloc.partnerName ?? alloc.name ?? 'Partner Account',
          status: alloc.statusLabel ?? alloc.status ?? 'Setup pending',
          connection: _notConnected,
          lastSynced: _never,
        ),
    ];
  }

  bool matches(String query, String statusFilter, String everyStatus) {
    final q = query.toLowerCase();
    final matchesSearch = name.toLowerCase().contains(q) || host.toLowerCase().contains(q);
    final matchesStatus = statusFilter == everyStatus || status.toLowerCase().contains(statusFilter.toLowerCase());
    return matchesSearch && matchesStatus;
  }
}

/// Website card matching the invoice/order card design pattern.
class WebsiteCard extends StatelessWidget {
  final WebsiteListItem item;

  const WebsiteCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHealthy = item.connection.toLowerCase().contains('healthy');
    final connectionColor = isHealthy ? successGreen : AppColorsTheme.textMutedColor(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : primaryOrange.withValues(alpha: 0.22),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Left vertical accent indicator bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4.w,
              color: primaryOrange,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.w, 14.w, 14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Icon + Name + Status Pill
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: primaryOrange.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.language_rounded, color: primaryOrange, size: 18.sp),
                    ),
                    UIHelper.horizontalSpace(10.w),
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _WebsiteStatusPill(status: item.status),
                  ],
                ),
                UIHelper.verticalSpace(12.h),

                // Inner Tinted Container for Host
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColorsTheme.innerCardBg(context) : const Color(0xFFFFF6F0),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: primaryOrange.withValues(alpha: 0.15),
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.link_rounded, size: 14.sp, color: primaryOrange),
                      UIHelper.horizontalSpace(6.w),
                      Expanded(
                        child: Text(
                          item.host,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColorsTheme.textMainColor(context),
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                UIHelper.verticalSpace(12.h),

                // Bottom Row: Account / Connection + Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _CapsLabel('ACCOUNT'),
                          UIHelper.verticalSpace(2.h),
                          Text(
                            item.account,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          UIHelper.verticalSpace(4.h),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isHealthy ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                size: 11.sp,
                                color: connectionColor,
                              ),
                              UIHelper.horizontalSpace(3.w),
                              Text(
                                item.connection,
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: connectionColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    UIHelper.horizontalSpace(8.w),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Action / Manage Website
                      },
                      icon: Icon(Icons.arrow_forward_rounded, size: 14.sp, color: Colors.white),
                      label: Text(
                        'Manage'.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Green "active" / blue "pending" pill.
class _WebsiteStatusPill extends StatelessWidget {
  final String status;

  const _WebsiteStatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase().contains('active');
    final color = isActive ? successGreen : infoBlue;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle_outline_rounded : Icons.sync_rounded,
            size: 12.sp,
            color: color,
          ),
          UIHelper.horizontalSpace(4.w),
          Text(
            status,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CapsLabel extends StatelessWidget {
  final String text;

  const _CapsLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 9.5.sp,
        fontWeight: FontWeight.w800,
        color: AppColorsTheme.textMutedColor(context),
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Shimmer placeholder shaped like a [WebsiteCard].
class WebsiteCardShimmer extends StatelessWidget {
  const WebsiteCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SheetShimmer(
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColorsTheme.cardBg(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColorsTheme.borderColor(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                UIHelper.horizontalSpace(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 140.w, height: 14.h, color: Colors.white),
                      UIHelper.verticalSpace(6.h),
                      Container(width: 100.w, height: 11.h, color: Colors.white),
                    ],
                  ),
                ),
                Container(
                  width: 70.w,
                  height: 22.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ],
            ),
            UIHelper.verticalSpace(12.h),
            Container(width: double.infinity, height: 1.h, color: Colors.white),
            UIHelper.verticalSpace(8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 80.w, height: 14.h, color: Colors.white),
                Container(width: 90.w, height: 14.h, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
