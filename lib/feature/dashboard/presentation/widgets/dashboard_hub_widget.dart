import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widget/hub_card_tile_widget.dart';
import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredItems = _selectedFilter == 'All'
        ? _allHubItems
        : _allHubItems.where((item) => item.category == _selectedFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Top Header: Banij Logo & Considine Group Owner Badge
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                isDark ? whiteLogo : logo,
                width: 120.w,
                height: 45.h,
                fit: BoxFit.contain,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColorsTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColorsTheme.borderColor(context)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECE0),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.business_center_rounded,
                        color: primaryOrange,
                        size: 16.sp,
                      ),
                    ),
                    UIHelper.horizontalSpace(8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'considine_group'.tr,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColorsTheme.textMainColor(context),
                          ),
                        ),
                        Text(
                          'owner'.tr,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColorsTheme.textMutedColor(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        UIHelper.verticalSpace(8.h),

        // 2. Filter Chips Row
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
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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

        // 3. 2-Column Grid of Cards using HubCardTileWidget
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
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
      ],
    );
  }
}
