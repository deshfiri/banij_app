import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../providers/cart_provider.dart';

/// Small rounded pill with an icon and label.
class ProductInfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;

  const ProductInfoBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
  });

  /// Badge tinted from a single accent colour (15% fill, 30% border).
  ProductInfoBadge.tinted({super.key, required this.icon, required this.label, required Color color})
      : bgColor = color.withValues(alpha: 0.15),
        textColor = color,
        borderColor = color.withValues(alpha: 0.3);

  @override
  Widget build(BuildContext context) {
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
          Text(label, style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }
}

/// App bar cart icon with the item-count badge.
class ProductCartAction extends StatelessWidget {
  final VoidCallback onTap;

  const ProductCartAction({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final count = context.select<CartProvider, int>((cart) => cart.totalItemsCount);

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.shopping_bag_outlined, color: AppColorsTheme.textMainColor(context)),
          onPressed: onTap,
        ),
        Positioned(
          right: 8.w,
          top: 8.h,
          child: count == 0
              ? const SizedBox.shrink()
              : Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(color: primaryOrange, shape: BoxShape.circle),
                  constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.h),
                  child: Text(
                    '$count',
                    style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
      ],
    );
  }
}

/// Large product image with the green category tag in the corner.
class ProductHeroImage extends StatelessWidget {
  final String imageUrl;
  final String categoryName;

  const ProductHeroImage({super.key, required this.imageUrl, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 220.h,
          decoration: BoxDecoration(
            color: AppColorsTheme.cardBg(context),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColorsTheme.borderColor(context), width: 1.w),
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
                return Center(child: Icon(Icons.inventory_2_outlined, size: 64.sp, color: primaryOrange));
              },
            ),
          ),
        ),
        Positioned(
          top: 12.h,
          left: 12.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: successGreen,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6.r)],
            ),
            child: Text(
              categoryName.toUpperCase(),
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}

/// White rounded card used for the price/stock and order sections.
class ProductSectionCard extends StatelessWidget {
  final Widget child;

  const ProductSectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColorsTheme.borderColor(context), width: 1.w),
      ),
      child: child,
    );
  }
}

/// Wholesale price, stock status and order-quantity range.
class ProductPriceStockCard extends StatelessWidget {
  final String wholesalePrice;
  final String availableStock;

  const ProductPriceStockCard({super.key, required this.wholesalePrice, required this.availableStock});

  @override
  Widget build(BuildContext context) {
    final mutedLabel = TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: AppColorsTheme.textMutedColor(context),
    );
    final mainColor = AppColorsTheme.textMainColor(context);

    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wholesale price', style: mutedLabel),
          UIHelper.verticalSpace(4.h),
          Text(
            wholesalePrice,
            style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w900, color: primaryOrange),
          ),
          UIHelper.verticalSpace(16.h),
          Text('Stock', style: mutedLabel),
          UIHelper.verticalSpace(6.h),
          Row(
            children: [
              ProductInfoBadge.tinted(icon: Icons.check_circle_outline_rounded, label: 'In stock', color: successGreen),
              UIHelper.horizontalSpace(8.w),
              Text(
                '$availableStock available to order',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: mainColor),
              ),
            ],
          ),
          UIHelper.verticalSpace(14.h),
          Text('Order quantity', style: mutedLabel),
          UIHelper.verticalSpace(4.h),
          Text(
            'Between 10 and 28 units in one order',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: mainColor),
          ),
        ],
      ),
    );
  }
}

/// "Order this product" card: quantity stepper + Order now / Add to cart / View cart.
class ProductOrderCard extends StatelessWidget {
  static const Color _darkOutlinedFill = Color(0xFF1E1E1E);

  final TextEditingController quantityController;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onOrderNow;
  final VoidCallback onAddToCart;
  final VoidCallback onViewCart;

  const ProductOrderCard({
    super.key,
    required this.quantityController,
    required this.onDecrement,
    required this.onIncrement,
    required this.onOrderNow,
    required this.onAddToCart,
    required this.onViewCart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainColor = AppColorsTheme.textMainColor(context);
    final mutedColor = AppColorsTheme.textMutedColor(context);
    final fieldDecoration = BoxDecoration(
      color: AppColorsTheme.background(context),
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: AppColorsTheme.borderColor(context)),
    );

    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order this product',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: mainColor),
          ),
          UIHelper.verticalSpace(4.h),
          Text(
            'Buy in bulk for yourself, receive the goods, and resell them wherever you sell.',
            style: TextStyle(fontSize: 12.sp, color: mutedColor, height: 1.3),
          ),
          UIHelper.verticalSpace(14.h),
          Divider(color: AppColorsTheme.borderColor(context)),
          UIHelper.verticalSpace(12.h),
          Text(
            'WHAT YOU ARE BUYING',
            style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w800, color: mutedColor, letterSpacing: 0.8),
          ),
          UIHelper.verticalSpace(6.h),
          Text(
            'Quantity to order',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: mainColor),
          ),
          UIHelper.verticalSpace(8.h),
          Row(
            children: [
              _StepButton(icon: Icons.remove_rounded, decoration: fieldDecoration, onTap: onDecrement),
              UIHelper.horizontalSpace(8.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: fieldDecoration,
                  child: TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: mainColor),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
              ),
              UIHelper.horizontalSpace(8.w),
              _StepButton(icon: Icons.add_rounded, decoration: fieldDecoration, onTap: onIncrement),
            ],
          ),
          UIHelper.verticalSpace(6.h),
          Text('Between 10 and 28', style: TextStyle(fontSize: 11.sp, color: mutedColor)),
          UIHelper.verticalSpace(20.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: onOrderNow,
                icon: Icon(Icons.bolt_rounded, size: 16.sp),
                label: Text('Order now', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  elevation: 0,
                ),
              ),
              OutlinedButton.icon(
                onPressed: onAddToCart,
                icon: Icon(Icons.shopping_bag_outlined, size: 16.sp),
                label: Text('Add to cart', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isDark ? _darkOutlinedFill : Colors.white,
                  foregroundColor: mainColor,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  side: BorderSide(color: AppColorsTheme.borderColor(context)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
              GestureDetector(
                onTap: onViewCart,
                child: Text(
                  'View cart',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: mainColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(14.h),
          Text(
            'Order now goes straight to checkout, where you choose how to pay. Add to cart keeps the item for later.',
            style: TextStyle(fontSize: 11.sp, color: mutedColor, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final BoxDecoration decoration;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.decoration, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: decoration,
        child: Icon(icon, size: 18.sp, color: AppColorsTheme.textMainColor(context)),
      ),
    );
  }
}
