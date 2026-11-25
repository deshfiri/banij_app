import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/my_product_model.dart';

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
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

/// Product image with optional category and featured tags.
class ProductHeroImage extends StatelessWidget {
  final String? imageUrl;
  final String? imageAlt;
  final String? categoryName;
  final bool isFeatured;

  const ProductHeroImage({
    super.key,
    required this.imageUrl,
    required this.imageAlt,
    required this.categoryName,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final image = imageUrl?.trim();
    final category = categoryName?.trim();

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
            child: image == null || image.isEmpty
                ? _ProductImagePlaceholder()
                : Semantics(
                    label: imageAlt,
                    image: true,
                    child: CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _ProductImagePlaceholder(),
                    ),
                  ),
          ),
        ),
        if (category != null && category.isNotEmpty)
          Positioned(
            top: 12.h,
            left: 12.w,
            right: isFeatured ? 88.w : 12.w,
            child: Align(
              alignment: Alignment.topLeft,
              child: ProductInfoBadge.tinted(
                icon: Icons.category_outlined,
                label: category,
                color: primaryOrange,
              ),
            ),
          ),
        if (isFeatured)
          Positioned(
            top: 12.h,
            right: 12.w,
            child: ProductInfoBadge.tinted(
              icon: Icons.star_rounded,
              label: 'Featured'.tr,
              color: warningYellow,
            ),
          ),
      ],
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorsTheme.innerCardBg(context),
      alignment: Alignment.center,
      child: Icon(
        Icons.inventory_2_outlined,
        size: 56.sp,
        color: primaryOrange.withValues(alpha: 0.7),
      ),
    );
  }
}

/// Rounded card used for product pricing and availability details.
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

/// Displays only pricing, stock, and order limits supplied by the product.
class ProductPriceStockCard extends StatelessWidget {
  final ProductItemModel product;

  const ProductPriceStockCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final wholesale = product.wholesale;
    final partner = product.partnerSelling;
    final stock = wholesale?.inStock?.trim();
    final stockCount = int.tryParse(stock ?? '');
    final stockColor = stockCount == null
        ? AppColorsTheme.textMutedColor(context)
        : stockCount > 0
            ? successGreen
            : errorRed;
    final prices = <(String, PriceModel?)>[
      ('Wholesale price'.tr, wholesale?.price),
      ('Suggested selling price'.tr, partner?.suggestedSellingPrice),
      ('Minimum selling price'.tr, partner?.minimumSellingPrice),
      ('Maximum selling price'.tr, partner?.maximumSellingPrice),
    ].where((entry) => _priceText(entry.$2) != null).toList();
    final hasStock = stock != null && stock.isNotEmpty;
    final minOrder = wholesale?.minOrderQuantity;
    final maxOrder = wholesale?.maxOrderQuantity;
    final rangeText = _orderRangeText(minOrder, maxOrder);

    if (prices.isEmpty && !hasStock && rangeText == null) {
      return const SizedBox.shrink();
    }

    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < prices.length; index++) ...[
            if (index > 0) UIHelper.verticalSpace(14.h),
            Text(
              prices[index].$1,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              _priceText(prices[index].$2)!,
              style: TextStyle(
                fontSize: index == 0 ? 26.sp : 18.sp,
                fontWeight: FontWeight.w900,
                color: index == 0 ? primaryOrange : AppColorsTheme.textMainColor(context),
              ),
            ),
          ],
          if (hasStock) ...[
            if (prices.isNotEmpty) UIHelper.verticalSpace(16.h),
            Text(
              'Stock'.tr,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(
                  stockCount != null && stockCount <= 0
                      ? Icons.remove_circle_outline
                      : Icons.inventory_2_outlined,
                  size: 17.sp,
                  color: stockColor,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    stockCount == null
                        ? stock
                        : '$stock ${'available to order'.tr}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: stockColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (rangeText != null) ...[
            if (prices.isNotEmpty || hasStock) ...[
              SizedBox(height: 14.h),
              Divider(color: AppColorsTheme.borderColor(context)),
            ],
            SizedBox(height: 4.h),
            Text(
              'Order quantity'.tr,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              rangeText,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String? _priceText(PriceModel? price) {
    final formatted = price?.formatted?.trim();
    if (formatted != null && formatted.isNotEmpty) return formatted;
    final amount = price?.amount?.trim();
    if (amount == null || amount.isEmpty) return null;
    final currency = price?.currency?.trim();
    return currency == null || currency.isEmpty ? amount : '$currency $amount';
  }

  static String? _orderRangeText(int? min, int? max) {
    if (min != null && max != null) {
      return 'Between @min and @max units'.trParams({
        'min': '$min',
        'max': '$max',
      });
    }
    if (min != null) return 'Minimum order: @min units'.trParams({'min': '$min'});
    if (max != null) return 'Maximum order: @max units'.trParams({'max': '$max'});
    return null;
  }
}

/// "Order this product" card: quantity stepper + Order now / Add to cart / View cart.
class ProductOrderCard extends StatelessWidget {
  final TextEditingController quantityController;
  final int? minOrderQuantity;
  final int? maxOrderQuantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onQuantitySubmitted;
  final VoidCallback onOrderNow;
  final VoidCallback onAddToCart;
  final VoidCallback onViewCart;

  const ProductOrderCard({
    super.key,
    required this.quantityController,
    required this.minOrderQuantity,
    required this.maxOrderQuantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.onQuantitySubmitted,
    required this.onOrderNow,
    required this.onAddToCart,
    required this.onViewCart,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = AppColorsTheme.textMainColor(context);
    final mutedColor = AppColorsTheme.textMutedColor(context);
    final rangeText = ProductPriceStockCard._orderRangeText(
      minOrderQuantity,
      maxOrderQuantity,
    );
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
            'Order this product'.tr,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: mainColor),
          ),
          UIHelper.verticalSpace(12.h),
          Text(
            'Quantity to order'.tr,
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () {
                      onQuantitySubmitted();
                      FocusScope.of(context).unfocus();
                    },
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
          if (rangeText != null) ...[
            UIHelper.verticalSpace(6.h),
            Text(rangeText, style: TextStyle(fontSize: 11.sp, color: mutedColor)),
          ],
          UIHelper.verticalSpace(20.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: onOrderNow,
                icon: Icon(Icons.bolt_rounded, size: 16.sp),
                label: Text('Order now'.tr, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
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
                label: Text('Add to cart'.tr, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColorsTheme.cardBg(context),
                  foregroundColor: mainColor,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  side: BorderSide(color: AppColorsTheme.borderColor(context)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
              GestureDetector(
                onTap: onViewCart,
                child: Text(
                  'View cart'.tr,
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
