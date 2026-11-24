import 'package:bbnij/feature/dashboard/model/catalog_model.dart';
import 'package:bbnij/feature/dashboard/presentation/widgets/products/product_card_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog fields are preserved for the product detail screen', () {
    final catalogProduct = CatalogProductData.fromJson({
      'slug': 'green-tea',
      'name': 'Green Tea',
      'sku': 'TEA-01',
      'category': 'Tea',
      'brand': 'Garden',
      'description': 'Loose-leaf green tea.',
      'is_featured': true,
      'purchased': '3',
      'ownership': 'supplier',
      'variant_count': '2',
      'package_scope': 'premium',
      'image': {'url': 'https://example.test/tea.png', 'alt': 'Green tea'},
      'wholesale': {
        'price': {'amount': '45', 'currency': 'BDT', 'formatted': '৳45'},
        'min_order_quantity': '5',
        'max_order_quantity': '20',
        'in_stock': '30',
      },
      'partner_selling': {
        'suggested_selling_price': {
          'amount': '65',
          'currency': 'BDT',
          'formatted': '৳65',
        },
        'minimum_selling_price': {'amount': '55', 'formatted': '৳55'},
        'maximum_selling_price': {'amount': '80', 'formatted': '৳80'},
      },
    });

    final product = ProductCardData.from(catalogProduct)!.model;

    expect(product.shortDescription, 'Loose-leaf green tea.');
    expect(product.brand, 'Garden');
    expect(product.packageScope, 'premium');
    expect(product.variantCount, 2);
    expect(product.image?.alt, 'Green tea');
    expect(product.wholesale?.price?.formatted, '৳45');
    expect(product.wholesale?.minOrderQuantity, 5);
    expect(product.wholesale?.maxOrderQuantity, 20);
    expect(product.wholesale?.inStock, '30');
    expect(product.partnerSelling?.suggestedSellingPrice?.formatted, '৳65');
    expect(product.partnerSelling?.minimumSellingPrice?.formatted, '৳55');
    expect(product.partnerSelling?.maximumSellingPrice?.formatted, '৳80');
  });

  test('missing catalog prices are not turned into product detail prices', () {
    final catalogProduct = CatalogProductData.fromJson({
      'slug': 'new-product',
      'name': 'New product',
    });

    final product = ProductCardData.from(catalogProduct)!.model;

    expect(product.wholesale, isNull);
    expect(product.partnerSelling, isNull);
  });
}
