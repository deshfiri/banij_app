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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final product = widget.product;

    final imageUrl = (product?.image?.url != null && product!.image!.url!.isNotEmpty)
        ? product.image!.url!
        : 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500';
    final titleText = product?.name ??
        'Officia veritatis qui irure dolorem in et ipsum asperiores ad vitae iusto ipsum alias sapiente quisquam voluptate sapiente vel';
    final bpcCode = product?.sku ?? '123456789';
    final wholesalePrice = product?.wholesale?.price?.formatted ?? '৳15.00';
    final availableStock = product?.wholesale?.inStock ?? '1000';
    final categoryName = product?.category ?? 'HAIR CARE';

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppColorsTheme.cardBg(context),
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColorsTheme.textMainColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Product Details'.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? Colors.redAccent : AppColorsTheme.textMainColor(context),
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              ToastUtil.showSuccessMessage(
                _isFavorite ? 'Added to favorites' : 'Removed from favorites',
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: AppColorsTheme.textMainColor(context),
            ),
            onPressed: () {
              ToastUtil.showSuccessMessage('Share link copied!');
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColorsTheme.textMainColor(context),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, Routes.cartScreen);
                },
              ),
              Positioned(
                right: 8.w,
                top: 8.h,
                child: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    if (cart.totalItemsCount == 0) return const SizedBox.shrink();
                    return Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: primaryOrange,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16.w,
                        minHeight: 16.h,
                      ),
                      child: Text(
                        '${cart.totalItemsCount}',
                        style: TextStyle(
                          fontSize: 9.sp,
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
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Featured Hero Product Image Section
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 220.h,
                    decoration: BoxDecoration(
                      color: AppColorsTheme.cardBg(context),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColorsTheme.borderColor(context),
                        width: 1.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                          blurRadius: 12.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 64.sp,
                              color: primaryOrange,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Floating Category Tag Pill
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6.r,
                          ),
                        ],
                      ),
                      child: Text(
                        categoryName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpace(16.h),

              // 2. Top Row Badges: BPC code, Wholesale, Partner Selling, All packages
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
                  _buildBadge(
                    context: context,
                    icon: Icons.local_shipping_outlined,
                    label: 'Wholesale',
                    bgColor: const Color(0xFF0284C7).withValues(alpha: 0.15),
                    textColor: const Color(0xFF0284C7),
                    borderColor: const Color(0xFF0284C7).withValues(alpha: 0.3),
                  ),
                  _buildBadge(
                    context: context,
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Partner Selling',
                    bgColor: const Color(0xFF10B981).withValues(alpha: 0.15),
                    textColor: const Color(0xFF10B981),
                    borderColor: const Color(0xFF10B981).withValues(alpha: 0.3),
                  ),
                  _buildBadge(
                    context: context,
                    icon: Icons.radio_button_unchecked_rounded,
                    label: 'All packages',
                    bgColor: AppColorsTheme.cardBg(context),
                    textColor: AppColorsTheme.textMutedColor(context),
                    borderColor: AppColorsTheme.borderColor(context),
                  ),
                ],
              ),
              UIHelper.verticalSpace(14.h),

              // Main Product Title / Description
              Text(
                titleText,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColorsTheme.textMainColor(context),
                  height: 1.35,
                ),
              ),
              UIHelper.verticalSpace(16.h),

              // Card 1: Wholesale Price & Stock Summary Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColorsTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColorsTheme.borderColor(context),
                    width: 1.w,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wholesale price',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColorsTheme.textMutedColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(4.h),
                    Text(
                      wholesalePrice,
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w900,
                        color: primaryOrange,
                      ),
                    ),
                    UIHelper.verticalSpace(16.h),
                    Text(
                      'Stock',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColorsTheme.textMutedColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(6.h),
                    Row(
                      children: [
                        _buildBadge(
                          context: context,
                          icon: Icons.check_circle_outline_rounded,
                          label: 'In stock',
                          bgColor: const Color(0xFF10B981).withValues(alpha: 0.15),
                          textColor: const Color(0xFF10B981),
                          borderColor: const Color(0xFF10B981).withValues(alpha: 0.3),
                        ),
                        UIHelper.horizontalSpace(8.w),
                        Text(
                          '$availableStock available to order',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColorsTheme.textMainColor(context),
                          ),
                        ),
                      ],
                    ),
                    UIHelper.verticalSpace(14.h),
                    Text(
                      'Order quantity',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColorsTheme.textMutedColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(4.h),
                    Text(
                      'Between 10 and 28 units in one order',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              UIHelper.verticalSpace(16.h),

              // Card 2: Order this product Form Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColorsTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColorsTheme.borderColor(context),
                    width: 1.w,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order this product',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(4.h),
                    Text(
                      'Buy in bulk for yourself, receive the goods, and resell them wherever you sell.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColorsTheme.textMutedColor(context),
                        height: 1.3,
                      ),
                    ),
                    UIHelper.verticalSpace(14.h),
                    Divider(color: AppColorsTheme.borderColor(context)),
                    UIHelper.verticalSpace(12.h),

                    Text(
                      'WHAT YOU ARE BUYING',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColorsTheme.textMutedColor(context),
                        letterSpacing: 0.8,
                      ),
                    ),
                    UIHelper.verticalSpace(6.h),
                    Text(
                      'Quantity to order',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(8.h),

                    // Interactive Quantity Stepper & Input TextField
                    Row(
                      children: [
                        // Decrement (-) Button
                        GestureDetector(
                          onTap: _decrementQuantity,
                          child: Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: AppColorsTheme.background(context),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: AppColorsTheme.borderColor(context)),
                            ),
                            child: Icon(
                              Icons.remove_rounded,
                              size: 18.sp,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          ),
                        ),
                        UIHelper.horizontalSpace(8.w),

                        // Quantity Input TextField
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w),
                            decoration: BoxDecoration(
                              color: AppColorsTheme.background(context),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: AppColorsTheme.borderColor(context)),
                            ),
                            child: TextField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColorsTheme.textMainColor(context),
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        UIHelper.horizontalSpace(8.w),

                        // Increment (+) Button
                        GestureDetector(
                          onTap: _incrementQuantity,
                          child: Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: AppColorsTheme.background(context),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: AppColorsTheme.borderColor(context)),
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              size: 18.sp,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    UIHelper.verticalSpace(6.h),
                    Text(
                      'Between 10 and 28',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColorsTheme.textMutedColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(20.h),

                    // Action Buttons: Order Now, Add to Cart, View Cart
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            final effectiveProduct = product ?? ProductItemModel(
                              slug: 'default-prod',
                              name: titleText,
                              category: categoryName,
                              image: ProductImageModel(url: imageUrl),
                              wholesale: WholesaleModel(price: PriceModel(formatted: wholesalePrice), inStock: availableStock),
                            );
                            Navigator.pushNamed(
                              context,
                              Routes.orderNowScreen,
                              arguments: effectiveProduct,
                            );
                          },
                          icon: Icon(Icons.bolt_rounded, size: 16.sp),
                          label: Text(
                            'Order now',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryOrange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            elevation: 0,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            final qty = int.tryParse(_quantityController.text) ?? 1;
                            final effectiveProduct = product ?? ProductItemModel(
                              slug: 'default-prod',
                              name: titleText,
                              category: categoryName,
                              image: ProductImageModel(url: imageUrl),
                              wholesale: WholesaleModel(price: PriceModel(formatted: wholesalePrice), inStock: availableStock),
                            );
                            context.read<CartProvider>().addToCart(effectiveProduct, quantity: qty);
                            ToastUtil.showSuccessMessage('Added $qty units to cart!');
                          },
                          icon: Icon(Icons.shopping_bag_outlined, size: 16.sp),
                          label: Text(
                            'Add to cart',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            foregroundColor: AppColorsTheme.textMainColor(context),
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            side: BorderSide(color: AppColorsTheme.borderColor(context)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, Routes.cartScreen);
                          },
                          child: Text(
                            'View cart',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColorsTheme.textMainColor(context),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    UIHelper.verticalSpace(14.h),

                    // Bottom helper subtext
                    Text(
                      'Order now goes straight to checkout, where you choose how to pay. Add to cart keeps the item for later.',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColorsTheme.textMutedColor(context),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor, width: 1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: textColor),
          UIHelper.horizontalSpace(4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
