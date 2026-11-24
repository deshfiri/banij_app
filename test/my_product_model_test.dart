import 'package:bbnij/feature/dashboard/model/my_product_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses structured ownership in my-product responses', () {
    final response = MyProductResponseModel.fromJson({
      'data': [
        {
          'slug': 'dfsdfsdf',
          'name': 'Ignacia Leon',
          'sku': '786786786',
          'category': 'School Wear',
          'purchased': true,
          'ownership': {
            'units': [
              {
                'sku': '786786786',
                'variant': null,
                'purchased': 10,
                'available': 10,
                'reserved': 0,
                'sold': 0,
                'unavailable': 0,
              },
            ],
            'totals': {
              'purchased': 10,
              'available': 10,
              'reserved': 0,
              'sold': 0,
              'unavailable': 0,
            },
            'storefronts': [],
          },
          'variant_count': 0,
          'package_scope': 'all',
          'image': null,
          'wholesale': {
            'price': {
              'amount': '110.00',
              'currency': 'BDT',
              'formatted': '৳110.00',
            },
            'min_order_quantity': 10,
            'max_order_quantity': 373,
            'in_stock': true,
            'tiers': [],
          },
          'partner_selling': {
            'suggested_selling_price': null,
            'minimum_selling_price': null,
            'maximum_selling_price': null,
          },
        },
      ],
    });

    final product = response.data!.single;
    final ownership = product.ownershipDetails!;

    expect(product.name, 'Ignacia Leon');
    expect(product.purchased, 'true');
    expect(ownership.units.single.sku, '786786786');
    expect(ownership.units.single.available, 10);
    expect(ownership.totals?.available, 10);
    expect(product.toJson()['ownership'], isA<Map<String, dynamic>>());
  });

  test('keeps string ownership values compatible', () {
    final product = ProductItemModel.fromJson({'ownership': 'supplier'});

    expect(product.ownership, 'supplier');
    expect(product.ownershipDetails, isNull);
  });
}
