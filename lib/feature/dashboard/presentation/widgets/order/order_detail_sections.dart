import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../finance/model/invoice_list_model.dart';
import '../../../../finance/presentation/invoice_details_screen.dart';
import '../../../model/order_model.dart';
import '../../../model/payment_status.dart';
import '../dashboard_card_decoration.dart';
import '../quick_access_section_widget.dart';
import '../../../../../common_widget/payment_status_badge.dart';
import 'order_status_style.dart';
import 'sheet_parts.dart';

/// Display values for the order detail screen, with the same fallbacks the
/// screen has always used when the API omits a field.
class OrderDetailData {
  final String orderNumber;
  final String status;
  final String currency;
  final String date;
  final String placedBy;
  final String invoiceNumber;
  final String displayTotal;

  /// Payment state from the order API (`payment_state`); null when not sent.
  final String? paymentState;

  const OrderDetailData({
    this.paymentState,
    required this.orderNumber,
    required this.status,
    required this.currency,
    required this.date,
    required this.placedBy,
    required this.invoiceNumber,
    required this.displayTotal,
  });

  factory OrderDetailData.from(OrderItemModel? order, String fallbackId) {
    final currency = order?.currency ?? '৳';

    String totalText = '—';
    final totalVal = order?.totals?.total?.formatted ?? order?.total;
    if (totalVal is Map) {
      totalText = totalVal['formatted']?.toString() ?? totalVal['amount']?.toString() ?? '—';
    } else if (totalVal != null) {
      totalText = totalVal.toString();
    }

    return OrderDetailData(
      orderNumber: order?.orderNumber ?? order?.reference ?? 'ORD-${order?.id ?? fallbackId}',
      status: order?.status ?? 'Unknown',
      paymentState: order?.paymentState,
      currency: currency,
      date: order?.createdAt ?? '—',
      placedBy: order?.placedBy ?? '—',
      invoiceNumber: order?.invoice?.number ?? '—',
      displayTotal: totalText.startsWith('৳') || totalText.startsWith(currency) ? totalText : '$currency $totalText',
    );
  }
}

/// Dashboard-style card surface used by every section of the order detail screen.
class OrderDetailCard extends StatelessWidget {
  final Widget child;
  final double padding;
  final double radius;
  final EdgeInsetsGeometry? margin;

  const OrderDetailCard({
    super.key,
    required this.child,
    this.padding = 16,
    this.radius = 18,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: EdgeInsets.all(padding.w),
      decoration: DashboardCardDecoration.of(context, radius: radius),
      child: child,
    );
  }
}

/// Section heading with the dashboard's orange accent bar, then a 10-point gap.
class OrderSectionTitle extends StatelessWidget {
  final String title;

  const OrderSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: DashboardSectionHeader(title: title),
    );
  }
}

/// Order number, status, placed-on line and total, shown inside the hero header.
class OrderDetailHeroSummary extends StatelessWidget {
  final OrderDetailData data;

  const OrderDetailHeroSummary({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.orderNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
              UIHelper.horizontalSpace(8.w),
              Flexible(child: OrderStatusPill(status: data.status, onHero: true)),
            ],
          ),
          if (data.paymentState != null) ...[
            UIHelper.verticalSpace(6.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
              child: PaymentStatusBadge(rawStatus: data.paymentState),
            ),
          ],
          UIHelper.verticalSpace(4.h),
          Text(
            'Placed on @date by @name'.trParams({'date': data.date, 'name': data.placedBy}),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5.sp, color: Colors.white.withValues(alpha: 0.85)),
          ),
          UIHelper.verticalSpace(12.h),
          Row(
            children: [
              Text(
                'ORDER TOTAL'.tr,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              UIHelper.horizontalSpace(8.w),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    data.displayTotal,
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Placed → Paid → Shipped → Delivered stepper, from the order's real
/// `status` and `payment_state`.
class OrderProgressCard extends StatelessWidget {
  final String? status;
  final String? paymentState;

  const OrderProgressCard({super.key, required this.status, required this.paymentState});

  List<(String, bool)> get _computedSteps {
    final s = status?.toLowerCase() ?? '';
    final delivered = s.contains('deliver') || s.contains('complet');
    final shipped = delivered || s.contains('ship') || s.contains('dispatch') || s.contains('transit');
    final paid = shipped || PaymentStatus.fromBackend(paymentState) == PaymentStatus.paid || s.contains('paid');
    return [('Placed', true), ('Paid', paid), ('Shipped', shipped), ('Delivered', delivered)];
  }

  @override
  Widget build(BuildContext context) {
    final steps = _computedSteps;
    return OrderDetailCard(
      padding: 14,
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++)
            Expanded(
              child: _ProgressStep(
                label: steps[i].$1.tr,
                isDone: steps[i].$2,
                lineBefore: i == 0 ? null : steps[i].$2,
                lineAfter: i == steps.length - 1 ? null : steps[i + 1].$2,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String label;
  final bool isDone;

  /// Connector colours: null = no connector, true = done (orange), false = pending.
  final bool? lineBefore;
  final bool? lineAfter;

  const _ProgressStep({required this.label, required this.isDone, this.lineBefore, this.lineAfter});

  @override
  Widget build(BuildContext context) {
    final border = AppColorsTheme.borderColor(context);
    Widget line(bool? done) => Expanded(
          child: Container(
            height: 3.h,
            decoration: BoxDecoration(
              color: done == null ? Colors.transparent : (done ? primaryOrange : border),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        );

    return Column(
      children: [
        Row(
          children: [
            line(lineBefore),
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isDone ? const LinearGradient(colors: [primaryOrange, secondaryOrange]) : null,
                color: isDone ? null : AppColorsTheme.cardBg(context),
                border: Border.all(color: isDone ? Colors.transparent : border, width: 1.5),
                boxShadow: isDone
                    ? [BoxShadow(color: primaryOrange.withValues(alpha: 0.3), blurRadius: 6.r, offset: const Offset(0, 2))]
                    : null,
              ),
              child: Icon(
                isDone ? Icons.check_rounded : Icons.circle_outlined,
                size: isDone ? 16.sp : 10.sp,
                color: isDone ? Colors.white : AppColorsTheme.textMutedColor(context),
              ),
            ),
            line(lineAfter),
          ],
        ),
        UIHelper.verticalSpace(6.h),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: isDone ? FontWeight.w800 : FontWeight.w500,
            color: isDone ? AppColorsTheme.textMainColor(context) : AppColorsTheme.textMutedColor(context),
          ),
        ),
      ],
    );
  }
}

/// Payment notice from the order's real `payment_state`: green when paid,
/// orange when pending / unpaid, red when failed, blue when refunded.
/// Hidden when the API sends no payment state.
class OrderPaymentBanner extends StatelessWidget {
  final String? paymentState;
  final String date;

  const OrderPaymentBanner({super.key, required this.paymentState, required this.date});

  @override
  Widget build(BuildContext context) {
    if (paymentState == null || paymentState!.trim().isEmpty) return const SizedBox.shrink();
    final status = PaymentStatus.fromBackend(paymentState);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = status.color;

    final (String title, String message) = switch (status) {
      PaymentStatus.paid => ('Payment received', 'Paid on @date. The stock for this order is set aside for you.'.trParams({'date': date})),
      PaymentStatus.failed => ('Payment failed', 'The payment for this order did not go through.'),
      PaymentStatus.cancelled => ('Payment cancelled', 'The payment for this order was cancelled.'),
      PaymentStatus.refunded || PaymentStatus.partiallyRefunded => ('Payment refunded', 'This order\'s payment was refunded.'),
      PaymentStatus.processing => ('Payment processing', 'The payment is being confirmed.'),
      PaymentStatus.unknown => ('Payment', paymentState!),
      _ => ('Payment pending', 'This order has not been paid yet.'),
    };

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.18), shape: BoxShape.circle),
            child: Icon(status == PaymentStatus.paid ? Icons.verified_rounded : status.icon, color: color, size: 20.sp),
          ),
          UIHelper.horizontalSpace(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.tr,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                UIHelper.verticalSpace(2.h),
                Text(
                  message.tr,
                  style: TextStyle(fontSize: 11.5.sp, height: 1.35, color: AppColorsTheme.textMutedColor(context)),
                ),
              ],
            ),
          ),
          UIHelper.horizontalSpace(8.w),
          PaymentStatusBadge(rawStatus: paymentState, compact: true),
        ],
      ),
    );
  }
}

/// The "Products" list, or a placeholder card when the order has no lines.
class OrderLinesSection extends StatelessWidget {
  final List<OrderLineModel> lines;
  final String fallbackTotal;

  const OrderLinesSection({super.key, required this.lines, required this.fallbackTotal});

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return OrderDetailCard(
        child: Row(
          children: [
            Icon(Icons.inventory_2_outlined, color: AppColorsTheme.textMutedColor(context), size: 20.sp),
            UIHelper.horizontalSpace(10.w),
            Expanded(
              child: Text('No product items found'.tr, style: TextStyle(color: AppColorsTheme.textMutedColor(context))),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final line in lines) _OrderLineTile(line: line, fallbackTotal: fallbackTotal)],
    );
  }
}

class _OrderLineTile extends StatelessWidget {
  final OrderLineModel line;
  final String fallbackTotal;

  const _OrderLineTile({required this.line, required this.fallbackTotal});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineTotal = line.total?.formatted ?? fallbackTotal;
    final unitPrice = line.unitPrice?.formatted ?? '';

    return OrderDetailCard(
      padding: 12,
      margin: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: isDark ? 0.18 : 0.08),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Icons.shopping_bag_outlined, color: primaryOrange, size: 24.sp),
          ),
          UIHelper.horizontalSpace(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name ?? 'Product Item',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                UIHelper.verticalSpace(3.h),
                Text(
                  'SKU: ${line.sku ?? "N/A"}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, color: AppColorsTheme.textMutedColor(context)),
                ),
                UIHelper.verticalSpace(2.h),
                Text(
                  '${line.quantity ?? 1} × $unitPrice',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
              ],
            ),
          ),
          UIHelper.horizontalSpace(8.w),
          Text(
            lineTotal,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: primaryOrange),
          ),
        ],
      ),
    );
  }
}

/// Billing and shipping address boxes side by side.
class OrderAddressesRow extends StatelessWidget {
  final OrderAddressDetailModel? billing;
  final OrderAddressDetailModel? shipping;

  const OrderAddressesRow({super.key, this.billing, this.shipping});

  // Shown when the API sends no address for the order.
  static const String _fallbackName = 'MD Hira';
  static const String _fallbackAddress = 'Mathbari, Rajapur, Jhalakathi';

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _box('Billing address'.tr, Icons.receipt_long_rounded, billing)),
          UIHelper.horizontalSpace(12.w),
          Expanded(child: _box('Shipping address'.tr, Icons.local_shipping_outlined, shipping)),
        ],
      ),
    );
  }

  Widget _box(String title, IconData icon, OrderAddressDetailModel? address) {
    return _AddressBox(
      title: title,
      icon: icon,
      name: address?.contactName ?? _fallbackName,
      phone: address?.contactMobile ?? '',
      address: address?.fullAddressFormatted.isNotEmpty == true ? address!.fullAddressFormatted : _fallbackAddress,
    );
  }
}

class _AddressBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final String name;
  final String phone;
  final String address;

  const _AddressBox({
    required this.title,
    required this.icon,
    required this.name,
    required this.phone,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = AppColorsTheme.textMutedColor(context);
    final main = AppColorsTheme.textMainColor(context);

    return OrderDetailCard(
      padding: 12,
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: isDark ? 0.18 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14.sp, color: primaryOrange),
              ),
              UIHelper.horizontalSpace(6.w),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: main),
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(10.h),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800, color: main),
          ),
          if (phone.isNotEmpty) ...[
            UIHelper.verticalSpace(2.h),
            Text(phone, style: TextStyle(fontSize: 11.5.sp, color: muted)),
          ],
          UIHelper.verticalSpace(4.h),
          Text(
            address,
            style: TextStyle(fontSize: 11.sp, color: muted, height: 1.3),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Vertical order timeline: orange step dots joined by a connector line.
class OrderTimelineCard extends StatelessWidget {
  final List<OrderTimelineModel> timeline;

  const OrderTimelineCard({super.key, required this.timeline});

  @override
  Widget build(BuildContext context) {
    return OrderDetailCard(
      child: Column(
        children: [
          for (int i = 0; i < timeline.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 22.w,
                        height: 22.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [primaryOrange, secondaryOrange]),
                        ),
                        child: Icon(Icons.check_rounded, size: 13.sp, color: Colors.white),
                      ),
                      if (i < timeline.length - 1)
                        Expanded(
                          child: Container(
                            width: 2.w,
                            margin: EdgeInsets.symmetric(vertical: 3.h),
                            color: primaryOrange.withValues(alpha: 0.35),
                          ),
                        ),
                    ],
                  ),
                  UIHelper.horizontalSpace(12.w),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: i < timeline.length - 1 ? 14.h : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            timeline[i].status?.toUpperCase() ?? 'STATUS',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          ),
                          UIHelper.verticalSpace(2.h),
                          Text(
                            timeline[i].note ?? '',
                            style: TextStyle(fontSize: 11.5.sp, color: AppColorsTheme.textMutedColor(context)),
                          ),
                        ],
                      ),
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

/// Subtotal / delivery, then the highlighted total.
class OrderSummaryCard extends StatelessWidget {
  final OrderTotalsModel? totals;
  final OrderDetailData data;

  const OrderSummaryCard({super.key, required this.totals, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OrderDetailCard(
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal'.tr, value: totals?.subtotal?.formatted ?? data.displayTotal),
          UIHelper.verticalSpace(10.h),
          _SummaryRow(label: 'Delivery'.tr, value: totals?.delivery?.formatted ?? '${data.currency} 0.00'),
          UIHelper.verticalSpace(12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: isDark ? 0.14 : 0.07),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Text(
                  'Total'.tr,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                UIHelper.horizontalSpace(8.w),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      totals?.total?.formatted ?? data.displayTotal,
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                    ),
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context))),
          Text(
            value,
            style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800, color: AppColorsTheme.textMainColor(context)),
          ),
        ],
      ),
    );
  }
}

/// Official tax invoice row with the "View Invoice" button.
class OrderInvoiceCard extends StatelessWidget {
  final OrderDetailData data;

  /// The order's invoice (`invoice` in the order API). Null = none issued yet.
  final OrderInvoiceModel? invoice;

  const OrderInvoiceCard({super.key, required this.data, required this.invoice});

  bool get _hasInvoice => invoice?.id?.trim().isNotEmpty == true;

  /// Opens Invoice Details, which loads `GET /invoices/{id}` (lines, totals,
  /// payment) with PDF preview / print / download.
  void _openInvoice(BuildContext context) {
    InvoiceDetailsScreen.open(
      context,
      invoice: InvoiceItemModel(id: invoice!.id, number: invoice!.number),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OrderDetailCard(
      padding: 14,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: isDark ? 0.18 : 0.1),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                UIHelper.verticalSpace(2.h),
                Text(
                  _hasInvoice ? (invoice!.number ?? data.invoiceNumber) : 'No invoice issued yet'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, color: AppColorsTheme.textMutedColor(context)),
                ),
              ],
            ),
          ),
          UIHelper.horizontalSpace(8.w),
          GestureDetector(
            onTap: _hasInvoice ? () => _openInvoice(context) : null,
            child: Opacity(
              opacity: _hasInvoice ? 1 : 0.45,
              child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [primaryOrange, secondaryOrange]),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(color: primaryOrange.withValues(alpha: 0.3), blurRadius: 8.r, offset: const Offset(0, 3)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility_rounded, size: 15.sp, color: Colors.white),
                  UIHelper.horizontalSpace(5.w),
                  Text(
                    'View Invoice'.tr,
                    style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grey blocks shown while the order detail loads.
class OrderDetailShimmer extends StatelessWidget {
  const OrderDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SheetShimmer(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: List.generate(
            4,
            (index) => Container(
              margin: EdgeInsets.only(bottom: 14.h),
              height: 90.h,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18.r)),
            ),
          ),
        ),
      ),
    );
  }
}
