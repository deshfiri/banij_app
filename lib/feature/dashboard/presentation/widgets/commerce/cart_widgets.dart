import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../checkout/checkout_shimmer.dart';

/// Cart row: image, title + delete, "WHOLESALE" tag, price and − qty + stepper.
/// Used for both server cart lines and local cart items.
class CartItemCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String priceText;
  final int quantity;
  final VoidCallback onRemove;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const CartItemCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.priceText,
    required this.quantity,
    required this.onRemove,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainColor = AppColorsTheme.textMainColor(context);

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColorsTheme.borderColor(context), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: 64.w,
              height: 64.h,
              color: primaryOrange.withValues(alpha: 0.1),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(Icons.inventory_2_outlined, color: primaryOrange, size: 24.sp),
                ),
              ),
            ),
          ),
          UIHelper.horizontalSpace(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w700, color: mainColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: onRemove,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: Icon(Icons.delete_outline_rounded, size: 18.sp, color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
                UIHelper.verticalSpace(4.h),
                Text(
                  'WHOLESALE',
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: successGreen),
                ),
                UIHelper.verticalSpace(8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      priceText,
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                    ),
                    Row(
                      children: [
                        _QtyButton(icon: Icons.remove_rounded, onTap: onDecrement),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Text(
                            '$quantity',
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: mainColor),
                          ),
                        ),
                        _QtyButton(icon: Icons.add_rounded, onTap: onIncrement),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: AppColorsTheme.background(context),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: AppColorsTheme.borderColor(context)),
        ),
        child: Icon(icon, size: 14.sp, color: AppColorsTheme.textMainColor(context)),
      ),
    );
  }
}

/// "Your Cart is Empty" state with a "Browse Products" button.
class CartEmptyState extends StatelessWidget {
  final VoidCallback onBrowse;

  const CartEmptyState({super.key, required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                color: primaryOrange.withValues(alpha: isDark ? 0.15 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_bag_outlined, size: 64.sp, color: primaryOrange),
            ),
            UIHelper.verticalSpace(20.h),
            Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(8.h),
            Text(
              'Explore wholesale products and add items to your cart to start ordering.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context), height: 1.4),
            ),
            UIHelper.verticalSpace(24.h),
            ElevatedButton.icon(
              onPressed: onBrowse,
              icon: Icon(Icons.explore_rounded, size: 18.sp),
              label: Text('Browse Products', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom panel: subtotal, optional delivery fee, grand total, checkout button.
class CartSummaryPanel extends StatelessWidget {
  final int itemCount;
  final String subtotalText;
  final double deliveryFee;
  final String grandTotalText;
  final VoidCallback onCheckout;

  const CartSummaryPanel({
    super.key,
    required this.itemCount,
    required this.subtotalText,
    required this.deliveryFee,
    required this.grandTotalText,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainColor = AppColorsTheme.textMainColor(context);
    final labelStyle = TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context));
    final valueStyle = TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: mainColor);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12.r,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal ($itemCount items)', style: labelStyle),
              Text(subtotalText, style: valueStyle),
            ],
          ),
          if (deliveryFee > 0) ...[
            UIHelper.verticalSpace(8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delivery Fee', style: labelStyle),
                Text('৳ ${deliveryFee.toStringAsFixed(2)}', style: valueStyle),
              ],
            ),
          ],
          UIHelper.verticalSpace(12.h),
          Divider(color: AppColorsTheme.borderColor(context)),
          UIHelper.verticalSpace(8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grand Total', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: mainColor)),
              Text(
                grandTotalText,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: primaryOrange),
              ),
            ],
          ),
          UIHelper.verticalSpace(16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCheckout,
              icon: Icon(Icons.bolt_rounded, size: 18.sp),
              label: Text('Proceed to Checkout', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Clear Cart" confirmation; [onConfirm] runs before the dialog closes.
class ClearCartDialog extends StatelessWidget {
  final BuildContext hostContext;
  final VoidCallback onConfirm;

  const ClearCartDialog({super.key, required this.hostContext, required this.onConfirm});

  @override
  Widget build(BuildContext ctx) {
    final context = hostContext;

    return AlertDialog(
      backgroundColor: AppColorsTheme.cardBg(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(
        'Clear Cart',
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
      ),
      content: Text(
        'Are you sure you want to remove all items from your cart?',
        style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel', style: TextStyle(color: AppColorsTheme.textMutedColor(context))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          onPressed: () {
            onConfirm();
            Navigator.pop(ctx);
          },
          child: const Text('Clear'),
        ),
      ],
    );
  }
}

/// Loading placeholder shaped like the cart list.
class CartShimmer extends StatelessWidget {
  const CartShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = CheckoutShimmerColors.of(context);

    return Shimmer.fromColors(
      baseColor: colors.base,
      highlightColor: colors.highlight,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 14.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
            child: Row(
              children: [
                Container(
                  width: 64.w,
                  height: 64.h,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
                ),
                UIHelper.horizontalSpace(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 140.w, height: 14.h, color: Colors.white),
                      UIHelper.verticalSpace(8.h),
                      Container(width: 80.w, height: 12.h, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
