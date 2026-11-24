import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/empty_state_widget.dart';
import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/toast.dart';
import '../../../providers/cart_provider.dart';
import '../model/my_product_model.dart';
import 'widgets/commerce/product_detail_widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductItemModel? product;

  const ProductDetailScreen({super.key, this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final TextEditingController _quantityController;
  bool _isFavorite = false;

  int get _minimumQuantity {
    final minimum = widget.product?.wholesale?.minOrderQuantity ?? 1;
    return minimum > 0 ? minimum : 1;
  }

  int? get _maximumQuantity {
    final maximum = widget.product?.wholesale?.maxOrderQuantity;
    return maximum != null && maximum >= _minimumQuantity ? maximum : null;
  }

  int get _selectedQuantity {
    final parsed = int.tryParse(_quantityController.text);
    if (parsed == null || parsed < _minimumQuantity) return _minimumQuantity;
    final maximum = _maximumQuantity;
    return maximum != null && parsed > maximum ? maximum : parsed;
  }

  @override
  void initState() {
    super.initState();
    final minimum = widget.product?.wholesale?.minOrderQuantity ?? 1;
    _quantityController = TextEditingController(
      text: '${minimum > 0 ? minimum : 1}',
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    final current = _selectedQuantity;
    final maximum = _maximumQuantity;
    if (maximum != null && current >= maximum) return;
    setState(() => _quantityController.text = '${current + 1}');
  }

  void _decrementQuantity() {
    final current = _selectedQuantity;
    if (current <= _minimumQuantity) return;
    setState(() => _quantityController.text = '${current - 1}');
  }

  void _normalizeQuantity() {
    final quantity = '$_selectedQuantity';
    if (_quantityController.text == quantity) return;
    _quantityController.value = TextEditingValue(
      text: quantity,
      selection: TextSelection.collapsed(offset: quantity.length),
    );
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    ToastUtil.showSuccessMessage(
      (_isFavorite ? 'Added to favorites' : 'Removed from favorites').tr,
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final productName = _nonEmpty(product?.name);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            HeroPageHeader(
              title: 'Product Details'.tr,
              subtitle: productName,
              trailing: product == null ? null : _headerActions(),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: product == null
                    ? Center(
                        child: EmptyStateWidget(
                          icon: Icons.inventory_2_outlined,
                          message: 'Product details unavailable'.tr,
                          subtitle:
                              'Return to the catalog and choose a product.'.tr,
                        ),
                      )
                    : _productContent(context, product, productName),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Favorite'.tr,
          onPressed: _toggleFavorite,
          icon: Icon(
            _isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: Colors.white,
          ),
        ),
        Consumer<CartProvider>(
          builder: (context, cart, _) => HeroIconButton(
            icon: Icons.shopping_bag_outlined,
            badgeCount: cart.totalItemsCount,
            onTap: () => Navigator.pushNamed(context, Routes.cartScreen),
          ),
        ),
      ],
    );
  }

  Widget _productContent(
    BuildContext context,
    ProductItemModel product,
    String? productName,
  ) {
    final displayName = productName ?? 'Product name unavailable'.tr;
    final description = _nonEmpty(product.shortDescription);
    final summary = _productSummary(context, product, displayName, description);
    final purchase = _purchaseDetails(context, product);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 820;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: summary),
                        SizedBox(width: 24.w),
                        Expanded(flex: 5, child: purchase),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        summary,
                        SizedBox(height: 18.h),
                        purchase,
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _productSummary(
    BuildContext context,
    ProductItemModel product,
    String productName,
    String? description,
  ) {
    final badges = _productBadges(product);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductHeroImage(
          imageUrl: _nonEmpty(product.image?.url),
          imageAlt: _nonEmpty(product.image?.alt) ?? productName,
          categoryName: _nonEmpty(product.category),
          isFeatured: product.isFeatured == true,
        ),
        if (badges.isNotEmpty) ...[
          SizedBox(height: 14.h),
          Wrap(spacing: 8.w, runSpacing: 8.h, children: badges),
        ],
        SizedBox(height: 16.h),
        Text(
          productName,
          style: TextStyle(
            fontSize: 21.sp,
            fontWeight: FontWeight.w800,
            height: 1.25,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
        if (description != null) ...[
          SizedBox(height: 8.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: AppColorsTheme.textMutedColor(context),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _productBadges(ProductItemModel product) {
    final badges = <Widget>[];
    final sku = _nonEmpty(product.sku);
    final brand = _nonEmpty(product.brand);
    final packageScope = _nonEmpty(product.packageScope);
    final ownership = _nonEmpty(product.ownership);

    if (sku != null) {
      badges.add(
        ProductInfoBadge.tinted(
          icon: Icons.qr_code_rounded,
          label: 'SKU: @sku'.trParams({'sku': sku}),
          color: infoBlue,
        ),
      );
    }
    if (brand != null) {
      badges.add(
        ProductInfoBadge.tinted(
          icon: Icons.sell_outlined,
          label: brand,
          color: purpleAccent,
        ),
      );
    }
    if (product.wholesale != null) {
      badges.add(
        ProductInfoBadge.tinted(
          icon: Icons.warehouse_outlined,
          label: 'Wholesale'.tr,
          color: infoBlue,
        ),
      );
    }
    if (product.partnerSelling != null) {
      badges.add(
        ProductInfoBadge.tinted(
          icon: Icons.storefront_outlined,
          label: 'Partner Selling'.tr,
          color: successGreen,
        ),
      );
    }
    if (packageScope != null) {
      badges.add(
        ProductInfoBadge.tinted(
          icon: Icons.inventory_2_outlined,
          label: packageScope,
          color: primaryOrange,
        ),
      );
    }
    if (ownership != null) {
      badges.add(
        ProductInfoBadge.tinted(
          icon: Icons.account_circle_outlined,
          label: ownership,
          color: infoBlue,
        ),
      );
    }
    final purchased = _nonEmpty(product.purchased);
    if (purchased != null) {
      badges.add(
        ProductInfoBadge.tinted(
          icon: Icons.shopping_bag_outlined,
          label: 'Purchased: @count'.trParams({'count': purchased}),
          color: successGreen,
        ),
      );
    }
    if (product.variantCount case final int count when count > 0) {
      badges.add(
        ProductInfoBadge.tinted(
          icon: Icons.view_module_outlined,
          label: '$count ${'variants'.tr}',
          color: purpleAccent,
        ),
      );
    }
    return badges;
  }

  Widget _purchaseDetails(BuildContext context, ProductItemModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductPriceStockCard(product: product),
        SizedBox(height: 16.h),
        ProductOrderCard(
          quantityController: _quantityController,
          minOrderQuantity: product.wholesale?.minOrderQuantity,
          maxOrderQuantity: product.wholesale?.maxOrderQuantity,
          onDecrement: _decrementQuantity,
          onIncrement: _incrementQuantity,
          onQuantitySubmitted: _normalizeQuantity,
          onOrderNow: () {
            _normalizeQuantity();
            Navigator.pushNamed(
              context,
              Routes.orderNowScreen,
              arguments: product,
            );
          },
          onAddToCart: () {
            _normalizeQuantity();
            context.read<CartProvider>().addToCart(
              product,
              quantity: _selectedQuantity,
            );
          },
          onViewCart: () => Navigator.pushNamed(context, Routes.cartScreen),
        ),
      ],
    );
  }

  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
