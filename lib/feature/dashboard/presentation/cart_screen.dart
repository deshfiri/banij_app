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
  static const String _placeholderImage = 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500';

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
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: cartLines.isNotEmpty ? cartLines.length : localItems.length,
              itemBuilder: (context, index) =>
                  cartLines.isNotEmpty ? _serverLineCard(context, index) : _localItemCard(context, index),
            ),
          ),
          CartSummaryPanel(
            itemCount: cartProvider.totalItemsCount,
            subtotalText: cartProvider.formattedSubtotal,
            deliveryFee: cartProvider.deliveryFee,
            grandTotalText: cartProvider.formattedGrandTotal,
            onCheckout: () => Navigator.pushNamed(context, Routes.orderNowScreen),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppColorsTheme.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColorsTheme.textMainColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Cart'.tr,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
        ),
        actions: [
          if (!isCartEmpty)
            TextButton.icon(
              onPressed: _confirmClearCart,
              icon: Icon(Icons.delete_outline_rounded, size: 16.sp, color: Colors.redAccent),
              label: Text(
                'Clear',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
            ),
        ],
      ),
      body: body,
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
      imageUrl: (product.image?.url != null && product.image!.url!.isNotEmpty) ? product.image!.url! : _placeholderImage,
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
