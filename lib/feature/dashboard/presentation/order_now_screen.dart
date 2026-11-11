import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../../../providers/cart_provider.dart';
import '../model/address_model.dart';
import '../model/my_product_model.dart';
import '../model/payment_model.dart';

class OrderNowScreen extends StatefulWidget {
  final ProductItemModel? product;

  const OrderNowScreen({
    super.key,
    this.product,
  });

  @override
  State<OrderNowScreen> createState() => _OrderNowScreenState();
}

class _OrderNowScreenState extends State<OrderNowScreen> {
  int _quantity = 1;
  String _selectedPaymentMethod = 'PayPal';
  bool _isLoading = false;
  bool _isSummaryExpanded = false;

  bool _isLoadingPaymentMethods = true;
  PaymentMethodResponseModel? _paymentResponseModel;

  bool _isLoadingAddresses = true;
  AddressResponseModel? _addressResponseModel;
  AddressItemModel? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
    _fetchAddresses();
  }

  Future<void> _fetchPaymentMethods() async {
    setState(() {
      _isLoadingPaymentMethods = true;
    });
    try {
      _paymentResponseModel = await paymentRxObj.fetchPaymentMethods();
    } catch (_) {
      _paymentResponseModel = PaymentMethodResponseModel(data: []);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPaymentMethods = false;
        });
      }
    }
  }

  Future<void> _fetchAddresses() async {
    setState(() {
      _isLoadingAddresses = true;
    });
    try {
      _addressResponseModel = await addressRxObj.fetchAddresses();
      final addresses = _addressResponseModel?.data ?? [];
      if (addresses.isNotEmpty) {
        _selectedAddress = addresses.firstWhere(
          (a) => a.isDefault == true,
          orElse: () => addresses.first,
        );
      }
    } catch (_) {
      _addressResponseModel = AddressResponseModel(data: []);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAddresses = false;
        });
      }
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _placeOrder(CartProvider cartProvider) {
    if (_selectedAddress == null) {
      ToastUtil.showErrorMessage('Please add a shipping address first');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        cartProvider.clearCart();
        _showSuccessDialog(context);
      }
    });
  }

  void _showAddressSelectionSheet(BuildContext context) {
    final addresses = _addressResponseModel?.data ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsTheme.cardBg(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Shipping Address',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(14.h),
            if (addresses.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: Text(
                    'No saved addresses',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                ),
              )
            else
              ...addresses.map((addr) {
                final isSelected = _selectedAddress?.id == addr.id;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? primaryOrange : AppColorsTheme.textMutedColor(context),
                  ),
                  title: Text(
                    addr.recipientName ?? 'Address',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  subtitle: Text(
                    addr.fullAddressFormatted,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedAddress = addr;
                    });
                    Navigator.pop(ctx);
                  },
                );
              }),
            UIHelper.verticalSpace(14.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ToastUtil.showSuccessMessage('Opening Add Address dialog...');
                },
                icon: Icon(Icons.add, size: 18.sp),
                label: const Text('Add New Address'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryOrange,
                  side: BorderSide(color: primaryOrange),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppColorsTheme.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 54.sp,
                  color: const Color(0xFF10B981),
                ),
              ),
              UIHelper.verticalSpace(20.h),
              Text(
                'Order Placed Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
              UIHelper.verticalSpace(8.h),
              Text(
                'Your Trade Assurance order has been placed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColorsTheme.textMutedColor(context),
                  height: 1.4,
                ),
              ),
              UIHelper.verticalSpace(24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.dashboardScreen,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Back to Dashboard',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final product = widget.product;

    final imageUrl = (product?.image?.url != null && product!.image!.url!.isNotEmpty)
        ? product.image!.url!
        : (cartProvider.cartItems.isNotEmpty
            ? (cartProvider.cartItems.first.product.image?.url ?? '')
            : 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500');

    final productTitle = product?.name ??
        (cartProvider.cartItems.isNotEmpty
            ? (cartProvider.cartItems.first.product.name ?? 'Wholesale Product')
            : 'Wholesale Product');

    final double unitPriceNum = product != null
        ? (double.tryParse(product.wholesale?.price?.amount ?? '') ??
            (double.tryParse(product.wholesale?.price?.formatted?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '') ?? 0.0))
        : (cartProvider.cartItems.isNotEmpty ? cartProvider.subtotal : 0.0);

    final String productPrice = product?.wholesale?.price?.formatted ??
        (cartProvider.cartItems.isNotEmpty
            ? (cartProvider.cartItems.first.product.wholesale?.price?.formatted ?? '৳ ${unitPriceNum.toStringAsFixed(2)}')
            : '৳ ${unitPriceNum.toStringAsFixed(2)}');

    final minOrder = product?.wholesale?.minOrderQuantity ?? 1;
    final categoryVariant = product?.category ?? product?.brand ?? 'Standard Unit';

    final double shippingFee = cartProvider.deliveryFee > 0 ? cartProvider.deliveryFee : 60.0;
    final double itemSubtotal = unitPriceNum > 0 ? (unitPriceNum * _quantity) : (cartProvider.subtotal > 0 ? cartProvider.subtotal : 0.0);
    final double grandTotalBdt = itemSubtotal + shippingFee;
    final double grandTotalUsd = grandTotalBdt / 115.0;

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Checkout'.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            Row(
              children: [
                Text(
                  'Protected by ',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColorsTheme.textMutedColor(context),
                  ),
                ),
                Icon(Icons.shield_rounded, size: 12.sp, color: Colors.amber[700]),
                UIHelper.horizontalSpace(2.w),
                Text(
                  'Trade Assurance',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
                UIHelper.horizontalSpace(4.w),
                Icon(Icons.info_outline_rounded, size: 12.sp, color: AppColorsTheme.textMutedColor(context)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.headset_mic_outlined,
              color: AppColorsTheme.textMainColor(context),
            ),
            onPressed: () {
              ToastUtil.showSuccessMessage('Opening support...');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Address Section (API Data or Add Address Prompt)
              _isLoadingAddresses
                  ? _buildAddressShimmer(context)
                  : _selectedAddress != null
                      ? Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColorsTheme.cardBg(context),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: AppColorsTheme.borderColor(context)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on_rounded, color: primaryOrange, size: 20.sp),
                                  UIHelper.horizontalSpace(8.w),
                                  Expanded(
                                    child: Text(
                                      _selectedAddress!.recipientName ?? 'Shipping Address',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColorsTheme.textMainColor(context),
                                      ),
                                    ),
                                  ),
                                  if (_selectedAddress!.isDefault == true) ...[
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: primaryOrange.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Text(
                                        'DEFAULT',
                                        style: TextStyle(
                                          fontSize: 8.5.sp,
                                          fontWeight: FontWeight.bold,
                                          color: primaryOrange,
                                        ),
                                      ),
                                    ),
                                    UIHelper.horizontalSpace(8.w),
                                  ],
                                  GestureDetector(
                                    onTap: () => _showAddressSelectionSheet(context),
                                    child: Text(
                                      'Change',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: primaryOrange,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              UIHelper.verticalSpace(6.h),
                              if (_selectedAddress!.phone != null)
                                Text(
                                  _selectedAddress!.phone!,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColorsTheme.textMutedColor(context),
                                  ),
                                ),
                              UIHelper.verticalSpace(4.h),
                              Text(
                                _selectedAddress!.fullAddressFormatted,
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  color: AppColorsTheme.textMainColor(context),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GestureDetector(
                          onTap: () => _showAddressSelectionSheet(context),
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: AppColorsTheme.cardBg(context),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppColorsTheme.borderColor(context)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: primaryOrange.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.location_on_outlined, color: primaryOrange, size: 22.sp),
                                ),
                                UIHelper.horizontalSpace(12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Add address',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppColorsTheme.textMainColor(context),
                                        ),
                                      ),
                                      UIHelper.verticalSpace(2.h),
                                      Text(
                                        'Add your address for shipping options and more accurate costs.',
                                        style: TextStyle(
                                          fontSize: 11.5.sp,
                                          color: AppColorsTheme.textMutedColor(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: AppColorsTheme.textMutedColor(context)),
                              ],
                            ),
                          ),
                        ),
              UIHelper.verticalSpace(16.h),

              // 2. Guaranteed Delivery & Shipping Section
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColorsTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColorsTheme.borderColor(context)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Guaranteed delivery: Dec 12 - Jan 22',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          ),
                          UIHelper.verticalSpace(2.h),
                          Text(
                            '5% compensation if delivered late',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          UIHelper.verticalSpace(8.h),
                          Text(
                            'Shipping fee: BDT ${shippingFee.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          ),
                          UIHelper.verticalSpace(2.h),
                          Row(
                            children: [
                              Text(
                                'Incoterm DAP',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColorsTheme.textMutedColor(context),
                                ),
                              ),
                              UIHelper.horizontalSpace(4.w),
                              Icon(Icons.info_outline_rounded, size: 13.sp, color: AppColorsTheme.textMutedColor(context)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: AppColorsTheme.textMutedColor(context)),
                  ],
                ),
              ),
              UIHelper.verticalSpace(16.h),

              // 3. Product Preview Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColorsTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColorsTheme.borderColor(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image with variant tag
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Container(
                                width: 72.w,
                                height: 72.h,
                                color: primaryOrange.withValues(alpha: 0.1),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Icon(Icons.inventory_2_outlined, color: primaryOrange, size: 28.sp),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4.h,
                              left: 4.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  categoryVariant.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 8.5.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        UIHelper.horizontalSpace(12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productTitle,
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColorsTheme.textMainColor(context),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              UIHelper.verticalSpace(2.h),
                              Text(
                                'Min. order: $minOrder piece${minOrder > 1 ? "s" : ""}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColorsTheme.textMutedColor(context),
                                ),
                              ),
                              UIHelper.verticalSpace(8.h),
                              Text(
                                productPrice,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColorsTheme.textMainColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    UIHelper.verticalSpace(14.h),

                    // Quantity Stepper Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColorsTheme.borderColor(context)),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: _decrementQuantity,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  child: Icon(Icons.remove, size: 14.sp, color: AppColorsTheme.textMainColor(context)),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Text(
                                  '$_quantity',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColorsTheme.textMainColor(context),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: _incrementQuantity,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  child: Icon(Icons.add, size: 14.sp, color: AppColorsTheme.textMainColor(context)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    UIHelper.verticalSpace(10.h),
                    Divider(color: AppColorsTheme.borderColor(context)),
                    UIHelper.verticalSpace(8.h),

                    // Add note to supplier link
                    GestureDetector(
                      onTap: () {
                        ToastUtil.showSuccessMessage('Note dialog opened');
                      },
                      child: Text(
                        'Add note to supplier',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColorsTheme.textMainColor(context),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              UIHelper.verticalSpace(20.h),

              // 4. Payment Method Section
              Text(
                'Payment method',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
              UIHelper.verticalSpace(10.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColorsTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColorsTheme.borderColor(context)),
                ),
                child: _isLoadingPaymentMethods
                    ? _buildPaymentShimmer(context)
                    : Column(
                        children: _buildPaymentList(context),
                      ),
              ),
              UIHelper.verticalSpace(30.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
        decoration: BoxDecoration(
          color: AppColorsTheme.cardBg(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10.r,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(top: BorderSide(color: AppColorsTheme.borderColor(context))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Expandable Summary Header
            InkWell(
              onTap: () {
                setState(() {
                  _isSummaryExpanded = !_isSummaryExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                      UIHelper.horizontalSpace(8.w),
                      Text(
                        'USD ${grandTotalUsd.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isSummaryExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ],
              ),
            ),
            if (_isSummaryExpanded) ...[
              UIHelper.verticalSpace(10.h),
              Divider(color: AppColorsTheme.borderColor(context)),
              UIHelper.verticalSpace(8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Items Subtotal', style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context))),
                  Text('BDT ${itemSubtotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context))),
                ],
              ),
              UIHelper.verticalSpace(4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Shipping Fee', style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context))),
                  Text('BDT ${shippingFee.toStringAsFixed(2)}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context))),
                ],
              ),
            ],
            UIHelper.verticalSpace(12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _placeOrder(context.read<CartProvider>()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _selectedAddress != null ? 'Place Order' : 'Add address',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: double.infinity,
        height: 80.h,
        decoration: BoxDecoration(
          color: AppColorsTheme.cardBg(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColorsTheme.borderColor(context)),
        ),
      ),
    );
  }

  List<Widget> _buildPaymentList(BuildContext context) {
    final apiTypes = _paymentResponseModel?.types ?? [];
    final apiData = _paymentResponseModel?.data ?? [];

    List<Widget> list = [];

    if (apiTypes.isNotEmpty) {
      for (int i = 0; i < apiTypes.length; i++) {
        final type = apiTypes[i];
        final label = type.label ?? type.value ?? 'Payment Option';
        final val = type.value ?? label;

        if (i > 0) list.add(Divider(height: 1, color: AppColorsTheme.borderColor(context)));
        list.add(
          _buildPaymentOption(
            context: context,
            title: label,
            subtitleText: type.fields != null && type.fields!.isNotEmpty
                ? 'Fields: ${type.fields!.join(", ")}'
                : null,
            icon: _getPaymentIcon(val),
            value: val,
          ),
        );
      }
    } else if (apiData.isNotEmpty) {
      for (int i = 0; i < apiData.length; i++) {
        final method = apiData[i];
        final name = method.name ?? 'Payment Option';
        final desc = method.description;
        final val = method.code ?? method.id ?? name;

        if (i > 0) list.add(Divider(height: 1, color: AppColorsTheme.borderColor(context)));
        list.add(
          _buildPaymentOption(
            context: context,
            title: name,
            subtitleText: desc,
            icon: _getPaymentIcon(val),
            value: val,
          ),
        );
      }
    } else {
      list.addAll([
        _buildPaymentOption(
          context: context,
          title: 'PayPal',
          subtitleText: null,
          icon: Icons.payment_rounded,
          value: 'PayPal',
        ),
        Divider(height: 1, color: AppColorsTheme.borderColor(context)),
        _buildPaymentOption(
          context: context,
          title: 'Google Pay',
          subtitleText: null,
          icon: Icons.g_mobiledata_rounded,
          value: 'Google Pay',
        ),
        Divider(height: 1, color: AppColorsTheme.borderColor(context)),
        _buildPaymentOption(
          context: context,
          title: 'Other payment methods',
          subtitleText: 'T/T\nPlace order first, pay with your preferred method later.',
          icon: Icons.account_balance_outlined,
          value: 'Other payment methods',
        ),
      ]);
    }

    return list;
  }

  IconData _getPaymentIcon(String val) {
    final lower = val.toLowerCase();
    if (lower.contains('card') || lower.contains('visa') || lower.contains('master')) {
      return Icons.credit_card_rounded;
    } else if (lower.contains('bkash')) {
      return Icons.account_balance_wallet_rounded;
    } else if (lower.contains('nagad')) {
      return Icons.mobile_friendly_rounded;
    } else if (lower.contains('bank')) {
      return Icons.account_balance_rounded;
    } else if (lower.contains('paypal')) {
      return Icons.payment_rounded;
    } else if (lower.contains('google') || lower.contains('gpay')) {
      return Icons.g_mobiledata_rounded;
    } else {
      return Icons.account_balance_outlined;
    }
  }

  Widget _buildPaymentShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Padding(
      padding: EdgeInsets.all(14.w),
      child: Column(
        children: List.generate(3, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index == 2 ? 0 : 12.h),
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Row(
                children: [
                  Container(
                    width: 20.w,
                    height: 20.h,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                  UIHelper.horizontalSpace(12.w),
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
                  ),
                  UIHelper.horizontalSpace(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 120.w, height: 14.h, color: Colors.white),
                        UIHelper.verticalSpace(4.h),
                        Container(width: 180.w, height: 10.h, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required String title,
    String? subtitleText,
    Widget? subtitleWidget,
    required IconData icon,
    required String value,
    bool showArrow = false,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              activeColor: primaryOrange,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedPaymentMethod = val;
                  });
                }
              },
            ),
            UIHelper.horizontalSpace(4.w),
            Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: AppColorsTheme.background(context),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColorsTheme.borderColor(context)),
              ),
              child: Icon(icon, size: 20.sp, color: primaryOrange),
            ),
            UIHelper.horizontalSpace(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  if (subtitleWidget != null) ...[
                    UIHelper.verticalSpace(4.h),
                    subtitleWidget,
                  ],
                  if (subtitleText != null && subtitleText.isNotEmpty) ...[
                    UIHelper.verticalSpace(2.h),
                    Text(
                      subtitleText,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColorsTheme.textMutedColor(context),
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: AppColorsTheme.textMutedColor(context)),
          ],
        ),
      ),
    );
  }
}
