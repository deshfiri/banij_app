import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/empty_state_widget.dart';
import '../../../common_widget/hero_page_header.dart';
import '../../../common_widget/hero_search_field.dart';
import '../../../common_widget/pill_chip.dart';
import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../model/catalog_model.dart';
import '../model/my_product_model.dart';
import 'widgets/catalog_advanced_filter_sheet.dart';
import 'widgets/products/product_card_data.dart';
import 'widgets/products/product_filters.dart';
import 'widgets/products/product_grid_card.dart';
import 'widgets/products/product_grid_shimmer.dart';
import 'widgets/products/product_list_type.dart';

/// Products (catalog) and My Products, styled like the dashboard:
/// hero header with search + filters, type tabs, category chips, product grid.
class ProductsScreen extends StatefulWidget {
  final String title;
  final ProductListType initialType;

  const ProductsScreen({super.key, required this.title, required this.initialType});

  /// [isCatalog] opens on "All Products"; otherwise on "My Products".
  static Future<void> open(BuildContext context, String title, {bool isCatalog = false}) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductsScreen(
          title: title,
          initialType: isCatalog ? ProductListType.all : ProductListType.myProducts,
        ),
      ),
    );
  }

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late ProductListType _type = widget.initialType;
  ProductFilters _filters = const ProductFilters();

  /// Search text the current catalog results were fetched with. The server
  /// already applied it (and may match on SKU/brand/description), so it must
  /// not be re-applied as a local name/category filter.
  String? _serverSearch;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetch() {
    final provider = context.read<DashboardProvider>();
    if (!_type.isCatalog) return provider.fetchMyProducts();
    _serverSearch = _filters.search;
    return provider.fetchCatalogProducts(
      type: _type.apiType,
      search: _filters.search,
      category: _filters.category,
      brand: _filters.brand,
      stock: _filters.stock,
      priceMin: _filters.priceMin,
      priceMax: _filters.priceMax,
      scope: _filters.scope,
    );
  }

  void _changeType(ProductListType type) {
    if (type == _type) return;
    // Switching tabs keeps the search text but resets the other filters.
    setState(() {
      _type = type;
      _filters = ProductFilters(search: _filters.search);
    });
    _fetch();
  }

  void _changeCategory(String? value) {
    setState(() => _filters = _filters.withCategory(value));
    // My Products filters categories locally; only the catalog needs a refetch.
    if (_type.isCatalog) _fetch();
  }

  void _openAdvancedFilters(_ProductsData data) {
    CatalogAdvancedFilterSheet.show(
      context,
      initialSearch: _filters.search,
      initialCategory: _filters.category,
      initialBrand: _filters.brand,
      initialStock: _filters.stock,
      initialPriceMin: _filters.priceMin,
      initialPriceMax: _filters.priceMax,
      initialScope: _filters.scope,
      categories: data.rawCategories,
      brands: data.rawBrands,
      onApply: (map) {
        setState(() {
          _filters = ProductFilters.fromMap(map);
          _searchController.text = _filters.search ?? '';
        });
        _fetch();
      },
    );
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() => _filters = const ProductFilters());
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final data = _ProductsData.from(provider, _type);
    final products = _applyLocalFilters(data);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            HeroPageHeader(
              title: widget.title,
              subtitle: 'Browse items & manage inventory'.tr,
              trailing: Consumer<CartProvider>(
                builder: (context, cart, _) => HeroIconButton(
                  icon: Icons.shopping_bag_outlined,
                  badgeCount: cart.totalItemsCount,
                  onTap: () => Navigator.pushNamed(context, Routes.cartScreen),
                ),
              ),
              bottom: Row(
                children: [
                  Expanded(
                    child: HeroSearchField(
                      controller: _searchController,
                      hintText: 'Search in @type'.trParams({'type': _type.labelKey.tr}),
                      onChanged: (value) => setState(() => _filters = _filters.withSearch(value)),
                      onSubmitted: (_) => _fetch(),
                      onCleared: _fetch,
                    ),
                  ),
                  if (_type.isCatalog) ...[
                    UIHelper.horizontalSpace(10.w),
                    HeroSquareButton(
                      icon: Icons.tune_rounded,
                      isActive: _filters.hasAdvanced,
                      onTap: () => _openAdvancedFilters(data),
                    ),
                  ],
                ],
              ),
            ),
            UIHelper.verticalSpace(14.h),
            PillChipBar(
              chips: [
                for (final type in ProductListType.values)
                  PillChip(
                    label: type.labelKey.tr,
                    icon: type.icon,
                    isSelected: type == _type,
                    onTap: () => _changeType(type),
                  ),
              ],
            ),
            if (data.categories.isNotEmpty) ...[
              UIHelper.verticalSpace(10.h),
              PillChipBar(
                compact: true,
                chips: [
                  PillChip(
                    compact: true,
                    label: 'All Categories'.tr,
                    isSelected: _filters.category == null,
                    onTap: () => _changeCategory(null),
                  ),
                  for (final option in data.categories)
                    PillChip(
                      compact: true,
                      label: option.shortLabel,
                      isSelected: _filters.category == option.value,
                      // Tapping the selected category again clears it.
                      onTap: () => _changeCategory(_filters.category == option.value ? null : option.value),
                    ),
                ],
              ),
            ],
            _ResultsBar(
              count: products.length,
              showClear: _filters.hasAdvanced || _filters.category != null || _filters.search != null,
              onClear: _clearFilters,
            ),
            Expanded(child: _buildBody(provider.isLoadingProducts, data, products)),
          ],
        ),
      ),
    );
  }

  /// Instant client-side search while typing; category too for My Products,
  /// whose endpoint does not take a category filter.
  List<ProductCardData> _applyLocalFilters(_ProductsData data) {
    // Catalog results already reflect the submitted search; only filter locally
    // while the typed text differs from it (or for My Products).
    final serverApplied = _type.isCatalog && _filters.search == _serverSearch;
    final query = serverApplied ? '' : (_filters.search ?? '').toLowerCase();
    final categoryLabel = _type.isCatalog || _filters.category == null
        ? null
        : data.categories.where((c) => c.value == _filters.category).map((c) => c.shortLabel.toLowerCase()).firstOrNull;

    return data.products.where((p) {
      final name = p.name.toLowerCase();
      final category = p.category.toLowerCase();
      final matchesQuery = query.isEmpty || name.contains(query) || category.contains(query);
      final matchesCategory = categoryLabel == null || category.contains(categoryLabel);
      return matchesQuery && matchesCategory;
    }).toList();
  }

  Widget _buildBody(bool isLoading, _ProductsData data, List<ProductCardData> products) {
    if (isLoading) return const ProductGridShimmer();

    final Widget content;
    if (data.products.isEmpty) {
      content = EmptyStateWidget(icon: Icons.inventory_2_outlined, message: 'No products found'.tr);
    } else if (products.isEmpty) {
      content = EmptyStateWidget(icon: Icons.search_off_rounded, message: 'No matching products found'.tr);
    } else {
      content = GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          mainAxisExtent: ProductGridCard.extent,
        ),
        itemCount: products.length,
        itemBuilder: (_, index) => ProductGridCard(product: products[index]),
      );
    }

    return RefreshIndicator(
      color: primaryOrange,
      onRefresh: _fetch,
      // Empty states need a scrollable for pull-to-refresh to work.
      child: content is GridView
          ? content
          : LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(height: constraints.maxHeight, child: content),
              ),
            ),
    );
  }
}

/// "12 products" + optional "Clear filters".
class _ResultsBar extends StatelessWidget {
  final int count;
  final bool showClear;
  final VoidCallback onClear;

  const _ResultsBar({required this.count, required this.showClear, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 15.h,
            decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(2.r)),
          ),
          UIHelper.horizontalSpace(8.w),
          Expanded(
            child: Text(
              '@count products'.trParams({'count': '$count'}),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
          ),
          if (showClear)
            GestureDetector(
              onTap: onClear,
              child: Text(
                'Clear filters'.tr,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: primaryOrange),
              ),
            ),
        ],
      ),
    );
  }
}

/// Products, categories and brands for the active tab, from whichever
/// provider response backs it.
class _ProductsData {
  final List<ProductCardData> products;
  final List<ProductCategoryOption> categories;
  final List<dynamic> rawCategories;
  final List<dynamic> rawBrands;

  const _ProductsData({
    required this.products,
    required this.categories,
    required this.rawCategories,
    required this.rawBrands,
  });

  factory _ProductsData.from(DashboardProvider provider, ProductListType type) {
    final List<dynamic> rawProducts;
    final List<dynamic> rawCategories;
    final List<dynamic> rawBrands;

    if (type.isCatalog) {
      rawProducts = provider.catalogResponseModel?.data ?? provider.catalogProductResponse?.data ?? [];
      rawCategories = provider.catalogResponseModel?.options?.categories ??
          provider.catalogProductResponse?.options?.categories ??
          [];
      rawBrands = provider.catalogResponseModel?.options?.brands ??
          provider.catalogProductResponse?.options?.brands ??
          [];
    } else {
      rawProducts = provider.myProductResponse?.data ?? [];
      rawCategories = provider.myProductResponse?.options?.categories ?? [];
      rawBrands = const [];
    }

    return _ProductsData(
      products: rawProducts.map(ProductCardData.from).whereType<ProductCardData>().toList(),
      categories: rawCategories.map(_toCategoryOption).whereType<ProductCategoryOption>().toList(),
      rawCategories: rawCategories,
      rawBrands: rawBrands,
    );
  }

  static ProductCategoryOption? _toCategoryOption(dynamic option) {
    String? value;
    String? label;
    if (option is CatalogOptionItem) {
      value = option.value;
      label = option.label;
    } else if (option is CategoryOptionModel) {
      value = option.value;
      label = option.label;
    }
    if (value == null || value.isEmpty) return null;
    return ProductCategoryOption(value: value, label: label ?? value);
  }
}
