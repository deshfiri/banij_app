import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/all_routes.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/order_model.dart';

class OrderItemCard extends StatelessWidget {
  final OrderItemModel order;
  final bool isStoreTab;
  final Function(String orderId) onCancelTap;

  const OrderItemCard({
    super.key,
    required this.order,
    this.isStoreTab = false,
    required this.onCancelTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orderId = order.orderNumber ?? 'ORD-${order.id ?? 1}';
    final status = order.status ?? 'Pending';
    final currency = order.currency ?? '৳';
    final date = order.createdAt ?? 'Recent';

    // Parse total safely whether it's a Map {amount, currency, formatted} or String/number
    String totalText = '0.00';
    final totalVal = order.total;
    if (totalVal is Map) {
      totalText = totalVal['formatted']?.toString() ?? totalVal['amount']?.toString() ?? '0.00';
    } else if (totalVal != null) {
      totalText = totalVal.toString();
    }
    final displayTotal = totalText.startsWith('৳') || totalText.startsWith(currency) ? totalText : '$currency $totalText';

    Color statusBg = warningYellowLight;
    Color statusFg = warningYellow;

    if (status.toLowerCase().contains('deliver') || status.toLowerCase().contains('complet') || status.toLowerCase().contains('active') || status.toLowerCase().contains('paid')) {
      statusBg = successGreenLight;
      statusFg = successGreenDark;
    } else if (status.toLowerCase().contains('cancel')) {
      statusBg = errorRedLight;
      statusFg = errorRed;
    } else if (status.toLowerCase().contains('process')) {
      statusBg = infoBlueLight;
      statusFg = infoBlue;
    }

    return GestureDetector(
      onTap: () {
        final targetId = order.id?.toString() ?? order.orderNumber ?? '1';
        Navigator.pop(context);
        Navigator.pushNamed(context, Routes.orderDetailScreen, arguments: targetId);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColorsTheme.cardBg(context),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColorsTheme.borderColor(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: primaryOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.receipt_long_rounded, color: primaryOrange, size: 20.sp),
                      ),
                      UIHelper.horizontalSpace(10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColorsTheme.textMainColor(context),
                              ),
                            ),
                            UIHelper.verticalSpace(2.h),
                            Text(
                              'Placed on $date',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColorsTheme.textMutedColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                UIHelper.horizontalSpace(8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 12.sp, color: statusFg),
                      UIHelper.horizontalSpace(4.w),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: statusFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            UIHelper.verticalSpace(12.h),
            Divider(color: AppColorsTheme.borderColor(context), height: 1.h),
            UIHelper.verticalSpace(12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount'.tr,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColorsTheme.textMutedColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(2.h),
                    Text(
                      displayTotal,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: primaryOrange,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (isStoreTab && !status.toLowerCase().contains('cancel')) ...[
                      OutlinedButton(
                        onPressed: () {
                          final targetId = order.id?.toString() ?? order.orderNumber ?? '';
                          if (targetId.isNotEmpty) {
                            onCancelTap(targetId);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        ),
                        child: Text(
                          'Cancel Order'.tr,
                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                      UIHelper.horizontalSpace(8.w),
                    ],
                    TextButton(
                      onPressed: () {
                        final targetId = order.id?.toString() ?? order.orderNumber ?? '1';
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.orderDetailScreen, arguments: targetId);
                      },
                      child: Text(
                        'View order'.tr,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
