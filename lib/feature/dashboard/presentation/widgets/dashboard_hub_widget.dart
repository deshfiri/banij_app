import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widget/hub_card_tile_widget.dart';
import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';

class HubItem {
  final String titleKey;
  final String category;
  final String tagKey;
  final IconData iconData;

  const HubItem({
    required this.titleKey,
    required this.category,
    required this.tagKey,
    required this.iconData,
  });
}

class DashboardHubWidget extends StatefulWidget {
  const DashboardHubWidget({super.key});

  @override
  State<DashboardHubWidget> createState() => _DashboardHubWidgetState();
}

class _DashboardHubWidgetState extends State<DashboardHubWidget> {
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Products', 'Sales & Orders', 'Finance'];

  final List<HubItem> _allHubItems = const [
    HubItem(titleKey: 'hub_products', category: 'Products', tagKey: 'tag_products', iconData: Icons.shopping_bag_outlined),
    HubItem(titleKey: 'hub_my_products', category: 'Products', tagKey: 'tag_products', iconData: Icons.grid_view_rounded),
    HubItem(titleKey: 'hub_my_damages', category: 'Products', tagKey: 'tag_products', iconData: Icons.warning_amber_rounded),
    HubItem(titleKey: 'hub_all_orders', category: 'Sales & Orders', tagKey: 'tag_sales_orders', iconData: Icons.format_list_bulleted_rounded),
    HubItem(titleKey: 'hub_customers', category: 'Sales & Orders', tagKey: 'tag_sales_orders', iconData: Icons.people_outline_rounded),
    HubItem(titleKey: 'hub_orders', category: 'Sales & Orders', tagKey: 'tag_sales_orders', iconData: Icons.description_outlined),
    HubItem(titleKey: 'hub_my_websites', category: 'Sales & Orders', tagKey: 'tag_sales_orders', iconData: Icons.language_outlined),
    HubItem(titleKey: 'hub_store_orders', category: 'Sales & Orders', tagKey: 'tag_sales_orders', iconData: Icons.storefront_outlined),
    HubItem(titleKey: 'hub_invoices', category: 'Finance', tagKey: 'tag_finance', iconData: Icons.receipt_long_outlined),
    HubItem(titleKey: 'hub_receipts', category: 'Finance', tagKey: 'tag_finance', iconData: Icons.payments_outlined),
    HubItem(titleKey: 'hub_reports', category: 'Finance', tagKey: 'tag_finance', iconData: Icons.bar_chart_rounded),
    HubItem(titleKey: 'hub_transactions', category: 'Finance', tagKey: 'tag_finance', iconData: Icons.swap_horiz_rounded),
  ];

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColorsTheme.borderColor(context),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          UIHelper.horizontalSpace(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                UIHelper.verticalSpace(2.h),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColorsTheme.textMutedColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredItems = _selectedFilter == 'All'
        ? _allHubItems
        : _allHubItems.where((item) => item.category == _selectedFilter).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Considine Group Owner Header Card Banner
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColorsTheme.cardBg(context),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: AppColorsTheme.borderColor(context)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                    blurRadius: 10.r,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'considine_group'.tr,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                      UIHelper.verticalSpace(2.h),
                      Text(
                        'Business Workspace',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColorsTheme.textMutedColor(context),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: primaryOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: primaryOrange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: primaryOrange,
                          size: 14.sp,
                        ),
                        UIHelper.horizontalSpace(6.w),
                        Text(
                          'owner'.tr.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          UIHelper.verticalSpace(4.h),

          // 2. Metrics Summary Grid Section (Matching Supplier Dashboard)
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
                      ),
                    ),
                    UIHelper.horizontalSpace(12.w),
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        title: 'Active Orders',
                        value: '4 Pending',
                        icon: Icons.format_list_bulleted_rounded,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
                UIHelper.verticalSpace(10.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        title: 'Revenue',
                        value: '৳ 45,800',
                        icon: Icons.account_balance_wallet_outlined,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    UIHelper.horizontalSpace(12.w),
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        title: 'Invoices',
                        value: '8 Issued',
                        icon: Icons.receipt_long_outlined,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(16.h),

          // 3. Filter Chips Row
          SizedBox(
            height: 42.h,
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
                  padding: EdgeInsets.only(right: 10.w),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryOrange : AppColorsTheme.cardBg(context),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected ? primaryOrange : AppColorsTheme.borderColor(context),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        filterLabel,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : AppColorsTheme.textMainColor(context),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          UIHelper.verticalSpace(16.h),

          // 4. 2-Column Grid of Cards using HubCardTileWidget
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14.w,
                mainAxisSpacing: 14.h,
                childAspectRatio: 1.15,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return HubCardTileWidget(
                  title: item.titleKey.tr,
                  subtitle: item.tagKey.tr,
                  iconData: item.iconData,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening ${item.titleKey.tr}...'),
                        backgroundColor: primaryOrange,
                        duration: const Duration(milliseconds: 800),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          UIHelper.verticalSpace(24.h),
        ],
      ),
    );
  }
}
