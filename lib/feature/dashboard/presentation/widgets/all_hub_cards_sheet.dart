import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widget/hub_card_tile_widget.dart';
import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../finance/presentation/widgets/invoices_receipts_sheet.dart';
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

class AllHubCardsSheet extends StatefulWidget {
  const AllHubCardsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AllHubCardsSheet(),
    );
  }

  @override
  State<AllHubCardsSheet> createState() => _AllHubCardsSheetState();
}

class _AllHubCardsSheetState extends State<AllHubCardsSheet> {
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Products', 'Sales & Orders', 'Finance'];

  final List<HubItem> _allHubItems = const [
    HubItem(
      titleKey: 'hub_products',
      category: 'catalog',
      tagKey: 'catalog',
      iconData: Icons.shopping_bag_rounded,
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
  ];

  void _handleCardTap(BuildContext context, HubItem item) {
    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredItems = _selectedFilter == 'All'
        ? _allHubItems
        : _allHubItems.where((item) => item.category == _selectedFilter).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColorsTheme.background(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle & Header Title Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColorsTheme.cardBg(context),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColorsTheme.borderColor(context),
                  width: 1.w,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                UIHelper.verticalSpace(12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Modules & Features',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColorsTheme.textMainColor(context),
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Category Chips
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: SizedBox(
              height: 38.h,
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
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryOrange : AppColorsTheme.cardBg(context),
                          borderRadius: BorderRadius.circular(20.r),
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
                              size: 14.sp,
                              color: isSelected ? Colors.white : AppColorsTheme.textMutedColor(context),
                            ),
                            UIHelper.horizontalSpace(6.w),
                            Text(
                              filterLabel,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
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

          // 2-Column Grid of Hub Cards Matching Reference Screenshot
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.25,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return HubCardTileWidget(
                  title: item.titleKey.tr,
                  subtitle: item.tagKey.tr,
                  iconData: item.iconData,
                  categoryColor: item.categoryColor,
                  onTap: () => _handleCardTap(context, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
