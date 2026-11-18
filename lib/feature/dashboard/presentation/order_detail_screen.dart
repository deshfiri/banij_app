import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/dashboard_provider.dart';
import '../../finance/presentation/widgets/invoice_receipt_preview_modal.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final order = dashboardProvider.selectedOrderModel;

    final orderNumber = order?.orderNumber ?? order?.reference ?? 'ORD-${order?.id ?? widget.orderId}';
    final status = order?.status ?? 'Paid';
    final currency = order?.currency ?? '৳';
    final date = order?.createdAt ?? '11/18/2026';
    final placedBy = order?.placedBy ?? 'Mohammad Ashraf';
    final invoiceNumber = order?.invoice?.number ?? 'INV-2026-000001';

    String totalText = '150.00';
    final totalVal = order?.totals?.total?.formatted ?? order?.total;
    if (totalVal is Map) {
      totalText = totalVal['formatted']?.toString() ?? totalVal['amount']?.toString() ?? '150.00';
    } else if (totalVal != null) {
      totalText = totalVal.toString();
    }
    final displayTotal = totalText.startsWith('৳') || totalText.startsWith(currency) ? totalText : '$currency $totalText';

    final lines = order?.lines ?? [];
    final billing = order?.addresses?.billing;
    final shipping = order?.addresses?.shipping;
    final timeline = order?.timeline ?? [];
    final totals = order?.totals;

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppColorsTheme.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColorsTheme.textMainColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Details'.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
      ),
      body: dashboardProvider.isLoadingOrderDetail
          ? _buildDetailShimmer(context)
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Order Header Card
                  Container(
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: AppColorsTheme.cardBg(context),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColorsTheme.borderColor(context)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
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
                              child: Text(
                                'Order $orderNumber',
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColorsTheme.textMainColor(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: primaryOrange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 12.sp, color: primaryOrange),
                                  UIHelper.horizontalSpace(4.w),
                                  Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: primaryOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        UIHelper.verticalSpace(6.h),
                        Text(
                          'Placed on $date by $placedBy',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColorsTheme.textMutedColor(context),
                          ),
                        ),
                        UIHelper.verticalSpace(14.h),
                        Divider(color: AppColorsTheme.borderColor(context)),
                        UIHelper.verticalSpace(12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ORDER TOTAL'.tr,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColorsTheme.textMutedColor(context),
                              ),
                            ),
                            Text(
                              displayTotal,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),

                  // 2. Progress Tracker Bars (Placed -> Paid -> Shipped -> Delivered)
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColorsTheme.cardBg(context),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: AppColorsTheme.borderColor(context)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildProgressSegment(context, 'Placed'.tr, true),
                            UIHelper.horizontalSpace(6.w),
                            _buildProgressSegment(context, 'Paid'.tr, true),
                            UIHelper.horizontalSpace(6.w),
                            _buildProgressSegment(context, 'Shipped'.tr, false),
                            UIHelper.horizontalSpace(6.w),
                            _buildProgressSegment(context, 'Delivered'.tr, false),
                          ],
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),

                  // 3. Payment Received Alert Box
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: primaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: primaryOrange.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded, color: primaryOrange),
                        UIHelper.horizontalSpace(12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment received'.tr,
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColorsTheme.textMainColor(context),
                                ),
                              ),
                              UIHelper.verticalSpace(2.h),
                              Text(
                                'Paid on $date. The stock for this order is set aside for you.'.tr,
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  color: AppColorsTheme.textMutedColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpace(20.h),

                  // 4. Products Section (Dynamic from lines)
                  Text(
                    'Products'.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(10.h),
                  if (lines.isNotEmpty)
                    ...lines.map((line) {
                      final lineTotal = line.total?.formatted ?? displayTotal;
                      final unitPrice = line.unitPrice?.formatted ?? '';
                      return Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColorsTheme.cardBg(context),
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(color: AppColorsTheme.borderColor(context)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52.w,
                              height: 52.h,
                              decoration: BoxDecoration(
                                color: primaryOrange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: Icon(Icons.shopping_bag_outlined, color: primaryOrange, size: 24.sp),
                              ),
                            ),
                            UIHelper.horizontalSpace(12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    line.name ?? 'Product Item',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColorsTheme.textMainColor(context),
                                    ),
                                  ),
                                  UIHelper.verticalSpace(2.h),
                                  Text(
                                    'SKU: ${line.sku ?? "N/A"}\n${line.quantity ?? 1} × $unitPrice',
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      color: AppColorsTheme.textMutedColor(context),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              lineTotal,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w900,
                                color: primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                  else
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColorsTheme.cardBg(context),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(color: AppColorsTheme.borderColor(context)),
                      ),
                      child: Text('No product items found'.tr, style: TextStyle(color: AppColorsTheme.textMutedColor(context))),
                    ),
                  UIHelper.verticalSpace(20.h),

                  // 5. Billing & Shipping Address Section
                  Row(
                    children: [
                      Expanded(
                        child: _buildAddressBox(
                          context,
                          title: 'Billing address'.tr,
                          name: billing?.contactName ?? 'MD Hira',
                          phone: billing?.contactMobile ?? '',
                          address: billing?.fullAddressFormatted.isNotEmpty == true
                              ? billing!.fullAddressFormatted
                              : 'Mathbari, Rajapur, Jhalakathi',
                        ),
                      ),
                      UIHelper.horizontalSpace(12.w),
                      Expanded(
                        child: _buildAddressBox(
                          context,
                          title: 'Shipping address'.tr,
                          name: shipping?.contactName ?? 'MD Hira',
                          phone: shipping?.contactMobile ?? '',
                          address: shipping?.fullAddressFormatted.isNotEmpty == true
                              ? shipping!.fullAddressFormatted
                              : 'Mathbari, Rajapur, Jhalakathi',
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(20.h),

                  // 6. Order Timeline Section
                  if (timeline.isNotEmpty) ...[
                    Text(
                      'Order timeline'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(10.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColorsTheme.cardBg(context),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(color: AppColorsTheme.borderColor(context)),
                      ),
                      child: Column(
                        children: timeline.map((t) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_rounded, color: primaryOrange, size: 18.sp),
                                UIHelper.horizontalSpace(10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.status?.toUpperCase() ?? 'STATUS',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppColorsTheme.textMainColor(context),
                                        ),
                                      ),
                                      UIHelper.verticalSpace(2.h),
                                      Text(
                                        t.note ?? '',
                                        style: TextStyle(
                                          fontSize: 11.5.sp,
                                          color: AppColorsTheme.textMutedColor(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    UIHelper.verticalSpace(20.h),
                  ],

                  // 7. Summary Financial Section
                  Text(
                    'Summary'.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(10.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColorsTheme.cardBg(context),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: AppColorsTheme.borderColor(context)),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(context, 'Subtotal'.tr, totals?.subtotal?.formatted ?? displayTotal),
                        UIHelper.verticalSpace(8.h),
                        _buildSummaryRow(context, 'Delivery'.tr, totals?.delivery?.formatted ?? '$currency 0.00'),
                        UIHelper.verticalSpace(12.h),
                        Divider(color: AppColorsTheme.borderColor(context)),
                        UIHelper.verticalSpace(12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total'.tr,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColorsTheme.textMainColor(context),
                              ),
                            ),
                            Text(
                              totals?.total?.formatted ?? displayTotal,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpace(20.h),

                  // 8. Invoice & Receipt Section (View Official Invoice Button)
                  Text(
                    'Invoice & Billing'.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(10.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColorsTheme.cardBg(context),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: AppColorsTheme.borderColor(context)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: primaryOrange.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.receipt_long_rounded, color: primaryOrange, size: 22.sp),
                              ),
                              UIHelper.horizontalSpace(12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Official Tax Invoice'.tr,
                                      style: TextStyle(
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColorsTheme.textMainColor(context),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    UIHelper.verticalSpace(2.h),
                                    Text(
                                      invoiceNumber,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: AppColorsTheme.textMutedColor(context),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        UIHelper.horizontalSpace(8.w),
                        ElevatedButton.icon(
                          onPressed: () {
                            InvoiceReceiptPreviewModal.show(
                              context,
                              title: 'Invoice'.tr,
                              docNo: invoiceNumber,
                              clientOrGateway: placedBy,
                              date: date,
                              dueDateOrTime: 'Net 30',
                              amount: displayTotal,
                              status: status.toUpperCase(),
                              isInvoice: true,
                            );
                          },
                          icon: Icon(Icons.visibility_rounded, size: 16.sp),
                          label: Text(
                            'View Invoice'.tr,
                            style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryOrange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpace(30.h),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressSegment(BuildContext context, String label, bool isDone) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4.h,
            decoration: BoxDecoration(
              color: isDone ? primaryOrange : AppColorsTheme.borderColor(context),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          UIHelper.verticalSpace(6.h),
          Row(
            children: [
              Icon(
                isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                size: 14.sp,
                color: isDone ? primaryOrange : AppColorsTheme.textMutedColor(context),
              ),
              UIHelper.horizontalSpace(4.w),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
                    color: isDone ? AppColorsTheme.textMainColor(context) : AppColorsTheme.textMutedColor(context),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressBox(BuildContext context, {required String title, required String name, required String phone, required String address}) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(8.h),
          Text(
            name,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.bold,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(2.h),
          Text(
            phone,
            style: TextStyle(
              fontSize: 11.5.sp,
              color: AppColorsTheme.textMutedColor(context),
            ),
          ),
          UIHelper.verticalSpace(4.h),
          Text(
            address,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColorsTheme.textMutedColor(context),
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColorsTheme.textMutedColor(context),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.bold,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: List.generate(4, (index) => Container(
            margin: EdgeInsets.only(bottom: 14.h),
            height: 90.h,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
          )),
        ),
      ),
    );
  }
}
