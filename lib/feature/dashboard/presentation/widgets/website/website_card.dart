import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

/// Website card: globe icon, name/host, status pill, account and connection.
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
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColorsTheme.borderColor(context),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 8.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.language_rounded, color: primaryOrange, size: 20.sp),
              ),
              UIHelper.horizontalSpace(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(2.h),
                    Text(
                      item.host,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColorsTheme.textMutedColor(context),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              _WebsiteStatusPill(status: item.status),
            ],
          ),
          UIHelper.verticalSpace(12.h),
          Divider(color: AppColorsTheme.borderColor(context)),
          UIHelper.verticalSpace(8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CapsLabel('ACCOUNT'),
                  UIHelper.verticalSpace(2.h),
                  Text(
                    item.account,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const _CapsLabel('CONNECTION'),
                  UIHelper.verticalSpace(2.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isHealthy ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        size: 12.sp,
                        color: connectionColor,
                      ),
                      UIHelper.horizontalSpace(4.w),
                      Text(
                        item.connection,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: connectionColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    item.lastSynced,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                ],
              ),
            ],
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
