import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/empty_state_widget.dart';
import '../../../common_widget/hero_search_field.dart';
import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/dashboard_provider.dart';
import '../model/order_model.dart';
import 'widgets/order/order_cancellation_dialog.dart';
import 'widgets/order/order_filters.dart';
import 'widgets/order/order_item_card.dart';
import 'widgets/order/order_tab_chips.dart';
import 'widgets/order/sheet_parts.dart';
import 'widgets/order_advanced_filter_sheet.dart';

/// Full-screen order list with search, filters, tabs, and order cards.
/// Fetching and filter logic live in [DashboardProvider].
class OrdersScreen extends StatefulWidget {
  final String orderTitle;

  const OrdersScreen({super.key, required this.orderTitle});

  static Future<void> open(BuildContext context, String orderTitle) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrdersScreen(orderTitle: orderTitle)),
    );
  }

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTypeTab = 'all'; // 'all', 'store', 'stores'
  OrderFilters _filters = const OrderFilters();

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
      search: _filters.search,
      source: _filters.source,
      store: _filters.store,
      status: _filters.status,
      payment: _filters.payment,
      from: _filters.from,
      to: _filters.to,
      sort: _filters.sort,
      direction: _filters.direction,
    );
  }

  void _onSearchChanged(String val) {
    setState(() {
      _searchQuery = val;
      _filters = _filters.withSearch(val.isNotEmpty ? val : null);
    });
  }

  void _openAdvancedFilters() {
    OrderAdvancedFilterSheet.show(
      context,
      initialSearch: _filters.search,
      initialSource: _filters.source,
      initialStore: _filters.store,
      initialStatus: _filters.status,
      initialPayment: _filters.payment,
      initialFromDate: _filters.from,
      initialToDate: _filters.to,
      initialSort: _filters.sort,
      initialDirection: _filters.direction,
      onApply: (filters) {
        setState(() {
          _filters = OrderFilters.fromMap(filters);
          if (_filters.search != null) {
            _searchController.text = _filters.search!;
            _searchQuery = _filters.search!;
          }
        });
        _fetchOrdersWithFilters();
      },
    );
  }

  void _confirmCancel(String orderId) {
    OrderCancellationDialog.show(context, orderId, (reason) {
      context.read<DashboardProvider>().cancelStoreOrder(
        orderId,
        reason: reason,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild only when the order list or its loading flag changes.
    final isLoading = context.select<DashboardProvider, bool>(
      (p) => p.isLoadingOrders,
    );
    final List<OrderItemModel> rawOrders =
        context.select<DashboardProvider, List<OrderItemModel>?>(
          (p) => p.orderResponse?.data,
        ) ??
        [];

    final query = _searchQuery.toLowerCase();
    final filteredList = rawOrders.where((order) {
      final orderNumber = order.orderNumber?.toLowerCase() ?? '';
      final status = order.status?.toLowerCase() ?? '';
      return orderNumber.contains(query) || status.contains(query);
    }).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            HeroPageHeader(
              title: widget.orderTitle,
              subtitle: 'Manage and track customer orders'.tr,
              trailing: HeroIconButton(
                icon: Icons.file_download_outlined,
                onTap: () => context.read<DashboardProvider>().exportOrders(),
              ),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    UIHelper.verticalSpace(14.h),
                    OrderTabChips(
                      selectedTypeTab: _selectedTypeTab,
                      onTabChanged: _onTypeTabChanged,
                    ),
                    UIHelper.verticalSpace(14.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: HeroSearchField(
                              controller: _searchController,
                              hintText: 'Search orders...'.tr,
                              onChanged: _onSearchChanged,
                              onSubmitted: (_) => _fetchOrdersWithFilters(),
                              onCleared: _fetchOrdersWithFilters,
                            ),
                          ),
                          UIHelper.horizontalSpace(10.w),
                          HeroSquareButton(
                            icon: Icons.tune_rounded,
                            isActive: _filters.hasAdvanced,
                            onTap: _openAdvancedFilters,
                          ),
                        ],
                      ),
                    ),
                    UIHelper.verticalSpace(8.h),
                    if (!isLoading && filteredList.isNotEmpty)
                      _OrderCountBar(count: filteredList.length),
                    Expanded(
                      child: isLoading
                          ? const _OrderListShimmer()
                          : rawOrders.isEmpty
                          ? EmptyStateWidget(
                              icon: Icons.assignment_outlined,
                              message: 'No orders found'.tr,
                            )
                          : filteredList.isEmpty
                          ? EmptyStateWidget(
                              icon: Icons.search_off_rounded,
                              message: 'No matching orders found'.tr,
                            )
                          : ListView.builder(
                              padding: EdgeInsets.fromLTRB(
                                20.w,
                                4.h,
                                20.w,
                                20.h,
                              ),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) => OrderItemCard(
                                order: filteredList[index],
                                isStoreTab: _selectedTypeTab == 'store',
                                onCancelTap: _confirmCancel,
                              ),
                            ),
                    ),
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

/// "12 orders" with the dashboard's orange accent bar.
class _OrderCountBar extends StatelessWidget {
  final int count;

  const _OrderCountBar({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 15.h,
            decoration: BoxDecoration(
              color: primaryOrange,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          UIHelper.horizontalSpace(8.w),
          Text(
            '@count orders'.trParams({'count': '$count'}),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderListShimmer extends StatelessWidget {
  const _OrderListShimmer();

  @override
  Widget build(BuildContext context) {
    return SheetShimmer(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        itemCount: 4,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.only(bottom: 14.h),
          height: 120.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }
}
