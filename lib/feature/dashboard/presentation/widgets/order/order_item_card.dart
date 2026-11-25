import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/all_routes.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/order_model.dart';
import '../../../../../common_widget/payment_status_badge.dart';
import 'order_status_style.dart';

/// Order card in the orders list: number, date, status pill, total, and the
/// cancel (store tab) / view actions.
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

  /// Opens this order's detail screen.
  void _openDetail(BuildContext context) {
    final targetId = order.id?.toString() ?? order.orderNumber ?? '1';
    Navigator.pushNamed(context, Routes.orderDetailScreen, arguments: targetId);
  }

  void _cancel() {
    final targetId = order.id?.toString() ?? order.orderNumber ?? '';
    if (targetId.isNotEmpty) onCancelTap(targetId);
  }

  /// Total as text, whether the API sent a Map {amount, currency, formatted} or a String/number.
  String _displayTotal(String currency) {
    String totalText = '0.00';
    final totalVal = order.total;
    if (totalVal is Map) {
      totalText =
          totalVal['formatted']?.toString() ??
          totalVal['amount']?.toString() ??
          '0.00';
    } else if (totalVal != null) {
      totalText = totalVal.toString();
    }
    return totalText.startsWith('৳') || totalText.startsWith(currency)
        ? totalText
        : '$currency $totalText';
  }

  @override
  Widget build(BuildContext context) {
    final orderId = order.orderNumber ?? 'ORD-${order.id ?? 1}';
    final status = order.status ?? 'Pending';
    final currency = order.currency ?? '৳';
    final date = order.createdAt ?? 'Recent';
    final canCancel = isStoreTab && !status.toLowerCase().contains('cancel');
    final statusStyle = OrderStatusStyle.of(status);
    final statusColor = statusStyle.text(context);
    final clientName =
        order.addresses?.billing?.contactName ??
        order.placedBy ??
        'Customer'.tr;
    final radius = BorderRadius.circular(14.r);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColorsTheme.cardBg(context),
          borderRadius: radius,
          border: Border.all(
            color: AppColorsTheme.borderColor(context),
            width: 0.8.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.15
                    : 0.03,
              ),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openDetail(context),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: statusStyle.foreground, width: 4.w),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5.w),
                          decoration: BoxDecoration(
                            color: primaryOrange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: primaryOrange,
                            size: 16.sp,
                          ),
                        ),
                        UIHelper.horizontalSpace(6.w),
                        Expanded(
                          child: Text(
                            orderId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          ),
                        ),
                        UIHelper.horizontalSpace(6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 2.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (order.paymentState != null) ...[
                      UIHelper.verticalSpace(6.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: PaymentStatusBadge(rawStatus: order.paymentState, compact: true),
                      ),
                    ],
                    UIHelper.verticalSpace(8.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColorsTheme.innerCardBg(context),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          ),
                          UIHelper.verticalSpace(2.h),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 10.sp,
                                color: AppColorsTheme.textMutedColor(context),
                              ),
                              UIHelper.horizontalSpace(4.w),
                              Expanded(
                                child: Text(
                                  'Placed on @date'.trParams({'date': date}),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColorsTheme.textMutedColor(
                                      context,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    UIHelper.verticalSpace(8.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Amount'.tr,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: AppColorsTheme.textMutedColor(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              UIHelper.verticalSpace(1.h),
                              Text(
                                _displayTotal(currency),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w900,
                                  color: primaryOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (canCancel) ...[
                          _CancelButton(onTap: _cancel),
                          UIHelper.horizontalSpace(6.w),
                        ],
                        _ViewOrderButton(onTap: () => _openDetail(context)),
                      ],
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

class _CancelButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CancelButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: errorRed.withValues(alpha: 0.6)),
        ),
        child: Text(
          'Cancel Order'.tr,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            color: errorRed,
          ),
        ),
      ),
    );
  }
}

/// Small orange gradient "View order →" pill.
class _ViewOrderButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewOrderButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(Icons.arrow_forward_rounded, size: 12.sp),
        label: Text(
          'View order'.tr,
          style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
