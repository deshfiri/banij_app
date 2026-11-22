import '../../../model/catalog_model.dart';
import '../../../model/my_product_model.dart';

/// UI-ready product, built from either API shape (catalog or my products),
/// so the list and card never deal with `dynamic`.
class ProductCardData {
  final String name;
  final String category;
  final String priceText;
  final String? imageUrl;
  final String? slug;
  final int minQty;
  final bool isFeatured;

  /// Model passed to the cart and the product detail screen.
  final ProductItemModel model;

  const ProductCardData({
    required this.name,
    required this.category,
    required this.priceText,
    required this.minQty,
    required this.isFeatured,
    required this.model,
    this.imageUrl,
    this.slug,
  });

  /// Returns null for items of an unknown type.
  static ProductCardData? from(Object? item) {
    if (item is CatalogProductData) return ProductCardData._fromCatalog(item);
    if (item is ProductItemModel) return ProductCardData._fromMyProduct(item);
    return null;
  }

  factory ProductCardData._fromCatalog(CatalogProductData p) {
    final name = p.name ?? '';
    final category = p.category ?? '';
    final imageUrl = p.image?.url;
    final minQty = p.wholesale?.minOrderQuantity ?? 1;
    final priceText = _firstNonEmpty([
          p.wholesale?.price?.formatted,
          p.partnerSelling?.suggestedSellingPrice?.formatted,
          p.wholesale?.price?.amount == null ? null : '৳ ${p.wholesale!.price!.amount}',
        ]) ??
        '৳ 0.00';

    return ProductCardData(
      name: name,
      category: category,
      priceText: priceText,
      imageUrl: imageUrl,
      slug: p.slug,
      minQty: minQty,
      isFeatured: p.isFeatured ?? false,
      model: ProductItemModel(
        slug: p.slug,
        name: name,
        sku: p.sku,
        category: category,
        image: imageUrl != null ? ProductImageModel(url: imageUrl, alt: name) : null,
        wholesale: WholesaleModel(
          price: PriceModel(
            amount: priceText.replaceAll(RegExp(r'[^0-9.]'), ''),
            currency: 'BDT',
            formatted: priceText,
          ),
          minOrderQuantity: minQty,
        ),
      ),
    );
  }

  factory ProductCardData._fromMyProduct(ProductItemModel p) {
    return ProductCardData(
      name: p.name ?? '',
      category: p.category ?? '',
      priceText: _firstNonEmpty([
            p.wholesale?.price?.formatted,
            p.partnerSelling?.suggestedSellingPrice?.formatted,
          ]) ??
          '৳ 0.00',
      imageUrl: p.image?.url,
      slug: p.slug,
      minQty: p.wholesale?.minOrderQuantity ?? 1,
      isFeatured: p.isFeatured ?? false,
      model: p,
    );
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      if (v != null && v.trim().isNotEmpty) return v;
    }
    return null;
  }
}

/// A category option from either API shape (value is sent, label is shown).
class ProductCategoryOption {
  final String value;
  final String label;

  const ProductCategoryOption({required this.value, required this.label});

  /// "Parent › Child" labels show only the last part on chips.
  String get shortLabel => label.contains('›') ? label.split('›').last.trim() : label;
}
