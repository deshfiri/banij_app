import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/toast.dart';
import '../../../providers/cart_provider.dart';
import 'widgets/commerce/cart_widgets.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<CartProvider>().fetchCart();
      } catch (_) {}
    });
  }

  void _confirmClearCart() {
    showDialog(
      context: context,
      builder: (_) => ClearCartDialog(
        hostContext: context,
        onConfirm: () {
          context.read<CartProvider>().clearCart();
          ToastUtil.showSuccessMessage('Cart cleared');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cartLines = cartProvider.cartLines;
    final localItems = cartProvider.localCartItems;
    final isCartEmpty = cartLines.isEmpty && localItems.isEmpty;

    final Widget body;
    if (cartProvider.isLoading) {
      body = const CartShimmer();
    } else if (isCartEmpty) {
      body = CartEmptyState(onBrowse: () => Navigator.pop(context));
    } else {
      body = Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  itemCount: cartLines.isNotEmpty
                      ? cartLines.length
                      : localItems.length,
                  itemBuilder: (context, index) => cartLines.isNotEmpty
                      ? _serverLineCard(context, index)
                      : _localItemCard(context, index),
                ),
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: CartSummaryPanel(
                itemCount: cartProvider.totalItemsCount,
                subtotalText: cartProvider.formattedSubtotal,
                deliveryFee: cartProvider.deliveryFee,
                grandTotalText: cartProvider.formattedGrandTotal,
                onCheckout: () =>
                    Navigator.pushNamed(context, Routes.orderNowScreen),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: Column(
        children: [
          _CartHeader(
            itemCount: cartProvider.totalItemsCount,
            isEmpty: isCartEmpty,
            isLoading: cartProvider.isLoading,
            onBack: () => Navigator.pop(context),
            onClear: _confirmClearCart,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  /// Server cart line (quantity changes go through the cart API).
  Widget _serverLineCard(BuildContext context, int index) {
    final cart = context.read<CartProvider>();
    final line = cart.cartLines[index];
    final product = line.product;
    final quantity = line.quantity ?? 1;

    void changeQuantity(int newQuantity) {
      if (line.id != null && product?.slug != null) {
        cart.updateLineQuantity(
          lineItemId: line.id!,
          productSlug: product!.slug!,
          variantSku: line.variant?.sku,
          newQuantity: newQuantity,
        );
      }
    }

    return CartItemCard(
      imageUrl: product?.image?.url ?? '',
      title: product?.name ?? '',
      priceText: line.lineTotal?.formatted ?? line.unitPrice?.formatted ?? '',
      quantity: quantity,
      onRemove: () {
        if (line.id != null) {
          cart.deleteLineItem(line.id!);
          ToastUtil.showSuccessMessage('Item removed from cart');
        }
      },
      onDecrement: () => changeQuantity(quantity - 1),
      onIncrement: () => changeQuantity(quantity + 1),
    );
  }

  /// Local (not yet synced) cart item.
  Widget _localItemCard(BuildContext context, int index) {
    final cart = context.read<CartProvider>();
    final item = cart.localCartItems[index];
    final product = item.product;
    final quantity = item.quantity;

    return CartItemCard(
      imageUrl: product.image?.url ?? '',
      title: product.name ?? 'Product Item',
      priceText: '৳ ${item.totalPrice.toStringAsFixed(2)}',
      quantity: quantity,
      onRemove: () {
        cart.removeFromLocalCart(index);
        ToastUtil.showSuccessMessage('Item removed from cart');
      },
      onDecrement: () => cart.updateLocalQuantity(index, quantity - 1),
      onIncrement: () => cart.updateLocalQuantity(index, quantity + 1),
    );
  }
}

class _CartHeader extends StatelessWidget {
  final int itemCount;
  final bool isEmpty;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onClear;

  const _CartHeader({
    required this.itemCount,
    required this.isEmpty,
    required this.isLoading,
    required this.onBack,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w900,
      color: Colors.white,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColorsTheme.heroGradient(context),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.18
                  : 0.2,
            ),
            blurRadius: 16.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 4.h, 16.w, 18.h),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: onBack,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.16),
                      foregroundColor: Colors.white,
                    ),
                    icon: Icon(Icons.arrow_back_rounded, size: 21.sp),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('My Cart'.tr, style: titleStyle),
                        SizedBox(height: 3.h),
                        Text(
                          isLoading
                              ? 'Loading your cart...'.tr
                              : isEmpty
                              ? 'Your Cart is Empty'.tr
                              : '$itemCount items',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.86),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isEmpty && !isLoading) ...[
                    SizedBox(width: 8.w),
                    Material(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14.r),
                      child: InkWell(
                        onTap: onClear,
                        borderRadius: BorderRadius.circular(14.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 11.w,
                            vertical: 9.h,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 17.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                'Clear'.tr,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
