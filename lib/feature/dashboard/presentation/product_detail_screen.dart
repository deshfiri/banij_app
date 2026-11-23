import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/cart_provider.dart';
import '../model/my_product_model.dart';
import 'widgets/commerce/product_detail_widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductItemModel? product;

  const ProductDetailScreen({
    super.key,
    this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Fallbacks shown when no product was passed in.
  static const String _placeholderImage = 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500';
  static const String _placeholderTitle =
      'Officia veritatis qui irure dolorem in et ipsum asperiores ad vitae iusto ipsum alias sapiente quisquam voluptate sapiente vel';
  static const String _placeholderSku = '123456789';
  static const String _placeholderPrice = '৳15.00';
  static const String _placeholderStock = '1000';
  static const String _placeholderCategory = 'HAIR CARE';

  final TextEditingController _quantityController = TextEditingController(text: '1');
  bool _isFavorite = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    int current = int.tryParse(_quantityController.text) ?? 1;
    setState(() {
      _quantityController.text = (current + 1).toString();
    });
  }

  void _decrementQuantity() {
    int current = int.tryParse(_quantityController.text) ?? 1;
    if (current > 1) {
      setState(() {
        _quantityController.text = (current - 1).toString();
      });
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    ToastUtil.showSuccessMessage(_isFavorite ? 'Added to favorites' : 'Removed from favorites');
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    final imageUrl =
        (product?.image?.url != null && product!.image!.url!.isNotEmpty) ? product.image!.url! : _placeholderImage;
    final titleText = product?.name ?? _placeholderTitle;
    final bpcCode = product?.sku ?? _placeholderSku;
    final wholesalePrice = product?.wholesale?.price?.formatted ?? _placeholderPrice;
    final availableStock = product?.wholesale?.inStock ?? _placeholderStock;
    final categoryName = product?.category ?? _placeholderCategory;

    // The passed product, or a stand-in built from the displayed values.
    ProductItemModel effectiveProduct() =>
        product ??
        ProductItemModel(
          slug: 'default-prod',
          name: titleText,
          category: categoryName,
          image: ProductImageModel(url: imageUrl),
          wholesale: WholesaleModel(price: PriceModel(formatted: wholesalePrice), inStock: availableStock),
        );

    final mainColor = AppColorsTheme.textMainColor(context);

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppColorsTheme.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: mainColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Product Details'.tr,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: mainColor),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? Colors.redAccent : mainColor,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: Icon(Icons.share_outlined, color: mainColor),
            onPressed: () => ToastUtil.showSuccessMessage('Share link copied!'),
          ),
          ProductCartAction(onTap: () => Navigator.pushNamed(context, Routes.cartScreen)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductHeroImage(imageUrl: imageUrl, categoryName: categoryName),
              UIHelper.verticalSpace(16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'BPC: $bpcCode',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                  ProductInfoBadge.tinted(icon: Icons.local_shipping_outlined, label: 'Wholesale', color: infoBlue),
                  ProductInfoBadge.tinted(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Partner Selling',
                    color: successGreen,
                  ),
                  ProductInfoBadge(
                    icon: Icons.radio_button_unchecked_rounded,
                    label: 'All packages',
                    bgColor: AppColorsTheme.cardBg(context),
                    textColor: AppColorsTheme.textMutedColor(context),
                    borderColor: AppColorsTheme.borderColor(context),
                  ),
                ],
              ),
              UIHelper.verticalSpace(14.h),
              Text(
                titleText,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: mainColor, height: 1.35),
              ),
              UIHelper.verticalSpace(16.h),
              ProductPriceStockCard(wholesalePrice: wholesalePrice, availableStock: availableStock),
              UIHelper.verticalSpace(16.h),
              ProductOrderCard(
                quantityController: _quantityController,
                onDecrement: _decrementQuantity,
                onIncrement: _incrementQuantity,
                onOrderNow: () => Navigator.pushNamed(context, Routes.orderNowScreen, arguments: effectiveProduct()),
                onAddToCart: () {
                  final qty = int.tryParse(_quantityController.text) ?? 1;
                  context.read<CartProvider>().addToCart(effectiveProduct(), quantity: qty);
                },
                onViewCart: () => Navigator.pushNamed(context, Routes.cartScreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
