import 'package:flutter/material.dart';
import '../feature/dashboard/model/my_product_model.dart';
import '../feature/dashboard/model/wholesale_cart_model.dart';
import '../networks/api_access.dart';

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
  final List<CartItemModel> _localCartItems = [];
  WholesaleCartModel? _cartModel;
  bool _isLoading = false;

  CartProvider() {
    fetchCart();
  }

  List<CartItemModel> get cartItems => List.unmodifiable(_localCartItems);
  List<CartItemModel> get localCartItems => List.unmodifiable(_localCartItems);
  WholesaleCartModel? get cartModel => _cartModel;
  bool get isLoading => _isLoading;

  List<WholesaleCartLine> get cartLines => _cartModel?.data?.lines ?? [];

  int get totalItemsCount {
    if (_cartModel?.data?.lines != null && _cartModel!.data!.lines!.isNotEmpty) {
      return _cartModel!.data!.lines!.fold(0, (sum, line) => sum + (line.quantity ?? 0));
    }
    return _localCartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotalNumeric {
    if (_cartModel?.data?.lines != null && _cartModel!.data!.lines!.isNotEmpty) {
      double sum = 0.0;
      for (var line in _cartModel!.data!.lines!) {
        if (line.lineTotal?.amount != null) {
          sum += double.tryParse(line.lineTotal!.amount!) ?? 0.0;
        } else if (line.unitPrice?.amount != null) {
          final unit = double.tryParse(line.unitPrice!.amount!) ?? 0.0;
          sum += unit * (line.quantity ?? 1);
        }
      }
      return sum;
    }
    if (_cartModel?.data?.subtotal?.amount != null) {
      return double.tryParse(_cartModel!.data!.subtotal!.amount!) ?? 0.0;
    }
    return _localCartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  String get formattedSubtotal {
    if (_cartModel?.data?.lines != null && _cartModel!.data!.lines!.isNotEmpty) {
      return '৳ ${subtotalNumeric.toStringAsFixed(2)}';
    }
    if (_cartModel?.data?.subtotal?.formatted != null) {
      return _cartModel!.data!.subtotal!.formatted!;
    }
    final sub = _localCartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    return '৳ ${sub.toStringAsFixed(2)}';
  }

  double get subtotal => subtotalNumeric;

  double get deliveryFee => 0.0;

  double get grandTotalNumeric => subtotalNumeric;

  String get formattedGrandTotal {
    return formattedSubtotal;
  }

  Future<void> fetchCart({bool showLoading = false}) async {
    if (showLoading || (_cartModel == null && _localCartItems.isEmpty)) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final model = await wholesaleCartRxObj.fetchCart();
      _cartModel = model;
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItemToCart({
    required String productSlug,
    String? variantSku,
    int quantity = 1,
  }) async {
    try {
      final body = {
        "product": productSlug,
        if (variantSku != null && variantSku.isNotEmpty) "variant": variantSku,
        "quantity": quantity,
      };
      final model = await wholesaleCartRxObj.addCartItem(body);
      _cartModel = model;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> updateLineQuantity({
    required String lineItemId,
    required String productSlug,
    String? variantSku,
    required int newQuantity,
  }) async {
    if (newQuantity <= 0) {
      await deleteLineItem(lineItemId);
      return;
    }

    // 1. Optimistic local quantity and lineTotal update
    if (_cartModel?.data?.lines != null) {
      final index = _cartModel!.data!.lines!.indexWhere((line) => line.id == lineItemId);
      if (index != -1) {
        final oldLine = _cartModel!.data!.lines![index];
        final unitAmount = double.tryParse(oldLine.unitPrice?.amount ?? '0') ?? 0.0;
        final newLineTotalAmount = (unitAmount * newQuantity).toStringAsFixed(2);

        _cartModel!.data!.lines![index] = WholesaleCartLine(
          id: oldLine.id,
          product: oldLine.product,
          variant: oldLine.variant,
          quantity: newQuantity,
          minOrderQuantity: oldLine.minOrderQuantity,
          maxOrderQuantity: oldLine.maxOrderQuantity,
          available: oldLine.available,
          unitPrice: oldLine.unitPrice,
          basePrice: oldLine.basePrice,
          lineTotal: WholesalePrice(
            amount: newLineTotalAmount,
            currency: oldLine.lineTotal?.currency ?? 'BDT',
            formatted: '৳ $newLineTotalAmount',
          ),
          unitPriceSeen: oldLine.unitPriceSeen,
          priceChanged: oldLine.priceChanged,
          problems: oldLine.problems,
          purchasable: oldLine.purchasable,
        );
        notifyListeners();
      }
    }

    // 2. Call backend API in background
    try {
      final body = {
        "product": productSlug,
        if (variantSku != null && variantSku.isNotEmpty) "variant": variantSku,
        "quantity": newQuantity,
      };
      final model = await wholesaleCartRxObj.updateCartItemQuantity(lineItemId, body);
      _cartModel = model;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> deleteLineItem(String lineItemId) async {
    // 1. Optimistic local line removal for instant price recalculation
    if (_cartModel?.data?.lines != null) {
      _cartModel!.data!.lines!.removeWhere((line) => line.id == lineItemId);
      notifyListeners();
    }

    // 2. Call backend API in background and sync response
    try {
      final model = await wholesaleCartRxObj.deleteCartItem(lineItemId);
      _cartModel = model;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> acceptPrices() async {
    try {
      final model = await wholesaleCartRxObj.acceptCartPrices();
      _cartModel = model;
      notifyListeners();
    } catch (_) {}
  }

  void addToCart(ProductItemModel product, {int quantity = 1}) {
    addToLocalCart(product, quantity: quantity);

    final slug = product.slug ?? product.name;
    if (slug != null && slug.isNotEmpty) {
      addItemToCart(
        productSlug: slug,
        quantity: quantity,
      );
    }
  }

  void addToLocalCart(ProductItemModel product, {int quantity = 1}) {
    final existingIndex = _localCartItems.indexWhere((item) => item.product.name == product.name);
    if (existingIndex != -1) {
      _localCartItems[existingIndex].quantity += quantity;
    } else {
      _localCartItems.add(CartItemModel(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    updateLocalQuantity(index, newQuantity);
  }

  void updateLocalQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _localCartItems.length) {
      if (newQuantity <= 0) {
        _localCartItems.removeAt(index);
      } else {
        _localCartItems[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void removeFromCart(int index) {
    removeFromLocalCart(index);
  }

  void removeFromLocalCart(int index) {
    if (index >= 0 && index < _localCartItems.length) {
      _localCartItems.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    _localCartItems.clear();
    _cartModel = null;
    notifyListeners();
  }
}
