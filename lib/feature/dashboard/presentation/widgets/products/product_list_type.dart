import 'package:flutter/material.dart';

/// Product list tabs. [apiType] is the catalog `type` query value;
/// [myProducts] is served by a different endpoint and has none.
enum ProductListType {
  all(labelKey: 'All Products', icon: Icons.apps_rounded, apiType: 'all'),
  wholesale(labelKey: 'Wholesale', icon: Icons.warehouse_outlined, apiType: 'wholesale'),
  dropshipping(labelKey: 'Dropshipping', icon: Icons.local_shipping_outlined, apiType: 'dropshipping'),
  myProducts(labelKey: 'My Products', icon: Icons.inventory_2_outlined, apiType: null);

  final String labelKey;
  final IconData icon;
  final String? apiType;

  const ProductListType({required this.labelKey, required this.icon, required this.apiType});

  bool get isCatalog => this != myProducts;
}
