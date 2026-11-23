import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/dashboard_provider.dart';
import '../model/order_model.dart';
import 'widgets/order/order_detail_sections.dart';

/// One order: hero summary (number, status, total), progress, payment notice,
/// products, addresses, timeline, totals and invoice.
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
    // Rebuild only when the order or its loading flag changes.
    final isLoading = context.select<DashboardProvider, bool>((p) => p.isLoadingOrderDetail);
    final order = context.select<DashboardProvider, OrderItemModel?>((p) => p.selectedOrderModel);
    final data = OrderDetailData.from(order, widget.orderId);
    final timeline = order?.timeline ?? const <OrderTimelineModel>[];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            HeroPageHeader(
              title: 'Order Details'.tr,
              onBack: () => Navigator.pop(context),
              bottom: isLoading ? null : OrderDetailHeroSummary(data: data),
            ),
            Expanded(
              child: isLoading
                  ? const OrderDetailShimmer()
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 30.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OrderSectionTitle('Order progress'.tr),
                          const OrderProgressCard(),
                          UIHelper.verticalSpace(14.h),
                          PaymentReceivedBanner(date: data.date),
                          UIHelper.verticalSpace(22.h),
                          OrderSectionTitle('Products'.tr),
                          OrderLinesSection(lines: order?.lines ?? const [], fallbackTotal: data.displayTotal),
                          UIHelper.verticalSpace(12.h),
                          OrderSectionTitle('Addresses'.tr),
                          OrderAddressesRow(billing: order?.addresses?.billing, shipping: order?.addresses?.shipping),
                          UIHelper.verticalSpace(22.h),
                          if (timeline.isNotEmpty) ...[
                            OrderSectionTitle('Order timeline'.tr),
                            OrderTimelineCard(timeline: timeline),
                            UIHelper.verticalSpace(22.h),
                          ],
                          OrderSectionTitle('Summary'.tr),
                          OrderSummaryCard(totals: order?.totals, data: data),
                          UIHelper.verticalSpace(22.h),
                          OrderSectionTitle('Invoice & Billing'.tr),
                          OrderInvoiceCard(data: data),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
