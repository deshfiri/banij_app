import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/dashboard_provider.dart';

class OrderCategoryDetailSheet extends StatefulWidget {
  final String orderTitle;

  const OrderCategoryDetailSheet({
    super.key,
    required this.orderTitle,
  });

  static void show(BuildContext context, String orderTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderCategoryDetailSheet(orderTitle: orderTitle),
    );
  }

  @override
  State<OrderCategoryDetailSheet> createState() => _OrderCategoryDetailSheetState();
}

class _OrderCategoryDetailSheetState extends State<OrderCategoryDetailSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<DashboardProvider>().fetchOrders();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardProvider = context.watch<DashboardProvider>();
    final rawOrders = dashboardProvider.orderResponse?.data ?? [];

    final filteredList = rawOrders.where((order) {
      final orderNumber = order.orderNumber?.toLowerCase() ?? '';
      final status = order.status?.toLowerCase() ?? '';
      return orderNumber.contains(_searchQuery.toLowerCase()) ||
          status.contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.84,
      decoration: BoxDecoration(
        color: AppColorsTheme.background(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20.r,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle bar
          UIHelper.verticalSpace(12.h),
          Center(
            child: Container(
              width: 42.w,
              height: 4.5.h,
              decoration: BoxDecoration(
                color: AppColorsTheme.textMutedColor(context).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          UIHelper.verticalSpace(12.h),

          // Sheet Top Header Bar: Title & Close Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.orderTitle,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(2.h),
                    Text(
                      'Manage and track customer orders',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColorsTheme.textMutedColor(context),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColorsTheme.cardBg(context),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColorsTheme.borderColor(context)),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20.sp,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(16.h),

          // Search Field Input
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: AppColorsTheme.cardBg(context),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColorsTheme.borderColor(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: primaryOrange,
                    size: 20.sp,
                  ),
                  UIHelper.horizontalSpace(10.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search orders...',
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: AppColorsTheme.textMutedColor(context),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      child: Icon(
                        Icons.clear_rounded,
                        size: 18.sp,
                        color: AppColorsTheme.textMutedColor(context),
                      ),
                    ),
                ],
              ),
            ),
          ),
          UIHelper.verticalSpace(16.h),

          // Scrollable Order List Cards
          Expanded(
            child: dashboardProvider.isLoadingOrders
                ? _buildOrderShimmer(context)
                : rawOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined, size: 48.sp, color: AppColorsTheme.textMutedColor(context)),
                            UIHelper.verticalSpace(12.h),
                            Text(
                              'order is not found',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColorsTheme.textMutedColor(context),
                              ),
                            ),
                          ],
                        ),
                      )
                    : filteredList.isEmpty
                        ? Center(
                            child: Text(
                              'No matching orders found',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColorsTheme.textMutedColor(context),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final order = filteredList[index];
                              final orderId = order.orderNumber ?? 'ORD-${order.id ?? index}';
                              final status = order.status ?? 'Pending';
                              final total = order.total?.toString() ?? '0.00';
                              final currency = order.currency ?? '৳';
                              final date = order.createdAt ?? 'Recent';

                              return Container(
                                margin: EdgeInsets.only(bottom: 14.h),
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: AppColorsTheme.cardBg(context),
                                  borderRadius: BorderRadius.circular(18.r),
                                  border: Border.all(
                                    color: AppColorsTheme.borderColor(context),
                                    width: 1.w,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                                      blurRadius: 10.r,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(12.w),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(14.r),
                                          ),
                                          child: Icon(
                                            Icons.shopping_bag_outlined,
                                            color: const Color(0xFF0284C7),
                                            size: 24.sp,
                                          ),
                                        ),
                                        UIHelper.horizontalSpace(12.w),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Order #$orderId',
                                              style: TextStyle(
                                                fontSize: 14.5.sp,
                                                fontWeight: FontWeight.w800,
                                                color: AppColorsTheme.textMainColor(context),
                                              ),
                                            ),
                                            UIHelper.verticalSpace(4.h),
                                            Text(
                                              date,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: AppColorsTheme.textMutedColor(context),
                                              ),
                                            ),
                                            UIHelper.verticalSpace(6.h),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(8.r),
                                              ),
                                              child: Text(
                                                status.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 9.5.sp,
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color(0xFF10B981),
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
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
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            margin: EdgeInsets.only(bottom: 14.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColorsTheme.cardBg(context),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: AppColorsTheme.borderColor(context),
                width: 1.w,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    UIHelper.horizontalSpace(12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 120.w, height: 14.h, color: Colors.white),
                        UIHelper.verticalSpace(6.h),
                        Container(width: 80.w, height: 12.h, color: Colors.white),
                        UIHelper.verticalSpace(8.h),
                        Container(
                          width: 60.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(width: 70.w, height: 20.h, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}
