import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartProvider = context.watch<CartProvider>();
    final cartItems = cartProvider.cartItems;

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
          'My Cart'.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColorsTheme.cardBg(context),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    title: Text(
                      'Clear Cart',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to remove all items from your cart?',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColorsTheme.textMutedColor(context),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: AppColorsTheme.textMutedColor(context)),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                        onPressed: () {
                          cartProvider.clearCart();
                          Navigator.pop(ctx);
                          ToastUtil.showSuccessMessage('Cart cleared');
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.delete_outline_rounded, size: 16.sp, color: Colors.redAccent),
              label: Text(
                'Clear',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
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
                      child: Icon(
                        Icons.shopping_basket_outlined,
                        size: 64.sp,
                        color: primaryOrange,
                      ),
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
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColorsTheme.textMutedColor(context),
                        height: 1.4,
                      ),
                    ),
                    UIHelper.verticalSpace(24.h),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.explore_rounded, size: 18.sp),
                      label: Text(
                        'Browse Products',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final product = item.product;
                      final imageUrl = (product.image?.url != null && product.image!.url!.isNotEmpty)
                          ? product.image!.url!
                          : 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500';
                      final title = product.name ?? 'Product Item';
                      final category = product.category ?? 'WHOLESALE';

                      return Container(
                        margin: EdgeInsets.only(bottom: 14.h),
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColorsTheme.cardBg(context),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColorsTheme.borderColor(context),
                            width: 1.w,
                          ),
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
                                          style: TextStyle(
                                            fontSize: 13.5.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColorsTheme.textMainColor(context),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          cartProvider.removeFromCart(index);
                                          ToastUtil.showSuccessMessage('Item removed from cart');
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 8.w),
                                          child: Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18.sp,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  UIHelper.verticalSpace(4.h),
                                  Text(
                                    category.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                  UIHelper.verticalSpace(8.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '৳ ${item.totalPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w900,
                                          color: primaryOrange,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () => cartProvider.updateQuantity(index, item.quantity - 1),
                                            child: Container(
                                              padding: EdgeInsets.all(5.w),
                                              decoration: BoxDecoration(
                                                color: AppColorsTheme.background(context),
                                                borderRadius: BorderRadius.circular(6.r),
                                                border: Border.all(color: AppColorsTheme.borderColor(context)),
                                              ),
                                              child: Icon(Icons.remove_rounded, size: 14.sp, color: AppColorsTheme.textMainColor(context)),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                                            child: Text(
                                              '${item.quantity}',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                                color: AppColorsTheme.textMainColor(context),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => cartProvider.updateQuantity(index, item.quantity + 1),
                                            child: Container(
                                              padding: EdgeInsets.all(5.w),
                                              decoration: BoxDecoration(
                                                color: AppColorsTheme.background(context),
                                                borderRadius: BorderRadius.circular(6.r),
                                                border: Border.all(color: AppColorsTheme.borderColor(context)),
                                              ),
                                              child: Icon(Icons.add_rounded, size: 14.sp, color: AppColorsTheme.textMainColor(context)),
                                            ),
                                          ),
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
                    },
                  ),
                ),

                // Cart Summary Bottom Card
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColorsTheme.cardBg(context),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                    ),
                    border: Border(
                      top: BorderSide(color: AppColorsTheme.borderColor(context)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16.r,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal (${cartProvider.totalItemsCount} items)',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColorsTheme.textMutedColor(context),
                            ),
                          ),
                          Text(
                            '৳ ${cartProvider.subtotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          ),
                        ],
                      ),
                      UIHelper.verticalSpace(8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delivery Fee',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColorsTheme.textMutedColor(context),
                            ),
                          ),
                          Text(
                            '৳ ${cartProvider.deliveryFee.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          ),
                        ],
                      ),
                      UIHelper.verticalSpace(12.h),
                      Divider(color: AppColorsTheme.borderColor(context)),
                      UIHelper.verticalSpace(10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Grand Total',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          ),
                          Text(
                            '৳ ${cartProvider.grandTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w900,
                              color: primaryOrange,
                            ),
                          ),
                        ],
                      ),
                      UIHelper.verticalSpace(16.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.orderNowScreen);
                          },
                          icon: Icon(Icons.bolt_rounded, size: 18.sp),
                          label: Text(
                            'Proceed to Checkout',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryOrange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
