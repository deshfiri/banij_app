import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/dashboard_provider.dart';
import '../../model/order_model.dart';
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

  void _showCancellationDialog(BuildContext context, String orderId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColorsTheme.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24.sp),
            UIHelper.horizontalSpace(8.w),
            Text(
              'Cancel Order',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel order #$orderId?',
              style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context)),
            ),
            UIHelper.verticalSpace(14.h),
            TextField(
              controller: reasonController,
              style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMainColor(context)),
              decoration: InputDecoration(
                hintText: 'Cancellation reason (optional)...',
                hintStyle: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context)),
                filled: true,
                fillColor: AppColorsTheme.background(context),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColorsTheme.borderColor(context))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep Order', style: TextStyle(color: AppColorsTheme.textMutedColor(context))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DashboardProvider>().cancelStoreOrder(orderId, reason: reasonController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: const Text('Confirm Cancellation'),
          ),
        ],
      ),
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

          // Endpoint Order Tabs Bar: All Orders, Store Orders, Connected Stores
          SizedBox(
            height: 38.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              children: [
                _buildOrderTabChip('all', 'All Orders'),
                _buildOrderTabChip('store', 'Store Orders'),
                _buildOrderTabChip('stores', 'Connected Stores'),
              ],
            ),
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
                              return _buildOrderItemCard(context, order);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTabChip(String value, String label) {
    final isSelected = _selectedTypeTab == value;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: () => _onTypeTabChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected ? primaryOrange : AppColorsTheme.cardBg(context),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isSelected ? primaryOrange : AppColorsTheme.borderColor(context),
              width: 1.w,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: primaryOrange.withValues(alpha: 0.3),
                  blurRadius: 6.r,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColorsTheme.textMainColor(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItemCard(BuildContext context, OrderItemModel order) {
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
              if (_selectedTypeTab == 'store' && !status.toLowerCase().contains('cancel')) ...[
                OutlinedButton(
                  onPressed: () {
                    final targetId = order.id?.toString() ?? order.orderNumber ?? '';
                    if (targetId.isNotEmpty) {
                      _showCancellationDialog(context, targetId);
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
