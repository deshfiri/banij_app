/// Server-side catalog filters (search, category, brand, stock, price, scope).
/// Immutable; build a new instance to change it.
class ProductFilters {
  final String? search;
  final String? category;
  final String? brand;
  final String? stock;
  final String? priceMin;
  final String? priceMax;
  final String? scope;

  const ProductFilters({
    this.search,
    this.category,
    this.brand,
    this.stock,
    this.priceMin,
    this.priceMax,
    this.scope,
  });

  /// From the map returned by `CatalogAdvancedFilterSheet`'s onApply.
  factory ProductFilters.fromMap(Map<String, dynamic> map) => ProductFilters(
        search: _clean(map['search']),
        category: _clean(map['category']),
        brand: _clean(map['brand']),
        stock: _clean(map['stock']),
        priceMin: _clean(map['price_min']),
        priceMax: _clean(map['price_max']),
        scope: _clean(map['scope']),
      );

  ProductFilters withSearch(String? value) => _copy(search: _clean(value), keepCategory: true);

  ProductFilters withCategory(String? value) => _copy(search: search, category: _clean(value));

  /// True when any advanced filter (not search/category) is applied.
  bool get hasAdvanced => brand != null || stock != null || priceMin != null || priceMax != null || scope != null;

  ProductFilters _copy({String? search, String? category, bool keepCategory = false}) => ProductFilters(
        search: search,
        category: keepCategory ? this.category : category,
        brand: brand,
        stock: stock,
        priceMin: priceMin,
        priceMax: priceMax,
        scope: scope,
      );

  static String? _clean(Object? value) {
    final text = value?.toString().trim();
    return (text == null || text.isEmpty) ? null : text;
  }
}
