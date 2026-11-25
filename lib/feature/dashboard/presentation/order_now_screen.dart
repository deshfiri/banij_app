import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../model/my_product_model.dart';
import 'widgets/checkout/checkout_address_card.dart';
import 'widgets/checkout/checkout_attention_card.dart';
import 'widgets/checkout/checkout_bottom_bar.dart';
import 'widgets/checkout/checkout_delivery_banner.dart';
import 'widgets/checkout/checkout_header_widgets.dart';
import 'widgets/checkout/checkout_order_items.dart';
import 'widgets/checkout/checkout_payment_flow.dart';
import 'widgets/checkout/checkout_payment_section.dart';
import 'widgets/checkout/checkout_ui.dart';
import 'widgets/checkout/checkout_voucher_section.dart';

class OrderNowScreen extends StatefulWidget {
  final ProductItemModel? product;

  const OrderNowScreen({super.key, this.product});

  @override
  State<OrderNowScreen> createState() => _OrderNowScreenState();
}

class _OrderNowScreenState extends State<OrderNowScreen> {
  final TextEditingController _couponController = TextEditingController();
  bool _isFixingCart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardProvider = context.read<DashboardProvider>();
      dashboardProvider.fetchCheckoutState();
      // Fresh cart so problems / changed prices are known before checkout.
      context.read<CartProvider>().fetchCart();
      // An activation payment left open (app closed mid-payment) can be resumed.
      dashboardProvider.loadLatestPayment();
    });
  }

  /// Reloads the cart and the checkout quote together.
  Future<void> _refreshCartAndCheckout() async {
    await Future.wait([
      context.read<CartProvider>().fetchCart(),
      context.read<DashboardProvider>().fetchCheckoutState(),
    ]);
  }

  Future<void> _acceptNewPrices() async {
    setState(() => _isFixingCart = true);
    await context.read<CartProvider>().acceptPrices();
    if (!mounted) return;
    await _refreshCartAndCheckout();
    if (mounted) setState(() => _isFixingCart = false);
  }

  void _reviewCart() {
    Navigator.pushNamed(context, Routes.cartScreen).then((_) {
      if (mounted) _refreshCartAndCheckout();
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final cartProvider = context.watch<CartProvider>();
    final product = widget.product;

    final imageUrl = (product?.image?.url != null && product!.image!.url!.isNotEmpty)
        ? product.image!.url!
        : (cartProvider.cartItems.isNotEmpty ? (cartProvider.cartItems.first.product.image?.url ?? '') : '');

    final productTitle =
        product?.name ??
        (cartProvider.cartItems.isNotEmpty
            ? (cartProvider.cartItems.first.product.name ?? 'Wholesale Product')
            : 'Wholesale Product');

    final double unitPriceNum = product != null
        ? (double.tryParse(product.wholesale?.price?.amount ?? '') ??
              (double.tryParse(product.wholesale?.price?.formatted?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '') ?? 0.0))
        : (cartProvider.cartItems.isNotEmpty ? cartProvider.subtotal : 0.0);

    final String productPrice =
        product?.wholesale?.price?.formatted ??
        (cartProvider.cartItems.isNotEmpty
            ? (cartProvider.cartItems.first.product.wholesale?.price?.formatted ??
                  '৳ ${unitPriceNum.toStringAsFixed(2)}')
            : '৳ ${unitPriceNum.toStringAsFixed(2)}');

    final minOrder = product?.wholesale?.minOrderQuantity ?? 1;
    final categoryVariant = product?.category ?? product?.brand ?? 'Standard Unit';

    final double shippingFee = cartProvider.deliveryFee > 0 ? cartProvider.deliveryFee : 60.0;
    final double itemSubtotal = unitPriceNum > 0
        ? (unitPriceNum * dashboardProvider.orderQuantity)
        : (cartProvider.subtotal > 0 ? cartProvider.subtotal : 0.0);
    final double grandTotalBdt = itemSubtotal + shippingFee;
    final double grandTotalUsd = grandTotalBdt / 115.0;

    final appliedCouponText =
        dashboardProvider.wholesaleCheckoutModel?.data?.appliedCoupon ??
        dashboardProvider.checkoutResponseModel?.data?.coupon;
    final orderTotalText =
        dashboardProvider.wholesaleCheckoutModel?.data?.total?.formatted ??
        dashboardProvider.checkoutResponseModel?.data?.quote?.total?.formatted ??
        'USD ${grandTotalUsd.toStringAsFixed(2)}';
    final subtotalText =
        dashboardProvider.wholesaleCheckoutModel?.data?.subtotal?.formatted ??
        dashboardProvider.checkoutResponseModel?.data?.quote?.subtotal?.formatted ??
        'BDT ${itemSubtotal.toStringAsFixed(2)}';
    final shippingText =
        dashboardProvider.wholesaleCheckoutModel?.data?.shipping?.formatted ?? 'BDT ${shippingFee.toStringAsFixed(2)}';

    if (_couponController.text.isEmpty && appliedCouponText != null && appliedCouponText.isNotEmpty) {
      _couponController.text = appliedCouponText;
    }

    // Sections, built once and placed in one or two columns below.
    // Wholesale cart the server will not quote yet (cart_not_ready).
    final cartBlocked = !dashboardProvider.isPackageCheckout &&
        cartProvider.cartLines.isNotEmpty &&
        (cartProvider.needsAttention || dashboardProvider.wholesaleCheckoutError != null);
    final attentionCard = cartBlocked
        ? CheckoutAttentionCard(
            message: dashboardProvider.wholesaleCheckoutError ?? 'Your cart needs attention before checkout.'.tr,
            problemLines: cartProvider.problemLines,
            hasPriceChanges: cartProvider.hasPriceChanges,
            isBusy: _isFixingCart,
            onAcceptPrices: _acceptNewPrices,
            onReviewCart: _reviewCart,
          )
        : null;

    final openPaymentCard = dashboardProvider.hasOpenPayment
        ? CheckoutOpenPaymentCard(
            status: dashboardProvider.latestPayment?.status,
            onCheckStatus: () async {
              final paid = await CheckoutPaymentFlow.resumeActivationPayment(
                context,
                dashboardProvider,
                amountText: orderTotalText,
              );
              if (!context.mounted) return;
              if (paid) {
                Navigator.pushReplacementNamed(context, Routes.dashboardScreen);
              } else {
                dashboardProvider.loadLatestPayment();
              }
            },
          )
        : null;

    final packageBanner = dashboardProvider.checkoutResponseModel?.data?.package != null
        ? CheckoutPackageBanner(package: dashboardProvider.checkoutResponseModel!.data!.package!)
        : null;
    final addressCard = CheckoutAddressCard(dashboardProvider: dashboardProvider);
    final deliveryCard = CheckoutDeliveryBanner(dashboardProvider: dashboardProvider, shippingFee: shippingFee);
    final itemsCard = cartProvider.cartLines.isNotEmpty
        ? CheckoutSectionCard(
            title: 'Order items'.tr,
            icon: Icons.inventory_2_outlined,
            trailing: CheckoutCountBadge(label: '${cartProvider.cartLines.length}'),
            child: Column(children: cartProvider.cartLines.map((line) => CheckoutCartLineTile(line: line)).toList()),
          )
        : CheckoutSectionCard(
            title: 'Order items'.tr,
            icon: Icons.inventory_2_outlined,
            child: CheckoutSingleProductCard(
              imageUrl: imageUrl,
              categoryVariant: categoryVariant,
              productTitle: productTitle,
              minOrder: minOrder,
              productPrice: productPrice,
              quantity: dashboardProvider.orderQuantity,
            ),
          );
    final voucherCard = CheckoutVoucherSection(
      dashboardProvider: dashboardProvider,
      couponController: _couponController,
    );
    final paymentCard = CheckoutPaymentSection(dashboardProvider: dashboardProvider);
    final summaryCard = CheckoutSummaryCard(
      subtotalText: subtotalText,
      shippingText: shippingText,
      totalText: orderTotalText,
      couponText: appliedCouponText,
    );

    Widget column(List<Widget?> children) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final child in children.whereType<Widget>()) ...[child, UIHelper.verticalSpace(14.h)],
      ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            HeroPageHeader(
              title: 'Checkout'.tr,
              trailing: HeroIconButton(
                icon: Icons.headset_mic_outlined,
                onTap: () => ToastUtil.showSuccessMessage('Opening support...'),
              ),
              bottom: const CheckoutTrustPill(),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  return SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 6.h),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isWide ? 1100 : 720),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: column([
                                      openPaymentCard,
                                      attentionCard,
                                      packageBanner,
                                      addressCard,
                                      deliveryCard,
                                      itemsCard,
                                    ]),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(flex: 2, child: column([voucherCard, paymentCard, summaryCard])),
                                ],
                              )
                            : column([
                                openPaymentCard,
                                attentionCard,
                                packageBanner,
                                addressCard,
                                deliveryCard,
                                itemsCard,
                                voucherCard,
                                paymentCard,
                                summaryCard,
                              ]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: CheckoutBottomBar(
          totalText: orderTotalText,
          subtotalText: subtotalText,
          shippingText: shippingText,
          isLoading: dashboardProvider.isLoadingCheckout || dashboardProvider.isPaying,
          hasAddress: dashboardProvider.selectedAddress != null,
          onPrimaryPressed: () async {
            if (dashboardProvider.selectedAddress == null) {
              Navigator.pushNamed(context, Routes.addAddressScreen).then((_) {
                dashboardProvider.fetchCheckoutState();
              });
              return;
            }

            // Package activation: pay with SSLCommerz through the backend
            // (POST /checkout → hosted page → verify / status → result).
            if (dashboardProvider.isPackageCheckout) {
              final paid = await CheckoutPaymentFlow.runActivationPayment(
                context,
                dashboardProvider,
                coupon: dashboardProvider.checkoutCoupon,
                amountText: orderTotalText,
              );
              if (!context.mounted || !paid) return;
              cartProvider.clearCart();
              Navigator.pushReplacementNamed(context, Routes.dashboardScreen);
              return;
            }

            // Wholesale cart that the server will not quote yet: fix it first.
            if (cartBlocked) {
              ToastUtil.showErrorMessage(
                dashboardProvider.wholesaleCheckoutError ?? 'Your cart needs attention before checkout.'.tr,
              );
              _reviewCart();
              return;
            }

            // Wholesale cart order: the backend creates the order and, for an
            // online method, returns the SSLCommerz page to pay it on.
            final success = await dashboardProvider.confirmWholesaleOrder();
            if (!context.mounted || !success) return;
            cartProvider.clearCart(); // The order exists now, paid or not.

            final paymentUrl = dashboardProvider.wholesalePaymentUrl;
            if (paymentUrl != null) {
              await CheckoutPaymentFlow.payWholesaleOrder(context, paymentUrl, amountText: orderTotalText);
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, Routes.dashboardScreen);
              return;
            }

            // Pay-later method.
            CheckoutSuccessDialog.show(context);
          },
        ),
      ),
    );
  }
}
