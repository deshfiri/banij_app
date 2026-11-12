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
import '../model/checkout_response_model.dart';
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
  String _selectedPaymentMethod = 'bKash';
  bool _isLoading = false;
  bool _isSummaryExpanded = false;
  bool _isApplyingCoupon = false;

  final TextEditingController _couponController = TextEditingController();

  bool _isLoadingPaymentMethods = true;
  PaymentMethodResponseModel? _paymentResponseModel;

  bool _isLoadingAddresses = true;
  AddressResponseModel? _addressResponseModel;
  AddressItemModel? _selectedAddress;
  CheckoutResponseModel? _checkoutResponseModel;

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
    _fetchAddresses();
    _fetchCheckoutDetails();
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _fetchCheckoutDetails() async {
    try {
      _checkoutResponseModel = await checkoutRxObj.fetchCheckoutDetails();
      if (_checkoutResponseModel?.data?.coupon != null) {
        _couponController.text = _checkoutResponseModel!.data!.coupon!;
      }
      if (mounted) {
        setState(() {});
      }
    } catch (_) {}
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
      } else {
        _selectedAddress = null;
      }
    } catch (_) {
      _addressResponseModel = AddressResponseModel(data: []);
      _selectedAddress = null;
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

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      ToastUtil.showErrorMessage('Please enter a coupon code');
      return;
    }
    setState(() {
      _isApplyingCoupon = true;
    });
    try {
      await checkoutRxObj.coupon({"code": code});
      ToastUtil.showSuccessMessage('Coupon applied successfully!');
    } catch (e) {
      String err = e.toString().replaceAll('Exception: ', '');
      ToastUtil.showErrorMessage(err.isNotEmpty ? err : 'Failed to apply coupon');
    } finally {
      if (mounted) {
        setState(() {
          _isApplyingCoupon = false;
        });
      }
    }
  }

  Future<void> _placeOrder(CartProvider cartProvider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final body = {
        "payment_method": _selectedPaymentMethod,
        if (_selectedAddress != null) "address_id": _selectedAddress!.id,
      };
      await checkoutRxObj.pay(body);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        cartProvider.clearCart();
        _showSuccessDialog(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      String err = e.toString().replaceAll('Exception: ', '');
      ToastUtil.showErrorMessage(err.isNotEmpty ? err : 'Payment failed. Please try again.');
    }
  }

  Future<void> _showAddressSelectionSheet(BuildContext context) async {
    try {
      _addressResponseModel = await addressRxObj.fetchAddresses();
    } catch (_) {}

    if (!mounted) return;

    final addresses = _addressResponseModel?.data ?? [];

    if (!mounted) return;

    showModalBottomSheet(
      context: this.context,
      backgroundColor: AppColorsTheme.cardBg(this.context),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Address',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppColorsTheme.textMainColor(context)),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            UIHelper.verticalSpace(12.h),
            if (addresses.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.location_off_outlined, size: 40.sp, color: AppColorsTheme.textMutedColor(context)),
                      UIHelper.verticalSpace(8.h),
                      Text(
                        'Address is not found',
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          color: AppColorsTheme.textMutedColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300.h),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final addr = addresses[index];
                    final isSelected = _selectedAddress?.id == addr.id;
                    return Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      decoration: BoxDecoration(
                        color: AppColorsTheme.background(context),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected ? primaryOrange : AppColorsTheme.borderColor(context),
                          width: isSelected ? 1.5.w : 1.w,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected ? primaryOrange : AppColorsTheme.textMutedColor(context),
                        ),
                        title: Text(
                          addr.recipientName ?? 'Address ${index + 1}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColorsTheme.textMainColor(context),
                          ),
                        ),
                        subtitle: Text(
                          addr.fullAddressFormatted.isNotEmpty ? addr.fullAddressFormatted : 'No address details',
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
                      ),
                    );
                  },
                ),
              ),
            UIHelper.verticalSpace(16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, Routes.addAddressScreen).then((_) {
                    _fetchAddresses();
                  });
                },
                icon: Icon(Icons.add, size: 18.sp),
                label: Text(
                  'Add New Address',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
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
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AppColorsTheme.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 48.sp,
                  color: const Color(0xFF10B981),
                ),
              ),
              UIHelper.verticalSpace(20.h),
              Text(
                'Payment Successful',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
              UIHelper.verticalSpace(6.h),
              Text(
                'Congratulation! Your order has been placed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColorsTheme.textMutedColor(context),
                ),
              ),
              UIHelper.verticalSpace(24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamedAndRemoveUntil(context, Routes.dashboardScreen, (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Download your booking task',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              UIHelper.verticalSpace(10.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamedAndRemoveUntil(context, Routes.dashboardScreen, (route) => false);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColorsTheme.textMainColor(context),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    side: BorderSide(color: AppColorsTheme.borderColor(context)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
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
              // Package Info Banner from GET /checkout
              if (_checkoutResponseModel?.data?.package != null) ...[
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: primaryOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: primaryOrange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.workspace_premium_rounded, color: primaryOrange, size: 24.sp),
                      UIHelper.horizontalSpace(12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _checkoutResponseModel!.data!.package!.name ?? 'Package',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColorsTheme.textMainColor(context),
                              ),
                            ),
                            if (_checkoutResponseModel!.data!.package!.validityDays != null) ...[
                              UIHelper.verticalSpace(2.h),
                              Text(
                                'Validity: ${_checkoutResponseModel!.data!.package!.validityDays} days',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColorsTheme.textMutedColor(context),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                UIHelper.verticalSpace(16.h),
              ],

              // 1. Address Card Banner (Tapping fetches GET API address list & opens sheet or Add Address screen)
              _isLoadingAddresses
                  ? _buildAddressShimmer(context)
                  : GestureDetector(
                      onTap: () {
                        if (_selectedAddress == null) {
                          Navigator.pushNamed(context, Routes.addAddressScreen).then((_) {
                            _fetchAddresses();
                          });
                        } else {
                          _showAddressSelectionSheet(context);
                        }
                      },
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
                                    _selectedAddress != null
                                        ? (_selectedAddress!.recipientName ?? 'Selected Address')
                                        : 'Address is not found',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColorsTheme.textMainColor(context),
                                    ),
                                  ),
                                  UIHelper.verticalSpace(2.h),
                                  Text(
                                    _selectedAddress != null
                                        ? _selectedAddress!.fullAddressFormatted
                                        : 'Add your address for shipping options and more accurate costs.',
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      color: AppColorsTheme.textMutedColor(context),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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

              // 3. Order Items Section (Dynamic from Cart / Checkout quote lines)
              Text(
                'Order items',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
              UIHelper.verticalSpace(10.h),
              if (cartProvider.cartLines.isNotEmpty)
                ...cartProvider.cartLines.map((line) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColorsTheme.cardBg(context),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColorsTheme.borderColor(context)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.network(
                            line.product?.image?.url ?? '',
                            width: 54.w,
                            height: 54.h,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              width: 54.w,
                              height: 54.h,
                              color: primaryOrange.withValues(alpha: 0.1),
                              child: Icon(Icons.inventory_2_outlined, color: primaryOrange, size: 22.sp),
                            ),
                          ),
                        ),
                        UIHelper.horizontalSpace(12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                line.product?.name ?? 'Product Item',
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColorsTheme.textMainColor(context),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              UIHelper.verticalSpace(2.h),
                              Text(
                                '${line.quantity ?? 1} × ${line.unitPrice?.formatted ?? ''}',
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  color: AppColorsTheme.textMutedColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          line.lineTotal?.formatted ?? '',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            color: primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  );
                })
              else
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

              // Apply Voucher / Coupon Section
              Text(
                'Apply Voucher',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
              UIHelper.verticalSpace(10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColorsTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColorsTheme.borderColor(context)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _couponController,
                        style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMainColor(context)),
                        decoration: InputDecoration(
                          hintText: 'Enter coupon code',
                          hintStyle: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isApplyingCoupon ? null : _applyCoupon,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        elevation: 0,
                      ),
                      child: _isApplyingCoupon
                          ? SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Apply',
                              style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold),
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
                        _checkoutResponseModel?.data?.quote?.total?.formatted ?? 'USD ${grandTotalUsd.toStringAsFixed(2)}',
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
                  Text(_checkoutResponseModel?.data?.quote?.subtotal?.formatted ?? 'BDT ${itemSubtotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context))),
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
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_selectedAddress == null) {
                          Navigator.pushNamed(context, Routes.addAddressScreen).then((_) {
                            _fetchAddresses();
                          });
                        } else {
                          _placeOrder(context.read<CartProvider>());
                        }
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
            iconColor: _getPaymentColor(val),
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
            iconColor: _getPaymentColor(val),
            value: val,
          ),
        );
      }
    } else {
      list.addAll([
        _buildPaymentOption(
          context: context,
          title: 'bKash',
          subtitleText: 'Pay securely with bKash mobile banking',
          icon: Icons.account_balance_wallet_rounded,
          iconColor: const Color(0xFFE2136E),
          value: 'bKash',
        ),
        Divider(height: 1, color: AppColorsTheme.borderColor(context)),
        _buildPaymentOption(
          context: context,
          title: 'Nagad',
          subtitleText: 'Pay securely with Nagad mobile financial service',
          icon: Icons.mobile_friendly_rounded,
          iconColor: const Color(0xFFED1C24),
          value: 'Nagad',
        ),
        Divider(height: 1, color: AppColorsTheme.borderColor(context)),
        _buildPaymentOption(
          context: context,
          title: 'PayPal',
          subtitleText: null,
          icon: Icons.payment_rounded,
          iconColor: primaryOrange,
          value: 'PayPal',
        ),
        Divider(height: 1, color: AppColorsTheme.borderColor(context)),
        _buildPaymentOption(
          context: context,
          title: 'Other payment methods',
          subtitleText: 'T/T\nPlace order first, pay with your preferred method later.',
          icon: Icons.account_balance_outlined,
          iconColor: AppColorsTheme.textMutedColor(context),
          value: 'Other payment methods',
        ),
      ]);
    }

    return list;
  }

  Color _getPaymentColor(String val) {
    final lower = val.toLowerCase();
    if (lower.contains('bkash')) {
      return const Color(0xFFE2136E);
    } else if (lower.contains('nagad')) {
      return const Color(0xFFED1C24);
    } else if (lower.contains('card') || lower.contains('visa')) {
      return const Color(0xFF0284C7);
    } else {
      return primaryOrange;
    }
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

  Widget _buildPaymentLogo(String title, Color brandColor) {
    final lower = title.toLowerCase();
    bool isBkash = lower.contains('bkash');
    bool isNagad = lower.contains('nagad');

    if (isBkash) {
      return Container(
        width: 52.w,
        height: 32.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColorsTheme.borderColor(context)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Image.network(
            'https://static.vecteezy.com/system/resources/previews/039/340/798/non_2x/bkash-logo-free-vector.jpg',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE2136E),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  'bKash',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (isNagad) {
      return Container(
        width: 52.w,
        height: 32.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColorsTheme.borderColor(context)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Image.network(
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrBk93RWS1sEp0YhxzsCPXVxu5ldNjhyHOdbfi9sEbEw&s',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFED1C24),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  'Nagad',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(7.w),
      decoration: BoxDecoration(
        color: brandColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Icon(Icons.payment_rounded, size: 20.sp, color: brandColor),
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required String title,
    String? subtitleText,
    Widget? subtitleWidget,
    required IconData icon,
    Color? iconColor,
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
            _buildPaymentLogo(title, iconColor ?? primaryOrange),
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
