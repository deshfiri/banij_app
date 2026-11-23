import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../constants/image_const.dart';
import '../../orders_screen.dart';
import '../../products_screen.dart';
import '../../website_screen.dart';

/// Module groups shown as filter chips and section headers.
enum ModuleCategory {
  products(labelKey: 'filter_products', icon: Icons.shopping_bag_outlined),
  sales(
    labelKey: 'filter_sales_orders',
    icon: Icons.format_list_bulleted_rounded,
  );

  final String labelKey;
  final IconData icon;

  const ModuleCategory({required this.labelKey, required this.icon});
}

/// One feature entry on the All Modules screen.
/// [open] is null for modules that are listed but not wired to a screen yet.
class AppModule {
  final String titleKey;
  final ModuleCategory category;
  final String iconAsset;
  final void Function(BuildContext context)? open;

  const AppModule({
    required this.titleKey,
    required this.category,
    required this.iconAsset,
    this.open,
  });
}

/// Single source of truth for every module and what tapping it opens.
class ModuleConfig {
  ModuleConfig._();

  static final List<AppModule> modules = [
    AppModule(
      titleKey: 'hub_products',
      category: ModuleCategory.products,
      iconAsset: productIcon,
      open: (context) =>
          ProductsScreen.open(context, 'hub_products'.tr, isCatalog: true),
    ),
    AppModule(
      titleKey: 'hub_my_products',
      category: ModuleCategory.products,
      iconAsset: myProductsIconAsset,
      open: (context) => ProductsScreen.open(context, 'hub_my_products'.tr),
    ),
    AppModule(
      titleKey: 'hub_my_damages',
      category: ModuleCategory.products,
      iconAsset: myDamagesIconAsset,
    ),
    AppModule(
      titleKey: 'hub_all_orders',
      category: ModuleCategory.sales,
      iconAsset: allOrdersIconAsset,
      open: (context) => OrdersScreen.open(context, 'hub_all_orders'.tr),
    ),
    AppModule(
      titleKey: 'hub_customers',
      category: ModuleCategory.sales,
      iconAsset: customersIconAsset,
      open: (context) => OrdersScreen.open(context, 'hub_customers'.tr),
    ),
    AppModule(
      titleKey: 'hub_orders',
      category: ModuleCategory.sales,
      iconAsset: cartIconAsset,
      open: (context) => OrdersScreen.open(context, 'hub_orders'.tr),
    ),
    AppModule(
      titleKey: 'hub_store_orders',
      category: ModuleCategory.sales,
      iconAsset: storeOrdersIconAsset,
    ),
    AppModule(
      titleKey: 'hub_order_exchange',
      category: ModuleCategory.sales,
      iconAsset: orderExchangeIconAsset,
    ),
    AppModule(
      titleKey: 'hub_my_websites',
      category: ModuleCategory.sales,
      iconAsset: websiteIconAsset,
      open: (context) => WebsiteScreen.open(context),
    ),
  ];
}
