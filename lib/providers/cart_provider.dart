import 'package:flutter/material.dart';
import '../feature/dashboard/model/my_product_model.dart';

class CartItemModel {
  final ProductItemModel product;
  int quantity;

  CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  double get unitPrice {
    final formattedPrice = product.wholesale?.price?.formatted ?? '৳ 15.00';
    final numeric = formattedPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(numeric) ?? 15.0;
  }

  double get totalPrice => unitPrice * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _cartItems = [];

  List<CartItemModel> get cartItems => List.unmodifiable(_cartItems);

  int get totalItemsCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get deliveryFee => _cartItems.isEmpty ? 0.0 : 60.0;

  double get grandTotal => subtotal + deliveryFee;

  void addToCart(ProductItemModel product, {int quantity = 10}) {
    final existingIndex = _cartItems.indexWhere((item) => item.product.name == product.name);
    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItemModel(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _cartItems.length) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
