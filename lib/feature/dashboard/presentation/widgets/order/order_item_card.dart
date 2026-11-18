import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
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
    final total = order.total?.toString() ?? '0.00';
    final currency = order.currency ?? '৳';
    final date = order.createdAt ?? 'Recent';

    Color statusBg = const Color(0xFFFEF3C7);
    Color statusFg = const Color(0xFFD97706);

    if (status.toLowerCase().contains('deliver') || status.toLowerCase().contains('complet')) {
      statusBg = const Color(0xFFD1FAE5);
      statusFg = const Color(0xFF059669);
    } else if (status.toLowerCase().contains('cancel')) {
      statusBg = const Color(0xFFFEE2E2);
      statusFg = const Color(0xFFDC2626);
    } else if (status.toLowerCase().contains('process')) {
      statusBg = const Color(0xFFDBEAFE);
      statusFg = const Color(0xFF2563EB);
    }

    return Container(
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
              Row(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderId,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                      UIHelper.verticalSpace(2.h),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColorsTheme.textMutedColor(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: statusFg,
                  ),
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
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(2.h),
                  Text(
                    '$currency $total',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: primaryOrange,
                    ),
                  ),
                ],
              ),
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
                    'Cancel Order',
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
