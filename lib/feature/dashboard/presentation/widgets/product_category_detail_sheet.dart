import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';

class SampleProductModel {
  final String id;
  final String title;
  final String description;
  final String price;
  final String stock;
  final String tag;
  final IconData icon;
  final String imageUrl;

  const SampleProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.stock,
    required this.tag,
    required this.icon,
    required this.imageUrl,
  });
}

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

  static const List<SampleProductModel> _sampleProducts = [
    SampleProductModel(
      id: 'P01',
      title: 'Banij Premium Wholesale Cotton Pack',
      description: 'High-grade 100% organic cotton wholesale bundle optimized for retail distribution & supply.',
      price: '৳ 2,450',
      stock: '120 Units in Stock',
      tag: 'IN STOCK',
      icon: Icons.inventory_2_outlined,
      imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500',
    ),
    SampleProductModel(
      id: 'P02',
      title: 'Banij Enterprise Smart Logistics Hub',
      description: 'Advanced automated inventory management device with real-time sync & barcode scanner integration.',
      price: '৳ 8,900',
      stock: '45 Units in Stock',
      tag: 'POPULAR',
      icon: Icons.devices_other_rounded,
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500',
    ),
    SampleProductModel(
      id: 'P03',
      title: 'Industrial Heavy Duty Storage Crate',
      description: 'Reinforced stackable warehouse crate designed for high-capacity freight logistics.',
      price: '৳ 4,120',
      stock: '85 Units in Stock',
      tag: 'FEATURED',
      icon: Icons.archive_outlined,
      imageUrl: 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=500',
    ),
    SampleProductModel(
      id: 'P04',
      title: 'Organic Tea & Beverage Bulk Container',
      description: 'Sealed export quality tea container ready for wholesale distribution across regional markets.',
      price: '৳ 1,850',
      stock: '210 Units in Stock',
      tag: 'BESTSELLER',
      icon: Icons.emoji_food_beverage_outlined,
      imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=500',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredList = _sampleProducts.where((product) {
      return product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
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
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final product = filteredList[index];

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
                          // Real Product Image Thumbnail with fallback
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
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      product.icon,
                                      color: primaryOrange,
                                      size: 26.sp,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          UIHelper.horizontalSpace(12.w),

                          // Title & Tag
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.title,
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
                                    product.tag,
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
                      UIHelper.verticalSpace(10.h),

                      // Description Paragraph
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColorsTheme.textMutedColor(context),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      UIHelper.verticalSpace(12.h),
                      Divider(color: AppColorsTheme.borderColor(context)),
                      UIHelper.verticalSpace(10.h),

                      // Bottom Row: Price, Stock & Action Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.price,
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w900,
                                  color: primaryOrange,
                                ),
                              ),
                              UIHelper.verticalSpace(2.h),
                              Text(
                                product.stock,
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
                                  content: Text('Selected ${product.title}'),
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
