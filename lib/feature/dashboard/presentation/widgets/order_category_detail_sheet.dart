import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/dashboard_provider.dart';
import '../../model/order_model.dart';
import 'order/order_cancellation_dialog.dart';
import 'order/order_item_card.dart';
import 'order/order_tab_chips.dart';
import 'order_advanced_filter_sheet.dart';

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
  String _selectedTypeTab = 'all'; // 'all', 'store', 'stores'

  String? _currentSearch;
  String? _currentSource;
  String? _currentStore;
  String? _currentStatus;
  String? _currentPayment;
  String? _currentFromDate;
  String? _currentToDate;
  String? _currentSort;
  String? _currentDirection;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<DashboardProvider>().fetchOrders(type: 'all');
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTypeTabChanged(String type) {
    setState(() {
      _selectedTypeTab = type;
    });
    _fetchOrdersWithFilters();
  }

  void _fetchOrdersWithFilters() {
    context.read<DashboardProvider>().fetchOrders(
          type: _selectedTypeTab,
          search: _currentSearch,
          source: _currentSource,
          store: _currentStore,
          status: _currentStatus,
          payment: _currentPayment,
          from: _currentFromDate,
          to: _currentToDate,
          sort: _currentSort,
          direction: _currentDirection,
        );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final List<OrderItemModel> rawOrders = dashboardProvider.orderResponse?.data ?? [];

    final filteredList = rawOrders.where((order) {
      final orderNumber = order.orderNumber?.toLowerCase() ?? '';
      final status = order.status?.toLowerCase() ?? '';
      return orderNumber.contains(_searchQuery.toLowerCase()) ||
          status.contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.86,
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

          // Sheet Top Header Bar: Title, Export Button & Close Button
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
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.read<DashboardProvider>().exportOrders();
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: primaryOrange.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryOrange.withValues(alpha: 0.3)),
                        ),
                        child: Icon(
                          Icons.file_download_outlined,
                          size: 20.sp,
                          color: primaryOrange,
                        ),
                      ),
                    ),
                    UIHelper.horizontalSpace(8.w),
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
              ],
            ),
          ),
          UIHelper.verticalSpace(14.h),

          // Order Tabs Chip Bar
          OrderTabChips(
            selectedTypeTab: _selectedTypeTab,
            onTabChanged: _onTypeTabChanged,
          ),
          UIHelper.verticalSpace(12.h),

          // Search Field Input & Advanced Filter Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
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
                                _currentSearch = val.isNotEmpty ? val : null;
                              });
                            },
                            onSubmitted: (_) {
                              _fetchOrdersWithFilters();
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
                                _currentSearch = null;
                              });
                              _fetchOrdersWithFilters();
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
                UIHelper.horizontalSpace(10.w),
                // Advanced Filter Button
                GestureDetector(
                  onTap: () {
                    OrderAdvancedFilterSheet.show(
                      context,
                      initialSearch: _currentSearch,
                      initialSource: _currentSource,
                      initialStore: _currentStore,
                      initialStatus: _currentStatus,
                      initialPayment: _currentPayment,
                      initialFromDate: _currentFromDate,
                      initialToDate: _currentToDate,
                      initialSort: _currentSort,
                      initialDirection: _currentDirection,
                      onApply: (filters) {
                        setState(() {
                          _currentSearch = filters['search'];
                          _currentSource = filters['source'];
                          _currentStore = filters['store'];
                          _currentStatus = filters['status'];
                          _currentPayment = filters['payment'];
                          _currentFromDate = filters['from'];
                          _currentToDate = filters['to'];
                          _currentSort = filters['sort'];
                          _currentDirection = filters['direction'];
                          if (_currentSearch != null) {
                            _searchController.text = _currentSearch!;
                            _searchQuery = _currentSearch!;
                          }
                        });
                        _fetchOrdersWithFilters();
                      },
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(13.w),
                    decoration: BoxDecoration(
                      color: primaryOrange,
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: primaryOrange.withValues(alpha: 0.3),
                          blurRadius: 6.r,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
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
                              'No orders found',
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
                              return OrderItemCard(
                                order: order,
                                isStoreTab: _selectedTypeTab == 'store',
                                onCancelTap: (orderId) {
                                  OrderCancellationDialog.show(context, orderId, (reason) {
                                    context.read<DashboardProvider>().cancelStoreOrder(orderId, reason: reason);
                                  });
                                },
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
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        itemCount: 4,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.only(bottom: 14.h),
          height: 110.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }
}
