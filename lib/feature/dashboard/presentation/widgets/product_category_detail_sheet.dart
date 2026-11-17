import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/toast.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/dashboard_provider.dart';
import '../../model/catalog_model.dart';
import '../../model/my_product_model.dart';
import 'catalog_advanced_filter_sheet.dart';

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
  String _selectedTypeTab = 'All'; // 'All', 'Wholesale', 'Dropshipping', 'My Products'

  String? _currentSearch;
  String? _currentCategory;
  String? _currentBrand;
  String? _currentStock;
  String? _currentPriceMin;
  String? _currentPriceMax;
  String? _currentScope;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (widget.isCatalog) {
          context.read<DashboardProvider>().fetchCatalogProducts(type: 'all');
        } else {
          context.read<DashboardProvider>().fetchMyProducts();
          _selectedTypeTab = 'My Products';
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTypeTabChanged(String tab) {
    setState(() {
      _selectedTypeTab = tab;
      _selectedCategory = 'All';
      _currentCategory = null;
      _currentBrand = null;
      _currentStock = null;
      _currentPriceMin = null;
      _currentPriceMax = null;
      _currentScope = null;
    });
    _fetchProductsWithFilters();
  }

  void _fetchProductsWithFilters() {
    final provider = context.read<DashboardProvider>();
    String? typeArg = 'all';
    if (_selectedTypeTab == 'Wholesale') typeArg = 'wholesale';
    if (_selectedTypeTab == 'Dropshipping') typeArg = 'dropshipping';

    if (_selectedTypeTab == 'My Products') {
      provider.fetchMyProducts();
    } else {
      provider.fetchCatalogProducts(
        type: typeArg,
        search: _currentSearch,
        category: _currentCategory,
        brand: _currentBrand,
        stock: _currentStock,
        priceMin: _currentPriceMin,
        priceMax: _currentPriceMax,
        scope: _currentScope,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();

    // Extract API Data or Catalog Model based on active type tab
    final List<dynamic> rawApiProducts = _selectedTypeTab == 'My Products'
        ? (dashboardProvider.myProductResponse?.data ?? [])
        : (dashboardProvider.catalogResponseModel?.data ?? dashboardProvider.catalogProductResponse?.data ?? []);

    final List<dynamic> apiCategories = _selectedTypeTab == 'My Products'
        ? (dashboardProvider.myProductResponse?.options?.categories ?? [])
        : (dashboardProvider.catalogResponseModel?.options?.categories ?? dashboardProvider.catalogProductResponse?.options?.categories ?? []);

    final List<dynamic> apiBrands = _selectedTypeTab == 'My Products'
        ? []
        : (dashboardProvider.catalogResponseModel?.options?.brands ?? dashboardProvider.catalogProductResponse?.options?.brands ?? []);

    final filteredList = rawApiProducts.where((product) {
      String name = '';
      String category = '';

      if (product is CatalogProductData) {
        name = product.name ?? '';
        category = product.category ?? '';
      } else if (product is ProductItemModel) {
        name = product.name ?? '';
        category = product.category ?? '';
      }

      final matchesSearch = name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' ||
          name.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
          category.toLowerCase().contains(_selectedCategory.toLowerCase());

      return matchesSearch && matchesCategory;
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
                                decoration: const BoxDecoration(
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
          UIHelper.verticalSpace(14.h),

          // Endpoint Type Tabs Bar: All, Wholesale, Dropshipping, My Products
          SizedBox(
            height: 38.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              children: [
                _buildTypeTabChip('All', 'All Products'),
                _buildTypeTabChip('Wholesale', 'Wholesale'),
                _buildTypeTabChip('Dropshipping', 'Dropshipping'),
                _buildTypeTabChip('My Products', 'My Products'),
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
                            onSubmitted: (val) {
                              _fetchProductsWithFilters();
                            },
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search in $_selectedTypeTab...',
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
                              _fetchProductsWithFilters();
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
                    CatalogAdvancedFilterSheet.show(
                      context,
                      initialSearch: _currentSearch,
                      initialCategory: _currentCategory,
                      initialBrand: _currentBrand,
                      initialStock: _currentStock,
                      initialPriceMin: _currentPriceMin,
                      initialPriceMax: _currentPriceMax,
                      initialScope: _currentScope,
                      categories: apiCategories,
                      brands: apiBrands,
                      onApply: (filters) {
                        setState(() {
                          _currentSearch = filters['search'];
                          _currentCategory = filters['category'];
                          _currentBrand = filters['brand'];
                          _currentStock = filters['stock'];
                          _currentPriceMin = filters['price_min'];
                          _currentPriceMax = filters['price_max'];
                          _currentScope = filters['scope'];
                          if (_currentSearch != null) {
                            _searchController.text = _currentSearch!;
                            _searchQuery = _currentSearch!;
                          }
                        });
                        _fetchProductsWithFilters();
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
                        label: const Text('All Categories'),
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
                            _currentCategory = null;
                          });
                          _fetchProductsWithFilters();
                        },
                      ),
                    );
                  }
                  final cat = apiCategories[index - 1];
                  final value = (cat?.value ?? '').toString();
                  final label = (cat?.label ?? '').toString();
                  final displayLabel = label.contains('›') ? label.split('›').last.trim() : label;
                  final isSelected = _selectedCategory == label || _selectedCategory == value;

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
                          _currentCategory = isSelected ? null : value;
                        });
                        _fetchProductsWithFilters();
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
                                fontSize: 13.sp,
                                color: AppColorsTheme.textMutedColor(context),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              return _ProductItemCard(
                                item: item,
                                categoryTitle: widget.categoryTitle,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTabChip(String value, String label) {
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

  Widget _buildProductShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.only(bottom: 12.h),
          height: 85.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
      ),
    );
  }
}

class _ProductItemCard extends StatefulWidget {
  final dynamic item;
  final String categoryTitle;

  const _ProductItemCard({
    required this.item,
    required this.categoryTitle,
  });

  @override
  State<_ProductItemCard> createState() => _ProductItemCardState();
}

class _ProductItemCardState extends State<_ProductItemCard> {
  bool _isAdded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = widget.item;

    String name = 'Product Name';
    String category = 'General';
    String priceText = '৳ 0.00';
    String? imageUrl;
    int minQty = 1;
    bool isFeatured = false;
    String? slug;

    if (item is CatalogProductData) {
      name = item.name ?? 'Product Name';
      category = item.category ?? 'General';
      imageUrl = item.image?.url;
      minQty = item.wholesale?.minOrderQuantity ?? 1;
      isFeatured = item.isFeatured ?? false;
      slug = item.slug;

      if (item.wholesale?.price?.formatted != null) {
        priceText = item.wholesale!.price!.formatted!;
      } else if (item.partnerSelling?.suggestedSellingPrice?.formatted != null) {
        priceText = item.partnerSelling!.suggestedSellingPrice!.formatted!;
      } else if (item.wholesale?.price?.amount != null) {
        priceText = '৳ ${item.wholesale!.price!.amount}';
      }
    } else if (item is ProductItemModel) {
      name = item.name ?? 'Product Name';
      category = item.category ?? 'General';
      imageUrl = item.image?.url;
      minQty = item.wholesale?.minOrderQuantity ?? 1;
      isFeatured = item.isFeatured ?? false;
      slug = item.slug;

      if (item.wholesale?.price?.formatted != null) {
        priceText = item.wholesale!.price!.formatted!;
      }
    }

    final productModel = item is ProductItemModel
        ? item
        : ProductItemModel(
            slug: slug,
            name: name,
            sku: item is CatalogProductData ? item.sku : null,
            category: category,
            image: imageUrl != null ? ProductImageModel(url: imageUrl, alt: name) : null,
            wholesale: WholesaleModel(
              price: PriceModel(amount: priceText.replaceAll(RegExp(r'[^0-9.]'), ''), currency: 'BDT', formatted: priceText),
              minOrderQuantity: minQty,
            ),
          );

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.productDetailScreen,
          arguments: productModel,
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColorsTheme.cardBg(context),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isFeatured ? primaryOrange.withValues(alpha: 0.5) : AppColorsTheme.borderColor(context),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8.r,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image Container
            Container(
              width: 72.w,
              height: 72.h,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: primaryOrange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 72.w,
                      height: 72.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(Icons.shopping_bag_outlined, color: primaryOrange, size: 28.sp),
                      ),
                    )
                  : Center(
                      child: Icon(Icons.shopping_bag_outlined, color: primaryOrange, size: 28.sp),
                    ),
            ),
            UIHelper.horizontalSpace(12.w),

            // Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFeatured) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: primaryOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'FEATURED',
                        style: TextStyle(
                          fontSize: 8.5.sp,
                          fontWeight: FontWeight.w800,
                          color: primaryOrange,
                        ),
                      ),
                    ),
                    UIHelper.verticalSpace(3.h),
                  ],
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(2.h),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        priceText,
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w900,
                          color: primaryOrange,
                        ),
                      ),
                      Text(
                        'Min: $minQty unit',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColorsTheme.textMutedColor(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            UIHelper.horizontalSpace(8.w),

            // Add to Cart Button with Animated Color Feedback
            GestureDetector(
              onTap: () async {
                setState(() {
                  _isAdded = true;
                });
                final cart = context.read<CartProvider>();
                if (slug != null && slug.isNotEmpty) {
                  await cart.addItemToCart(productSlug: slug, quantity: minQty);
                }
                cart.addToCart(productModel, quantity: minQty);
                ToastUtil.showSuccessMessage('$name added to cart');

                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (mounted) {
                    setState(() {
                      _isAdded = false;
                    });
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: _isAdded ? const Color(0xFF10B981) : primaryOrange,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: (_isAdded ? const Color(0xFF10B981) : primaryOrange).withValues(alpha: 0.3),
                      blurRadius: 6.r,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _isAdded ? Icons.check_rounded : Icons.add_shopping_cart_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
