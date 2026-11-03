import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/ui_helpers.dart';

class FinanceHubItem {
  final String titleKey;
  final String category;
  final String tagKey;
  final IconData iconData;
  final String? targetTab;

  const FinanceHubItem({
    required this.titleKey,
    required this.category,
    required this.tagKey,
    required this.iconData,
    this.targetTab,
  });
}

class FinanceHubWidget extends StatefulWidget {
  const FinanceHubWidget({super.key});

  @override
  State<FinanceHubWidget> createState() => _FinanceHubWidgetState();
}

class _FinanceHubWidgetState extends State<FinanceHubWidget> {
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Invoices', 'Payments', 'Reports'];

  final List<FinanceHubItem> _allFinanceItems = const [
    FinanceHubItem(
      titleKey: 'hub_invoices',
      category: 'Invoices',
      tagKey: 'tag_billing',
      iconData: Icons.receipt_long_outlined,
      targetTab: 'Invoices',
    ),
    FinanceHubItem(
      titleKey: 'hub_receipts',
      category: 'Payments',
      tagKey: 'tag_billing',
      iconData: Icons.payments_outlined,
      targetTab: 'Receipts',
    ),
    FinanceHubItem(
      titleKey: 'hub_transactions',
      category: 'Payments',
      tagKey: 'tag_finance',
      iconData: Icons.swap_horiz_rounded,
      targetTab: 'Receipts',
    ),
    FinanceHubItem(
      titleKey: 'hub_wallet',
      category: 'Payments',
      tagKey: 'tag_finance',
      iconData: Icons.account_balance_wallet_outlined,
      targetTab: 'Package',
    ),
    FinanceHubItem(
      titleKey: 'hub_expenses',
      category: 'Reports',
      tagKey: 'tag_finance',
      iconData: Icons.trending_down_rounded,
      targetTab: 'Invoices',
    ),
    FinanceHubItem(
      titleKey: 'hub_reports',
      category: 'Reports',
      tagKey: 'tag_finance',
      iconData: Icons.bar_chart_rounded,
      targetTab: 'Package',
    ),
  ];

  void _handleItemTap(BuildContext context, FinanceHubItem item) {
    if (item.targetTab != null) {
      Navigator.pushNamed(
        context,
        Routes.accountScreen,
        arguments: item.targetTab,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening ${item.titleKey.tr}...'),
          backgroundColor: primaryOrange,
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredItems = _selectedFilter == 'All'
        ? _allFinanceItems
        : _allFinanceItems.where((item) => item.category == _selectedFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Top Header: Banij Logo & Financial Management Title
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
                        Icons.account_balance_wallet,
                        color: primaryOrange,
                        size: 16.sp,
                      ),
                    ),
                    UIHelper.horizontalSpace(8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'finance'.tr,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColorsTheme.textMainColor(context),
                          ),
                        ),
                        Text(
                          'financial_management'.tr,
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
              if (filter == 'Invoices') filterLabel = 'hub_invoices'.tr;
              if (filter == 'Payments') filterLabel = 'filter_payments'.tr;
              if (filter == 'Reports') filterLabel = 'filter_reports'.tr;

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

        // 3. 2-Column Grid of Cards
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
              return GestureDetector(
                onTap: () => _handleItemTap(context, item),
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColorsTheme.cardBg(context),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColorsTheme.borderColor(context),
                      width: 1.w,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top row: Icon Box & Chevron Right
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFECE0),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              item.iconData,
                              color: primaryOrange,
                              size: 22.sp,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppColorsTheme.textMutedColor(context),
                            size: 20.sp,
                          ),
                        ],
                      ),
                      // Bottom texts: Title & Tag
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.titleKey.tr,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          UIHelper.verticalSpace(2.h),
                          Text(
                            item.tagKey.tr,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColorsTheme.textMutedColor(context),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
