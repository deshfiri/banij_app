import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/dashboard_provider.dart';

class ProductCategoryDetailSheet extends StatefulWidget {
  final String categoryTitle;

  const ProductCategoryDetailSheet({
    super.key,
    required this.categoryTitle,
  });

  static void show(BuildContext context, String categoryTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductCategoryDetailSheet(categoryTitle: categoryTitle),
    );
  }

  @override
  State<ProductCategoryDetailSheet> createState() => _ProductCategoryDetailSheetState();
}

class _ProductCategoryDetailSheetState extends State<ProductCategoryDetailSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardProvider = context.watch<DashboardProvider>();
    final apiProducts = dashboardProvider.myProductResponse?.data ?? [];

    final filteredList = apiProducts.where((product) {
      final name = product.name ?? '';
      final category = product.category ?? '';
      return name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          category.toLowerCase().contains(_searchQuery.toLowerCase());
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
                      widget.categoryTitle,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(2.h),
                    Text(
                      'Browse items & manage inventory',
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
                        hintText: 'Search in ${widget.categoryTitle}...',
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

          // Scrollable Product List Cards
          Expanded(
            child: dashboardProvider.isLoadingProducts
                ? Center(
                    child: CircularProgressIndicator(color: primaryOrange),
                  )
                : apiProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 48.sp, color: AppColorsTheme.textMutedColor(context)),
                            UIHelper.verticalSpace(12.h),
                            Text(
                              'No products found',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColorsTheme.textMutedColor(context),
                              ),
                            ),
                            UIHelper.verticalSpace(6.h),
                            Text(
                              'Please finish setting up your account or add products.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColorsTheme.textMutedColor(context),
                              ),
                            ),
                          ],
                        ),
                      )
                    : filteredList.isEmpty
                        ? Center(
                            child: Text(
                              'No matching products found',
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
                          final product = filteredList[index];
                          final imageUrl = product.image?.url ?? '';
                          final title = product.name ?? 'Product';
                          final category = product.category ?? 'General';
                          final price = product.wholesale?.price?.formatted ?? '৳ 0';
                          final stock = product.wholesale?.inStock != null
                              ? '${product.wholesale!.inStock} Units in Stock'
                              : 'In Stock';

                          return Container(
                            margin: EdgeInsets.only(bottom: 16.h),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row: Product Image Thumbnail, Title & Status Tag
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14.r),
                                      child: Container(
                                        width: 64.w,
                                        height: 64.h,
                                        decoration: BoxDecoration(
                                          color: primaryOrange.withValues(alpha: isDark ? 0.15 : 0.12),
                                          borderRadius: BorderRadius.circular(14.r),
                                          border: Border.all(
                                            color: primaryOrange.withValues(alpha: 0.3),
                                            width: 1.w,
                                          ),
                                        ),
                                        child: imageUrl.isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Center(
                                                    child: Icon(
                                                      Icons.inventory_2_outlined,
                                                      color: primaryOrange,
                                                      size: 26.sp,
                                                    ),
                                                  );
                                                },
                                              )
                                            : Center(
                                                child: Icon(
                                                  Icons.inventory_2_outlined,
                                                  color: primaryOrange,
                                                  size: 26.sp,
                                                ),
                                              ),
                                      ),
                                    ),
                                    UIHelper.horizontalSpace(12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: TextStyle(
                                              fontSize: 14.5.sp,
                                              fontWeight: FontWeight.w800,
                                              color: AppColorsTheme.textMainColor(context),
                                              height: 1.25,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          UIHelper.verticalSpace(4.h),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(8.r),
                                            ),
                                            child: Text(
                                              category.toUpperCase(),
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
                                    ),
                                  ],
                                ),
                                UIHelper.verticalSpace(12.h),
                                Divider(color: AppColorsTheme.borderColor(context)),
                                UIHelper.verticalSpace(10.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          price,
                                          style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.w900,
                                            color: primaryOrange,
                                          ),
                                        ),
                                        UIHelper.verticalSpace(2.h),
                                        Text(
                                          stock,
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColorsTheme.textMutedColor(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Selected $title'),
                                            backgroundColor: primaryOrange,
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.arrow_forward_rounded, size: 14.sp),
                                      label: Text(
                                        'Manage'.tr,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryOrange,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                        elevation: 0,
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
}
