import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/all_routes.dart';
import '../../../../../helpers/toast.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../providers/cart_provider.dart';
import '../dashboard_card_decoration.dart';
import 'product_card_data.dart';

/// Grid card in the dashboard card style: image, featured badge, name,
/// category, price, min quantity and an add-to-cart button.
class ProductGridCard extends StatelessWidget {
  final ProductCardData product;

  const ProductGridCard({super.key, required this.product});

  /// Height the grid should give each card.
  static double get extent => 260.h;

  void _openDetail(BuildContext context) {
    Navigator.pushNamed(context, Routes.productDetailScreen, arguments: product.model);
  }

  @override
  Widget build(BuildContext context) {
    final radius = 18.r;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetail(context),
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: DashboardCardDecoration.of(context, radius: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImage(product: product, radius: radius),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 9.h, 10.w, 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                      if (product.category.isNotEmpty) ...[
                        UIHelper.verticalSpace(2.h),
                        Text(
                          product.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10.5.sp, color: AppColorsTheme.textMutedColor(context)),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.priceText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: primaryOrange.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'Min: @qty'.trParams({'qty': '${product.minQty}'}),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColorsTheme.textMutedColor(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      UIHelper.verticalSpace(8.h),
                      _AddToCartButton(product: product),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final ProductCardData product;
  final double radius;

  const _ProductImage({required this.product, required this.radius});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholder = Center(
      child: Icon(Icons.shopping_bag_outlined, color: primaryOrange, size: 32.sp),
    );
    final url = product.imageUrl;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
          child: Container(
            height: 120.h,
            width: double.infinity,
            color: primaryOrange.withValues(alpha: isDark ? 0.12 : 0.06),
            child: url == null || url.isEmpty
                ? placeholder
                : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder),
          ),
        ),
        if (product.isFeatured)
          Positioned(
            top: 8.h,
            left: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [primaryOrange, secondaryOrange]),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, size: 10.sp, color: Colors.white),
                  UIHelper.horizontalSpace(2.w),
                  Text(
                    'FEATURED'.tr,
                    style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Orange gradient button that turns green with a check for a moment after adding.
class _AddToCartButton extends StatefulWidget {
  final ProductCardData product;

  const _AddToCartButton({required this.product});

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton> {
  static const Duration _addedFeedback = Duration(milliseconds: 1500);
  bool _added = false;

  Future<void> _addToCart() async {
    final product = widget.product;
    final cart = context.read<CartProvider>();
    setState(() => _added = true);

    // Add to the server cart once, then mirror locally. (CartProvider.addToCart
    // also calls addItemToCart, so calling both would add the item twice.)
    final slug = product.slug;
    if (slug != null && slug.isNotEmpty) {
      final added = await cart.addItemToCart(productSlug: slug, quantity: product.minQty);
      if (!added) {
        // addItemToCart already showed the error toast.
        if (mounted) setState(() => _added = false);
        return;
      }
      cart.addToLocalCart(product.model, quantity: product.minQty);
    } else {
      await cart.addToCart(product.model, quantity: product.minQty);
    }
    ToastUtil.showSuccessMessage('@name added to cart'.trParams({'name': product.name}));

    await Future.delayed(_addedFeedback);
    if (mounted) setState(() => _added = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = _added ? const [successGreen, successGreenDark] : const [primaryOrange, secondaryOrange];

    return GestureDetector(
      onTap: _added ? null : _addToCart,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 38.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(color: colors.first.withValues(alpha: 0.3), blurRadius: 6.r, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _added ? Icons.check_rounded : Icons.add_shopping_cart_rounded,
              color: Colors.white,
              size: 15.sp,
            ),
            UIHelper.horizontalSpace(5.w),
            Text(
              (_added ? 'Added' : 'Add to cart').tr,
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
