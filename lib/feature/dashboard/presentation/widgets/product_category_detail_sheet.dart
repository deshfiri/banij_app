import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/toast.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/dashboard_provider.dart';

class ProductCategoryDetailSheet extends StatefulWidget {
  final String categoryTitle;
  final bool isCatalog;

  const ProductCategoryDetailSheet({
    super.key,
    required this.categoryTitle,
    this.isCatalog = false,
  });

  static void show(BuildContext context, String categoryTitle, {bool isCatalog = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductCategoryDetailSheet(
        categoryTitle: categoryTitle,
        isCatalog: isCatalog,
      ),
    );
  }

  @override
  State<ProductCategoryDetailSheet> createState() => _ProductCategoryDetailSheetState();
}

class _ProductCategoryDetailSheetState extends State<ProductCategoryDetailSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (widget.isCatalog) {
          context.read<DashboardProvider>().fetchCatalogProducts();
        } else {
          context.read<DashboardProvider>().fetchMyProducts();
        }
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
    final rawApiProducts = widget.isCatalog
        ? (dashboardProvider.catalogProductResponse?.data ?? [])
        : (dashboardProvider.myProductResponse?.data ?? []);
    final apiCategories = widget.isCatalog
        ? (dashboardProvider.catalogProductResponse?.options?.categories ?? [])
        : (dashboardProvider.myProductResponse?.options?.categories ?? []);
    final displayProducts = rawApiProducts;

    final filteredList = displayProducts.where((product) {
      final name = product.name ?? '';
      final category = product.category ?? '';
      final matchesSearch = name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' ||
          name.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
          category.toLowerCase().contains(_selectedCategory.toLowerCase());

      return matchesSearch && matchesCategory;
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
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, Routes.cartScreen);
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppColorsTheme.cardBg(context),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColorsTheme.borderColor(context)),
                            ),
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              size: 20.sp,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Consumer<CartProvider>(
                            builder: (context, cart, child) {
                              if (cart.totalItemsCount == 0) return const SizedBox.shrink();
                              return Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: primaryOrange,
                                  shape: BoxShape.circle,
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 15.w,
                                  minHeight: 15.h,
                                ),
                                child: Text(
                                  '${cart.totalItemsCount}',
                                  style: TextStyle(
                                    fontSize: 8.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    UIHelper.horizontalSpace(10.w),
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
          UIHelper.verticalSpace(12.h),

          // Horizontal Category Choice Chips
          if (apiCategories.isNotEmpty) ...[
            SizedBox(
              height: 34.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: apiCategories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isSelected = _selectedCategory == 'All';
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: ChoiceChip(
                        label: Text('All Categories'),
                        selected: isSelected,
                        selectedColor: primaryOrange,
                        backgroundColor: AppColorsTheme.cardBg(context),
                        labelStyle: TextStyle(
                          fontSize: 11.sp,
                          color: isSelected ? Colors.white : AppColorsTheme.textMainColor(context),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected ? primaryOrange : AppColorsTheme.borderColor(context),
                        ),
                        onSelected: (val) {
                          setState(() {
                            _selectedCategory = 'All';
                          });
                        },
                      ),
                    );
                  }
                  final cat = apiCategories[index - 1];
                  final label = cat.label ?? '';
                  final displayLabel = label.contains('›') ? label.split('›').last.trim() : label;
                  final isSelected = _selectedCategory == label;

                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: ChoiceChip(
                      label: Text(displayLabel),
                      selected: isSelected,
                      selectedColor: primaryOrange,
                      backgroundColor: AppColorsTheme.cardBg(context),
                      labelStyle: TextStyle(
                        fontSize: 11.sp,
                        color: isSelected ? Colors.white : AppColorsTheme.textMainColor(context),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected ? primaryOrange : AppColorsTheme.borderColor(context),
                      ),
                      onSelected: (val) {
                        setState(() {
                          _selectedCategory = isSelected ? 'All' : label;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            UIHelper.verticalSpace(10.h),
          ],

          // Scrollable Product List Cards
          Expanded(
            child: dashboardProvider.isLoadingProducts
                ? _buildProductShimmer(context)
                : rawApiProducts.isEmpty
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
                          final title = product.name ?? '';
                          final category = product.category ?? '';
                          final price = product.wholesale?.price?.formatted ?? '';
                          final stock = product.wholesale?.inStock != null
                              ? '${product.wholesale!.inStock} Units in Stock'
                              : '';

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
                                        child: Image.network(
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
                                          Text(
                                            product.shortDescription ?? 'Catalog',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AppColorsTheme.textMutedColor(context),
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
                                    Row(
                                      children: [
                                        OutlinedButton(
                                          onPressed: () {
                                            context.read<CartProvider>().addToCart(product, quantity: 1);
                                            ToastUtil.showSuccessMessage('Added to cart');
                                          },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColorsTheme.textMainColor(context),
                                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                                            side: BorderSide(color: AppColorsTheme.borderColor(context)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.r),
                                            ),
                                          ),
                                          child: Text(
                                            'Add to Cart',
                                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        UIHelper.horizontalSpace(8.w),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              Routes.productDetailScreen,
                                              arguments: product,
                                            );
                                          },
                                          icon: Icon(Icons.arrow_forward_rounded, size: 14.sp),
                                          label: Text(
                                            'Details'.tr,
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

  Widget _buildProductShimmer(BuildContext context) {
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
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColorsTheme.cardBg(context),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: AppColorsTheme.borderColor(context),
                width: 1.w,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    UIHelper.horizontalSpace(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 14.h,
                            color: Colors.white,
                          ),
                          UIHelper.verticalSpace(6.h),
                          Container(
                            width: 140.w,
                            height: 12.h,
                            color: Colors.white,
                          ),
                          UIHelper.verticalSpace(8.h),
                          Container(
                            width: 70.w,
                            height: 16.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                UIHelper.verticalSpace(12.h),
                Container(
                  width: double.infinity,
                  height: 1.h,
                  color: Colors.white,
                ),
                UIHelper.verticalSpace(10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 90.w,
                      height: 20.h,
                      color: Colors.white,
                    ),
                    Container(
                      width: 80.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
