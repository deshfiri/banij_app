import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../common_widget/hub_card_tile_widget.dart';
import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../networks/api_access.dart';
import '../../../../providers/dashboard_provider.dart';
import '../../../finance/presentation/widgets/invoices_receipts_sheet.dart';
import '../../model/current_user_model.dart';
import 'order_category_detail_sheet.dart';
import 'product_category_detail_sheet.dart';
import 'website_sheet.dart';

class HubItem {
  final String titleKey;
  final String category;
  final String tagKey;
  final IconData iconData;
  final Color categoryColor;

  const HubItem({
    required this.titleKey,
    required this.category,
    required this.tagKey,
    required this.iconData,
    required this.categoryColor,
  });
}

class DashboardHubWidget extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const DashboardHubWidget({
    super.key,
    this.onOpenDrawer,
  });

  @override
  State<DashboardHubWidget> createState() => _DashboardHubWidgetState();
}

class _DashboardHubWidgetState extends State<DashboardHubWidget> {
  String _selectedFilter = 'All';
  CurrentUserModel? _currentUserModel;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final res = await currentUserRxObj.fetchCurrentUser();
      if (mounted) {
        setState(() {
          _currentUserModel = res;
          _isLoadingUser = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  final List<String> _filters = ['All', 'Products', 'Sales & Orders', 'Finance'];

  final List<HubItem> _allHubItems = const [
    HubItem(
      titleKey: 'hub_products',
      category: 'catalog',
      tagKey: 'catalog',
      iconData: Icons.shopping_bag_outlined,
      categoryColor: primaryOrange,
    ),
    HubItem(
      titleKey: 'hub_my_products',
      category: 'Products',
      tagKey: 'tag_products',
      iconData: Icons.grid_view_rounded,
      categoryColor: primaryOrange,
    ),
    HubItem(
      titleKey: 'hub_my_damages',
      category: 'Products',
      tagKey: 'tag_products',
      iconData: Icons.warning_amber_rounded,
      categoryColor: primaryOrange,
    ),
    HubItem(
      titleKey: 'hub_all_orders',
      category: 'Sales & Orders',
      tagKey: 'tag_sales_orders',
      iconData: Icons.format_list_bulleted_rounded,
      categoryColor: Color(0xFF0284C7),
    ),
    HubItem(
      titleKey: 'hub_customers',
      category: 'Sales & Orders',
      tagKey: 'tag_sales_orders',
      iconData: Icons.people_outline_rounded,
      categoryColor: Color(0xFF0284C7),
    ),
    HubItem(
      titleKey: 'hub_orders',
      category: 'Sales & Orders',
      tagKey: 'tag_sales_orders',
      iconData: Icons.description_outlined,
      categoryColor: Color(0xFF0284C7),
    ),
    HubItem(
      titleKey: 'hub_my_websites',
      category: 'Sales & Orders',
      tagKey: 'tag_sales_orders',
      iconData: Icons.language_outlined,
      categoryColor: Color(0xFF0284C7),
    ),
    HubItem(
      titleKey: 'hub_store_orders',
      category: 'Sales & Orders',
      tagKey: 'tag_sales_orders',
      iconData: Icons.storefront_outlined,
      categoryColor: Color(0xFF0284C7),
    ),
    HubItem(
      titleKey: 'hub_invoices',
      category: 'Finance',
      tagKey: 'tag_finance',
      iconData: Icons.receipt_long_outlined,
      categoryColor: Color(0xFF8B5CF6),
    ),
    HubItem(
      titleKey: 'hub_receipts',
      category: 'Finance',
      tagKey: 'tag_finance',
      iconData: Icons.payments_outlined,
      categoryColor: Color(0xFF10B981),
    ),
    HubItem(
      titleKey: 'hub_reports',
      category: 'Finance',
      tagKey: 'tag_finance',
      iconData: Icons.bar_chart_rounded,
      categoryColor: Color(0xFF8B5CF6),
    ),
    HubItem(
      titleKey: 'hub_transactions',
      category: 'Finance',
      tagKey: 'tag_finance',
      iconData: Icons.swap_horiz_rounded,
      categoryColor: Color(0xFF10B981),
    ),
  ];

  void _handleCardTap(BuildContext context, HubItem item) {
    if (item.category == 'Finance' ||
        item.titleKey == 'hub_invoices' ||
        item.titleKey == 'hub_receipts' ||
        item.titleKey == 'hub_transactions' ||
        item.titleKey == 'hub_reports') {
      final initialTab = (item.titleKey == 'hub_receipts' || item.titleKey == 'hub_transactions')
          ? 'Receipts'
          : 'Invoices';
      InvoicesReceiptsSheet.show(context, initialTab: initialTab);
    } else if (item.titleKey == 'hub_my_websites') {
      WebsiteSheet.show(context);
    } else if (item.category == 'Sales & Orders' ||
        item.titleKey == 'hub_orders' ||
        item.titleKey == 'hub_all_orders' ||
        item.titleKey == 'hub_store_orders' ||
        item.titleKey == 'hub_customers') {
      OrderCategoryDetailSheet.show(context, item.titleKey.tr);
    } else {
      final isCatalog = item.category == 'catalog' || item.titleKey == 'hub_products';
      ProductCategoryDetailSheet.show(context, item.titleKey.tr, isCatalog: isCatalog);
    }
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'Products':
        return Icons.shopping_bag_outlined;
      case 'Sales & Orders':
        return Icons.format_list_bulleted_rounded;
      case 'Finance':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.grid_view_rounded;
    }
  }

  Widget _buildWorkspaceHeaderCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColorsTheme.cardBg(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark
                ? AppColorsTheme.borderColor(context)
                : primaryOrange.withValues(alpha: 0.2),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 10.r,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: primaryOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: primaryOrange.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: primaryOrange,
                    size: 19.sp,
                  ),
                ),
                UIHelper.horizontalSpace(10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUserModel?.data?.businessAccount?.name ??
                          _currentUserModel?.data?.name ??
                          'considine_group'.tr,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(1.h),
                    Text(
                      'Business Workspace',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColorsTheme.textMutedColor(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: primaryOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: primaryOrange.withValues(alpha: 0.3),
                  width: 1.w,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    color: primaryOrange,
                    size: 12.sp,
                  ),
                  UIHelper.horizontalSpace(4.w),
                  Text(
                    'owner'.tr.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w800,
                      color: primaryOrange,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: AppColorsTheme.cardBg(context),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.3 : 0.16),
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.025),
                blurRadius: 8.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(7.5.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: color.withValues(alpha: 0.22),
                  ),
                ),
                child: Icon(icon, color: color, size: 17.sp),
              ),
              UIHelper.horizontalSpace(8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(1.h),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColorsTheme.textMutedColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardProvider = context.watch<DashboardProvider>();

    final filteredItems = _selectedFilter == 'All'
        ? _allHubItems
        : _allHubItems.where((item) => item.category == _selectedFilter).toList();

    return CustomScrollView(
      slivers: [
        // 1. Pinned & Floating SliverAppBar with Centered Logo, Menu Drawer Button & Notification Badge
        SliverAppBar(
          pinned: true,
          floating: true,
          snap: true,
          elevation: 1,
          backgroundColor: AppColorsTheme.cardBg(context),
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          toolbarHeight: 52.h,
          title: Stack(
            alignment: Alignment.center,
            children: [
              // 100% Dead-Centered Logo
              Center(
                child: Image.asset(
                  isDark ? whiteLogo : logo,
                  width: 105.w,
                  height: 34.h,
                  fit: BoxFit.contain,
                ),
              ),
              // Left Drawer Menu Icon
              Positioned(
                left: 0,
                child: IconButton(
                  onPressed: widget.onOpenDrawer,
                  icon: Icon(
                    Icons.menu_rounded,
                    color: AppColorsTheme.textMainColor(context),
                    size: 23.sp,
                  ),
                ),
              ),
              // Right Action Icons: Notifications & Profile
              Positioned(
                right: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.notificationScreen);
                      },
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            color: AppColorsTheme.textMainColor(context),
                            size: 21.sp,
                          ),
                          Positioned(
                            top: -2.h,
                            right: -2.w,
                            child: Container(
                              width: 7.w,
                              height: 7.h,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        dashboardProvider.setBottomNavIndex(4);
                      },
                      icon: Icon(
                        Icons.person_outline_rounded,
                        color: AppColorsTheme.textMainColor(context),
                        size: 21.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2. Considine Group Workspace & Metric Cards Section
        SliverToBoxAdapter(
          child: Column(
            children: [
              // Considine Group Owner Header Card Banner
              _buildWorkspaceHeaderCard(context),
              UIHelper.verticalSpace(2.h),

              // Metrics Summary Grid Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: 'Products',
                            value: '12 Active',
                            icon: Icons.shopping_bag_outlined,
                            color: primaryOrange,
                            onTap: () => ProductCategoryDetailSheet.show(context, 'hub_products'.tr, isCatalog: true),
                          ),
                        ),
                        UIHelper.horizontalSpace(10.w),
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: 'Active Orders',
                            value: '4 Pending',
                            icon: Icons.format_list_bulleted_rounded,
                            color: const Color(0xFF0284C7),
                            onTap: () => OrderCategoryDetailSheet.show(context, 'hub_orders'.tr),
                          ),
                        ),
                      ],
                    ),
                    UIHelper.verticalSpace(8.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: 'Revenue',
                            value: '৳ 45,800',
                            icon: Icons.account_balance_wallet_outlined,
                            color: const Color(0xFF10B981),
                            onTap: () => InvoicesReceiptsSheet.show(context, initialTab: 'Receipts'),
                          ),
                        ),
                        UIHelper.horizontalSpace(10.w),
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: 'Invoices',
                            value: '8 Issued',
                            icon: Icons.receipt_long_outlined,
                            color: const Color(0xFF8B5CF6),
                            onTap: () => InvoicesReceiptsSheet.show(context, initialTab: 'Invoices'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              UIHelper.verticalSpace(12.h),
            ],
          ),
        ),

        // 3. Sticky Fixed Filter Chips Header (Pinned on Scrolling)
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyFilterDelegate(
            child: Container(
              color: AppColorsTheme.background(context),
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;

                  String filterLabel = filter;
                  if (filter == 'All') filterLabel = 'filter_all'.tr;
                  if (filter == 'Products') filterLabel = 'filter_products'.tr;
                  if (filter == 'Sales & Orders') filterLabel = 'filter_sales_orders'.tr;
                  if (filter == 'Finance') filterLabel = 'filter_finance'.tr;

                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 6.h),
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
                              )
                            else
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.02),
                                blurRadius: 4.r,
                              ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getFilterIcon(filter),
                              size: 13.sp,
                              color: isSelected ? Colors.white : AppColorsTheme.textMutedColor(context),
                            ),
                            UIHelper.horizontalSpace(5.w),
                            Text(
                              filterLabel,
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? Colors.white : AppColorsTheme.textMainColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // 4. Ultra-Sleek Compact 2-Column Cards Grid with Category Colors
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 100.h),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1.3,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = filteredItems[index];
                return HubCardTileWidget(
                  title: item.titleKey.tr,
                  subtitle: item.tagKey.tr,
                  iconData: item.iconData,
                  categoryColor: item.categoryColor,
                  onTap: () => _handleCardTap(context, item),
                );
              },
              childCount: filteredItems.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyFilterDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 44.h;

  @override
  double get minExtent => 44.h;

  @override
  bool shouldRebuild(covariant _StickyFilterDelegate oldDelegate) {
    return true;
  }
}
