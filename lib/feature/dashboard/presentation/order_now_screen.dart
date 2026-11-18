import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../model/my_product_model.dart';
import 'widgets/checkout/checkout_address_card.dart';
import 'widgets/checkout/checkout_delivery_banner.dart';
import 'widgets/checkout/checkout_payment_section.dart';
import 'widgets/checkout/checkout_voucher_section.dart';

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
  bool _isSummaryExpanded = false;
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardProvider = context.read<DashboardProvider>();
      dashboardProvider.fetchCheckoutState();
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
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
                'Payment Successful'.tr,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
              UIHelper.verticalSpace(6.h),
              Text(
                'Congratulation! Your order has been placed successfully.'.tr,
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
                    Navigator.pushReplacementNamed(context, Routes.dashboardScreen);
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
                    'Back to Dashboard'.tr,
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
    final dashboardProvider = context.watch<DashboardProvider>();
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
    final double itemSubtotal = unitPriceNum > 0 ? (unitPriceNum * dashboardProvider.orderQuantity) : (cartProvider.subtotal > 0 ? cartProvider.subtotal : 0.0);
    final double grandTotalBdt = itemSubtotal + shippingFee;
    final double grandTotalUsd = grandTotalBdt / 115.0;

    final appliedCouponText = dashboardProvider.wholesaleCheckoutModel?.data?.appliedCoupon ?? dashboardProvider.checkoutResponseModel?.data?.coupon;

    if (_couponController.text.isEmpty && appliedCouponText != null && appliedCouponText.isNotEmpty) {
      _couponController.text = appliedCouponText;
    }

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppColorsTheme.background(context),
        elevation: 0,
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
              // Package Info Banner
              if (dashboardProvider.checkoutResponseModel?.data?.package != null) ...[
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
                              dashboardProvider.checkoutResponseModel!.data!.package!.name ?? 'Package',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColorsTheme.textMainColor(context),
                              ),
                            ),
                            if (dashboardProvider.checkoutResponseModel!.data!.package!.validityDays != null) ...[
                              UIHelper.verticalSpace(2.h),
                              Text(
                                'Validity: ${dashboardProvider.checkoutResponseModel!.data!.package!.validityDays} days',
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

              // 1. Shipping Address Section
              CheckoutAddressCard(dashboardProvider: dashboardProvider),
              UIHelper.verticalSpace(16.h),

              // 2. Guaranteed Delivery & Shipping Info Section
              CheckoutDeliveryBanner(
                dashboardProvider: dashboardProvider,
                shippingFee: shippingFee,
              ),
              UIHelper.verticalSpace(16.h),

              // 3. Order Items Section
              Text(
                'Order items'.tr,
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
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: AppColorsTheme.borderColor(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  onTap: () => dashboardProvider.decrementOrderQuantity(),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                    child: Icon(Icons.remove, size: 14.sp, color: AppColorsTheme.textMainColor(context)),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                                  child: Text(
                                    '${dashboardProvider.orderQuantity}',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColorsTheme.textMainColor(context),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => dashboardProvider.incrementOrderQuantity(),
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
                          'Add note to supplier'.tr,
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

              // 4. Voucher / Coupon Section
              CheckoutVoucherSection(
                dashboardProvider: dashboardProvider,
                couponController: _couponController,
              ),
              UIHelper.verticalSpace(20.h),

              // 5. Payment Method Section
              CheckoutPaymentSection(
                dashboardProvider: dashboardProvider,
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
                        'Total'.tr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                      UIHelper.horizontalSpace(8.w),
                      Text(
                        dashboardProvider.wholesaleCheckoutModel?.data?.total?.formatted ??
                            (dashboardProvider.checkoutResponseModel?.data?.quote?.total?.formatted ?? 'USD ${grandTotalUsd.toStringAsFixed(2)}'),
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
                  Text('Items Subtotal'.tr, style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context))),
                  Text(
                    dashboardProvider.wholesaleCheckoutModel?.data?.subtotal?.formatted ??
                        (dashboardProvider.checkoutResponseModel?.data?.quote?.subtotal?.formatted ?? 'BDT ${itemSubtotal.toStringAsFixed(2)}'),
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                  ),
                ],
              ),
              UIHelper.verticalSpace(4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Shipping Fee'.tr, style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context))),
                  Text(
                    dashboardProvider.wholesaleCheckoutModel?.data?.shipping?.formatted ?? 'BDT ${shippingFee.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                  ),
                ],
              ),
            ],
            UIHelper.verticalSpace(12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: dashboardProvider.isLoadingCheckout
                    ? null
                    : () async {
                        if (dashboardProvider.selectedAddress == null) {
                          Navigator.pushNamed(context, Routes.addAddressScreen).then((_) {
                            dashboardProvider.fetchCheckoutState();
                          });
                        } else {
                          final success = await dashboardProvider.confirmWholesaleOrder();
                          if (success && mounted) {
                            cartProvider.clearCart();
                            _showSuccessDialog(context);
                          }
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
                child: dashboardProvider.isLoadingCheckout
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        dashboardProvider.selectedAddress != null ? 'Place Order'.tr : 'Add address'.tr,
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
}
